import 'dart:io';
import 'dart:ui';
import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/model/contact_number.dart';
import 'package:ekaon/services/address_listener.dart';
import 'package:ekaon/services/cart.dart';
import 'package:ekaon/services/contact_number_listener.dart';
import 'package:ekaon/services/discount.dart';
import 'package:ekaon/services/discount_collected_listener.dart';
import 'package:ekaon/services/distancer.dart';
import 'package:ekaon/services/distancer_service.dart';
import 'package:ekaon/services/location_picker.dart';
import 'package:ekaon/services/order.dart';
import 'package:ekaon/services/order_listener.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/pricer.dart';
import 'package:ekaon/services/store.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/home_page.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/ticket_clipper.dart';
import 'package:ekaon/views/home_page_children/drawer/transaction_children/order_details.dart';
import 'package:ekaon/views/map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class CheckoutPage extends StatefulWidget {
  final Map toCheckout;
  void useDelivery(BuildContext context, {Map data}) {
    context.findAncestorStateOfType<_CheckoutPageState>().useDeliveryAddress(data: data);
  }
  CheckoutPage({Key key, @required this.toCheckout}) : super( key : key );
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isDelivery = true;
  Map discountData;
  bool _hasDelivery = true;
  bool showCollectedVoucher = false;
  Color selectedColor = Color.fromRGBO(0, 171, 225, 1);
  bool _isTimeManual = false;
  TimeOfDay chosenTime = TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 20)));
  double deliveryCharge = 0.0;
  bool _keyboardVisible = false;
  bool _isLocFetching = false;
  Map _chosenLocation;
  String chosenNumber;
  bool _activeAddressChoice = false;
  double subTotal = 0.0;
  double distance = 0.0;
  DateTime now = DateTime.now();
  bool _activeContactChoice = false;
  bool _isLoading = false;
  GlobalKey _key = new GlobalKey();
  Future useDeliveryAddress({Map data}) async {
    print(data);
    setState(() {
      _chosenLocation = data;
    });
    getDelCharge();
//    getDistance();
  }
  get deliveryChargeGetter {
    if(_isDelivery){
      return deliveryCharge;
    }
    return 0;
  }
  getDelCharge() async {
    //widget.toCheckout['store']['latitude'], widget.toCheckout['store']['longitude']
    double dd = await distanceService.calculateDistance(Position(longitude: _chosenLocation['longitude'], latitude: _chosenLocation['latitude']),destination: Position(
      latitude: double.parse(widget.toCheckout['store']['latitude'].toString()),
      longitude: double.parse(widget.toCheckout['store']['longitude'].toString())
    ));
    setState(() {
      distance = dd;
      deliveryCharge = distance * double.parse(widget.toCheckout['store']['delivery_charge_per_km'].toString());
      print("INIT CHARGE : $deliveryCharge");
      if(deliveryCharge >= 1){
        deliveryCharge = distance * double.parse(widget.toCheckout['store']['delivery_charge_per_km'].toString());
      }else{
        deliveryCharge = 0.0;
      }
    });
    print("DISTANCE : $distance");
    print("CHARGE : $deliveryCharge");
  }
  getVouchers() async {
    if(discountCollected.current == null){
      await discountCollected.fetchFromServer();
    }
//    vouchers = discountCollected.current;
  }
  double getDiscount() {
    print(discountData);
    if(discountData != null){
      if(discountData['type'].toString() == "1"){
        print("PERCENTAGE");
        var toMinus = Percentage().calculate(num: subTotal, percent: double.parse(discountData['value'].toString()));
        return toMinus;
      }else{
        var toMinus = double.parse(discountData['value'].toString());
        return toMinus;
      }
    }
    else return 0.0;
  }
  orderNow() async {
    setState(()=> _isLoading = true);
    List cart_data = await this.getNewDetails();
//    List subtotals = [];
//    List quantities = [];
//    List productIds = [];
//    for(var xx in widget.toCheckout['details']){
//      subtotals.add(xx['total']);
//      quantities.add(xx['quantity']);
//      productIds.add(xx['product']['id']);
//    }
    DateTime cDate = DateTime(now.year,now.month,now.day, chosenTime.hourOfPeriod,chosenTime.minute);

    await Order().add(
      context,
        ownerId: widget.toCheckout['store']['owner']['id'],
        storeId: widget.toCheckout['store']['id'],
        cartId: widget.toCheckout['id'],
        isDelivery: _isDelivery ? 1 : 0,
        cart_data: cart_data,
        location: _chosenLocation,
        time: cDate,
        withDiscount: discountData != null ? 1 : 0,
        total: calculateTotal(),
        orderI: _otherInstructions.text
    ).whenComplete(() => setState(()=> _isLoading = false));
  }
  getStoreState() async {
    for(var x = 0; x<cartAuth.current.length;x++){
      print(cartAuth.current[x]['store']);
      await Store().getStoreDeliveyState(cartAuth.current[x]['store']['id']).then((value) {
        if(value != null){
          setState(() {
            cartAuth.current[x]['store']['hasDelivery'] = value['status'];
            cartAuth.current[x]['store']['storeOpen'] = value['store_open'];
            _hasDelivery = value['status'].toString() == "1";
            _isDelivery = _hasDelivery;
          });
        }
      });
    }
  }
  Future getCurrentLocation() async {
    setState(() {
      _isLocFetching = true;
    });
    await distancer.getCurrentLocation().then((value) {
      setState(() {
        _chosenLocation = value;
      });
    }).whenComplete(() => setState(() => _isLocFetching = false));
  }
//  getDistance() async {
//    var dd = await distancer.getDifference(storeCoordinate: new Coordinates(widget.toCheckout['store']['latitude'], widget.toCheckout['store']['longitude']), chosenCoordinate: new Coordinates(_chosenLocation['latitude'], _chosenLocation['longitude']));
//    setState(() {
//      distance = double.parse(dd);
//      deliveryCharge = distance * double.parse(widget.toCheckout['store']['delivery_charge_per_km'].toString());
//      if(deliveryCharge >= 1){
//        deliveryCharge = distance * double.parse(widget.toCheckout['store']['delivery_charge_per_km'].toString());
//      }else{
//        deliveryCharge = 0.0;
//      }
//    });
//    print(distance);
//  }

  double calculateTotal() {
    double total = (priceChecker.calculateSubtotal(data: widget.toCheckout) + deliveryChargeGetter) - getDiscount();
    return total;
  }
//  calculateAdditionalPrice(){
//    for(var product in widget.toCheckout['details']){
//      if(product['selected_variations'] != null && product['selected_variations'].length > 0){
//        for(var additional in product['selected_variations']){
//          setState(() {
//            product['total'] += additional['details']['price'];
//          });
//        }
//      }
//    }
//  }
//  calculateSubtotal() {
//    for(var product in widget.toCheckout['details']){
//
//      setState(() {
//        subTotal += double.parse(product['total'].toString());
//      });
//      if(product['selected_variations'] != null && product['selected_variations'].length > 0){
//        for(var additional in product['selected_variations']){
//          setState(() {
//            subTotal += double.parse(additional['details']['price'].toString());
//          });
//        }
//      }
//    }
//  }
  getDefaultTime(){
    if(widget.toCheckout['store']['standard_delivery_time'] != null){
      setState(() {
        chosenTime = TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: int.parse("${widget.toCheckout['store']['standard_delivery_time']}"))));
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _hasDelivery = widget.toCheckout['store']['hasDelivery'].toString() == "1";
    });
    if(this.mounted){
      KeyboardVisibility.onChange.listen((event) {
        setState(() {
          _keyboardVisible = event;
        });
      });
//      getDelCharge();
    }
    if(contactListner.current != null && contactListner.current.length > 0){
      setState(() {
        chosenNumber = contactListner.current[0].number;
      });
    }
//    calculateSubtotal();
    getDefaultTime();
    getStoreState();
  }
  Future<List> getNewDetails() async {
    List da = [];
    for(var products in widget.toCheckout['details']){
      da.add({
        "\"cart_detail_id\"" : "\"${products['id']}\"",
        "\"quantity\"" : "\"${products['quantity']}\"",
        "\"total\"" : "\"${priceChecker.calculateProductTotal(products)}\""
      });
    }
    return da;
  }
  TextEditingController _otherInstructions = new TextEditingController();
  TextEditingController _discountCode = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    try{
      return Stack(
        children: <Widget>[
          GestureDetector(
            onTap: ()=> FocusScope.of(context).unfocus(),
            child: Scaffold(
              bottomSheet: showCollectedVoucher ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2,sigmaY: 2),
                child: StreamBuilder<List>(
                    stream: discountCollected.stream$,
                    builder: (context, data) {
                      try{
                        return AnimatedContainer(
                          width: double.infinity,
                          duration: Duration(milliseconds: 600),
                          height: Percentage().calculate(num: scrh,percent: data.hasData ? data.data.length == 0 ? 20 : 80 : 10),
                          color: Colors.grey[300],
                          child: !data.hasData ? Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                              ),
                            ),
                          ) : data.data.length == 0 ? Column(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                child: Row(
                                  children: <Widget>[
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Text("Collected Vouchers",style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () => setState(() => showCollectedVoucher = false),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text("No collected vouchers"),
                                ),
                              )
                            ],
                          ) : Column(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                child: Row(
                                  children: <Widget>[
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Text("Collected Vouchers",style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: () => setState(() => showCollectedVoucher = false),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  children: <Widget>[
                                    for(var voucher in data.data)...{
                                      Container(
                                        width: double.infinity,
                                        child: TicketWidget(
                                            height: Percentage().calculate(num: scrh,percent: 15),
                                            onPressed: (){},
                                            color: StringFormatter(string: voucher['color']).stringToColor(),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15), percent: 15),vertical: 10),
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    width: double.infinity,
                                                    height: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60),
                                                    child: Column(
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Container(
                                                              alignment: AlignmentDirectional.centerStart,
                                                              child: Row(
                                                                children: <Widget>[
                                                                  Expanded(
                                                                    child: RichText(
                                                                      textAlign: TextAlign.left,
                                                                      text: TextSpan(
                                                                          text: "${voucher['value']}",
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600,
                                                                              fontSize: Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60),percent: scrw > 700 ? 68 : 70)
                                                                          ),
                                                                          children: [
                                                                            TextSpan(
                                                                                text: "${voucher['type'].toString() == "1" ? "%" : "₱"} OFF",
                                                                                style: TextStyle(
                                                                                    fontWeight: FontWeight.w500,
                                                                                    fontSize:Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60),percent: scrw > 700 ? 18 : 20)
                                                                                )
                                                                            )
                                                                          ]
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        color: voucher['store_id'].toString() == widget.toCheckout['store']['id'].toString() ? kPrimaryColor : Colors.grey[600],
                                                                        borderRadius: BorderRadius.circular(5)
                                                                    ),

                                                                    child: FlatButton(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                                                      onPressed: voucher['store_id'].toString() == widget.toCheckout['store']['id'].toString() ? (){
                                                                        setState(() {
                                                                          _discountCode.clear();
                                                                        });
                                                                        print("VOUCHER DATA : $voucher");
                                                                        if(priceChecker.calculateSubtotal(data: widget.toCheckout) >= double.parse(voucher['on_reach'].toString())){
                                                                          setState(() {
                                                                            showCollectedVoucher = false;
                                                                            discountData = voucher;
                                                                          });
                                                                        }else{
                                                                          setState(() {
                                                                            showCollectedVoucher = false;
                                                                          });
                                                                          Fluttertoast.showToast(msg: "Min. Spend not reached");
                                                                        }
                                                                      } : null,
                                                                      child: Text(voucher['store_id'].toString() == widget.toCheckout['store']['id'].toString() ? "Apply" : "Not Available",style: TextStyle(
                                                                          color: Colors.white
                                                                      ),),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                          ),
                                                        ),
                                                        Container(
                                                          width: double.infinity,
                                                          child: Text("Valid until ${DateFormat('MMM. dd').format(DateTime.parse(voucher['valid_until']))}",style: TextStyle(
                                                              fontSize: Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60),percent: scrw > 700 ? 13 : 15)
                                                          ),),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  brokenLines(count: 15,height: 3.5,color: Colors.grey[200]),
                                                  Expanded(
                                                    child: Container(
                                                      margin: const EdgeInsets.only(top: 5),
                                                      child: Container(
                                                        width: double.infinity,
                                                        child: Text("Min spend ₱${"${double.parse(voucher['on_reach'].toString()).toStringAsFixed(2)}"}",style: TextStyle(
                                                            fontSize: Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60),percent: scrw > 700 ? 13 : 15)
                                                        ),),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      )
                                    }
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }catch(e){
                        return MyWidgets().errorBuilder(context,error: e.toString());
                      }
                    }
                ),
              ) : null,
              key: _key,
              resizeToAvoidBottomPadding: Platform.isIOS,
              appBar: AppBar(
                elevation: 0,
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
                backgroundColor: Colors.transparent,
                title: Text("Checkout",style: TextStyle(
                    color: Colors.black
                ),),
                centerTitle: true,
              ),
              body: Container(
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Scrollbar(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ListView(
                              children: <Widget>[
                                myInfo(),
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(20),
                                  child: Text("${widget.toCheckout['store']['name']}",style: TextStyle(
                                      fontSize: Percentage().calculate(num: scrh, percent: 2),
                                      fontWeight: FontWeight.w600
                                  ),),
                                ),
                                for(var products in widget.toCheckout['details'])...{
                                  productCards(products),
                                },
                                Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Divider(thickness: 2,)),
                                orderOption(),
//                  Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Divider(thickness: 2,)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: TextField(
                                    maxLines: 5,
                                    cursorColor: kPrimaryColor,
                                    controller: _otherInstructions,
                                    keyboardType: TextInputType.multiline,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        labelText: "Other Instructions",
                                        alignLabelWithHint: true
                                    ),
                                  ),
                                ),
                                Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Divider(thickness: 2,)),
                                discountCode(),
                                Padding(padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10), child: Divider(thickness: 2,)),
                                amountInfo(),
                                Platform.isAndroid && _keyboardVisible ? SizedBox(
                                  height: Percentage().calculate(num: scrh, percent: 40),
                                ) : Container()
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        color: Colors.grey[200],
                        padding: EdgeInsets.symmetric(horizontal: Percentage().calculate(num: scrw, percent: 10),vertical: Percentage().calculate(num: scrw, percent: 5)),
                        height: Percentage().calculate(num: scrh,percent: 13.5),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
//                      color: Colors.red,
                                child: RichText(
                                  text: TextSpan(
                                      text: "Total : ",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: Theme.of(context).textTheme.bodyText1.fontSize
                                      ),
                                      children: [
                                        TextSpan(
                                            text: "\n₱ ${this.calculateTotal().toStringAsFixed(2)}",
                                            style: TextStyle(
                                                color: kPrimaryColor
                                            )
                                        )
                                      ]
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      borderRadius: BorderRadius.circular(7)
                                  ),
                                  child: FlatButton(
                                    onPressed: () async {
//                                        List cart_data = await this.getNewDetails();
//                                        print(cart_data);
                                      if(widget.toCheckout['store']['storeOpen'] == 1){
                                        if(_chosenLocation != null){
                                          if(chosenTime != null){
                                            this.orderNow();
                                          }else{
                                            Fluttertoast.showToast(msg: "Add time");
                                          }
                                        }else{
                                          Fluttertoast.showToast(msg: "Add your location");
                                        }
                                      }else{
                                        Fluttertoast.showToast(msg: "Sorry,store is closed");
                                      }
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7)
                                    ),
                                    child: Center(
                                      child: Text("Place Order",style: TextStyle(
                                          color: Colors.white
                                      ),),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
//                  AnimatedContainer(
//                    width: double.infinity,
//                    height: Percentage().calculate(num: scrh , percent: _activeAddressChoice ? scrw > 700 ? 35 : 40 : 0),
//                    duration: Duration(milliseconds: 600),
//                    child: myAddress.show(useCurrentLocation: () async {
//                      await getCurrentLocation();
//                      setState(() {
//                        _activeAddressChoice = false;
//                      });
//                      getDelCharge();
////                      getDistance();
//                    }, onClose: (){
//                      setState(() {
//                        _activeAddressChoice = false;
//                      });
//                    }, context: _key.currentContext,myState: _CheckoutPageState()),
//                  ),
//                      AnimatedContainer(
//                        width: double.infinity,
//                        height: Percentage().calculate(num: scrh , percent: _activeContactChoice ? scrw > 700 ? 20 : 25 : 0),
//                        color: Colors.white,
//                        duration: Duration(milliseconds: 600),
//                        child: Column(
//                          children: <Widget>[
//                            Container(
//                                width: double.infinity,
////        alignment: AlignmentDirectional.centerEnd,
//                                decoration: BoxDecoration(
//                                    border: Border(bottom: BorderSide(color: Colors.grey[300]))
//                                ),
//                                child: Row(
//                                  children: <Widget>[
//                                    const SizedBox(width: 20,),
//                                    Expanded(
//                                      child: Text("My numbers :",style: TextStyle(
//                                          color: kPrimaryColor,
//                                          fontWeight: FontWeight.w600
//                                      ),),
//                                    ),
//                                    const SizedBox(width: 10,),
//                                    IconButton(
//                                      icon: Icon(Icons.close,color: Colors.grey[400],),
//                                      onPressed: ()=>setState(()=> _activeContactChoice = false),
//                                    ),
//                                  ],
//                                )
//                            ),
//                            Expanded(
//                              child: StreamBuilder<List<ContactNumber>>(
//                                  stream: contactListner.stream,
//                                  builder: (context, contact)=> contact.hasData ? contact.data.length > 0 ? ListView.builder(
//                                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
//                                    itemCount: contact.data.length,
//                                    itemBuilder: (context, index) => Container(
//                                      width: double.infinity,
//                                      height: 60,
//                                      margin: const EdgeInsets.only(bottom: 10),
//                                      child: FlatButton(
//                                        onPressed: (){
//                                          setState(() {
//                                            chosenNumber = contact.data[index].number;
//                                            _activeContactChoice = false;
//                                          });
//                                        },
//                                        child: Row(
//                                          children: <Widget>[
//                                            Icon(Icons.phone_in_talk,color: selectedColor,),
//                                            const SizedBox(
//                                              width: 10,
//                                            ),
//                                            Expanded(
//                                              child: Container(
//                                                width: double.infinity,
//                                                child: Text("${contact.data[index].number}"),
//                                              ),
//                                            )
//                                          ],
//                                        ),
//                                      ),
//                                    ),
//                                  ) : Center(
//                                    child: Text("No recorded contact number please add at least one"),
//                                  ) : Center(
//                                    child: CircularProgressIndicator(
//                                      valueColor: AlwaysStoppedAnimation(kPrimaryColor),
//                                    ),
//                                  )
//                              ),
//                            ),
//                          ],
//                        ),
//                      )
                    ],
                  )
              ),
            ),
          ),
          _isLoading ? MyWidgets().loader() : Container()
        ],
      );
    }catch(e){
      return MyWidgets().errorBuilder(context,error: e.toString());
    }
  }
  showBottomsheet({List<ListTile> buttons, bool specialButton}) => showModalBottomSheet(
      context: _key.currentContext,
      backgroundColor: Colors.grey[100],
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1,sigmaY: 1),
        child: Container(
          height: Percentage().calculate(num: scrh, percent: 40),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(5))
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    for(var button in buttons)...{
                      button
                    },
                    specialButton ? ListTile(
                      leading: Icon(Icons.add),
                      title: Text("Add"),
                      onTap: (){
                        locationPicker.show(context).then((LocationResult value) async {
                          if(value != null){
                            await myAddress.append(obj: {
                              "address" : value.address,
                              "longitude" : value.latLng.longitude,
                              "latitude" : value.latLng.latitude
                            });
                            Navigator.of(context).pop(null);
                          }
                        });
                      },
                    ) : Container()
                  ],
                ),
              ),
              specialButton ? ListTile(
                leading: Icon(Icons.my_location),
                title: Text("Use current location"),
                onTap: () async {
                  await getCurrentLocation();
                  Navigator.of(context).pop();
                  getDelCharge();
//                      getDistance();
                },
              ) : Container(),
              ListTile(
                leading: Icon(Icons.close),
                title: Text("Close"),
                onTap: (){
                  Navigator.of(context).pop(null);
                },
              )
            ],
          )
        ),
      )
  );
  Container amountContainer(String label, String value) => Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label,style: TextStyle(
            color: Colors.black54,
            fontSize: Theme.of(context).textTheme.subtitle1.fontSize - 2,
            fontWeight: FontWeight.w600
        ),),
        Text("$value",style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: Theme.of(context).textTheme.subtitle1.fontSize - 2
        ),)
      ],
    ),
  );
  Widget amountInfo()=>Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: <Widget>[
        amountContainer("Subtotal", "Php${priceChecker.calculateSubtotal(data: widget.toCheckout).toStringAsFixed(2)}"),
        !_isDelivery ? Container() : amountContainer("Delivery charge", "${_chosenLocation == null ? "Unspecified location" : deliveryCharge == 0.0 ? "Free" : "Php"+deliveryCharge.toStringAsFixed(2)}"),
        discountData == null ? Container() : amountContainer("Discount", "Php${getDiscount().toStringAsFixed(2)}"),
        amountContainer("Total", "Php${calculateTotal().toStringAsFixed(2)}")
      ],
    ),
  );
  bool showTextField = false;
  Widget discountCode(){

   return Container(
     margin: const EdgeInsets.only(top: 20),
     padding: const EdgeInsets.symmetric(horizontal: 20),
     child: Column(
       children: <Widget>[
         Container(
           width: double.infinity,
           child: Text("Add voucher",style: TextStyle(
               fontSize: Percentage().calculate(num: scrw, percent: 4)
           ),),
         ),
         Container(
           width: double.infinity,
           child: FlatButton(
             onPressed: (){
               showModalBottomSheet(
                   context: context,
                   builder: (_) => Container(
                     width: double.infinity,
                     height: 130,
                     child: Column(
                       children: [
                         ListTile(
                           leading: Icon(Icons.text_format),
                           title: Text("Enter a code"),
                           onTap: (){
                             Navigator.of(context).pop(null);
                             setState(() {
                               showTextField = true;
                             });
                           },
                         ),
                         ListTile(
                           leading: Icon(Icons.receipt),
                           title: Text("Select from collected voucher"),
                           onTap: (){
                             Navigator.of(context).pop(null);
                             setState(() {
                               showCollectedVoucher = true;
                             });
                             getVouchers();
                           },
                         )
                       ],
                     ),
                   )
               );
             },
             padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 10),
             child: showTextField ? Container(
               width: double.infinity,
               child: Row(
                 children: [
                   Expanded(
                     child: TextField(
                       controller: _discountCode,
                       autofocus: false,
                       cursorColor: kPrimaryColor,
                       decoration: InputDecoration(
                         hintText: "Enter voucher code"
                       ),
                     ),
                   ),
                   IconButton(icon: Icon(Icons.save), onPressed: ()async{
                     FocusScope.of(context).unfocus();
                     if(_discountCode.text.isNotEmpty){
                       setState(() {
                         _isLoading = true;
                         showTextField = false;
                       });
                       await Discount().check(widget.toCheckout['store']['id'], _discountCode.text).then((value) {
                         if(value != null){
                           if(priceChecker.calculateSubtotal(data:widget.toCheckout) >= double.parse(value['on_reach'].toString())){
                             Fluttertoast.showToast(msg: "${value['code']} applied");
                             setState(() {
                               discountData = value;
                             });
                           }else{
                             Fluttertoast.showToast(msg: "Min. Spend not reached");
                           }
                         }else{
                           Fluttertoast.showToast(msg: "Code not available");
                         }
                       }).whenComplete(() => setState(()=> _isLoading = false));
                     }else{
                       Fluttertoast.showToast(msg: "Empty discount code");
                     }
                   }
                   )
                 ],
               )
             ) :  discountData != null ? Container(
               margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
               width: double.infinity,
               child: Row(
                 children: <Widget>[
                   GestureDetector(
                     onTap: (){
                       print("${getDiscount()}");
                     },
                     child: Container(
                       width: 25,
                       height: 25,
                       child: Center(
                         child: Image.asset("assets/images/voucher.png",color: kPrimaryColor,),
                       ),
                     ),
                   ),
                   Spacer(),
                   Container(
                     child: Text("${discountData['code']} applied"),
                   )
                 ],
               ),
             ) : Text("No selected voucher",style: TextStyle(
                 color: Colors.grey,
                 fontWeight: FontWeight.w400
             ),),
           ),
         )
       ],
     ),
   );
  }

  Widget orderOption()=>Container(
    margin: const EdgeInsets.symmetric(vertical: 15),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          child: Text("Options",style: TextStyle(
            fontSize: Percentage().calculate(num: scrw, percent: 4)
          ),),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 20),
          height: Percentage().calculate(num: scrh,percent: 9),
          child: Row(
            children: <Widget>[
              _hasDelivery ? Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _isDelivery ? selectedColor : Colors.transparent,
                    border: Border.all(color: _isDelivery ? Colors.transparent : Colors.grey),
                    borderRadius: BorderRadius.circular(5)
                  ),
                  margin: const EdgeInsets.only(right: 10),
                  child: FlatButton(
                    onPressed: ()=>setState(()=> _isDelivery = true),
                    child: Center(
                      child: Text("Standard Delivery",style: TextStyle(
                        color: _isDelivery ? Colors.white : Colors.grey
                      ),textAlign: TextAlign.center,),
                    ),
                  ),
                ),
              ) : Container(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: !_isDelivery ? selectedColor : Colors.transparent,
                      border: Border.all(color: !_isDelivery ? Colors.transparent : Colors.grey),
                      borderRadius: BorderRadius.circular(5)
                  ),
                  margin: const EdgeInsets.only(right: 10),
                  child: FlatButton(
                    onPressed: ()=>setState(()=> _isDelivery = false),
                    child: Center(
                      child: Text("Store Pickup",style: TextStyle(
                          color: _isDelivery ? Colors.grey : Colors.white
                      ),textAlign: TextAlign.center),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: Text("${_isDelivery ? "Delivery" : "Pickup"} Time",style: TextStyle(
              fontSize: Percentage().calculate(num: scrw, percent: 4)
          ),),
        ),
        Container(
          width: double.infinity,
          child: Column(
//            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: ()=> setState((){
                        _isTimeManual = false;
                        chosenTime = TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 20)));
                      }),
                      icon: Icon(_isTimeManual ? Icons.radio_button_unchecked : Icons.radio_button_checked, color: _isTimeManual ? Colors.grey : selectedColor,),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text("Standard Time ${widget.toCheckout['store']['standard_delivery_time'] == null ? "(current time + 20 mins (default))" : "(current time + ${widget.toCheckout['store']['standard_delivery_time']} mins)"}"),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      onPressed: ()=> setState(()=> _isTimeManual = true),
                      icon: Icon(!_isTimeManual ? Icons.radio_button_unchecked : Icons.radio_button_checked, color: !_isTimeManual ? Colors.grey : selectedColor,),
                    ),

                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                  text: "Manual Input",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15
                                  ),
                                children: [
                                  TextSpan(
                                    text: "\n*note: 10 mins ahead delivery time",
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: Colors.black54
                                    )
                                  )
                                ]
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              setState((){
                                _isTimeManual = true;
                              });
                              TimeOfDay picked  = await showTimePicker(context: context,
                                  initialTime: TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 20))),
                                  builder: (context,child) => MediaQuery(
                                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                    child: child,
                                  )
                              );
                              if(picked != chosenTime){
                                DateTime pickedTime = DateTime(now.year, now.month, now.day,picked.hour,picked.minute);
                                if(now.add(Duration(minutes: 10)).isBefore(pickedTime)){
                                  setState(() {
                                    chosenTime = picked;
                                  });
                                }else{
                                  Fluttertoast.showToast(msg: "Please consider time of preparation is atleast 10 minutes",toastLength: Toast.LENGTH_LONG);
                                }
                              }
//                              DatePicker.showTime12hPicker(
//                                  context,
//                                  showTitleActions: true,
////                                  onConfirm: (time){
////                                    if(DateTime.now().add(Duration(minutes: 10)).isBefore(time)){
////                                      setState(() {
////                                        _chosenTime = time;
////                                      });
////                                    }else{
////                                      if(_isPickup){
////                                        Fluttertoast.showToast(msg: "Please consider time of preparation, atleast 10 minutes");
////                                      }else{
////                                        Fluttertoast.showToast(msg: "We can't travel back in time, time should be 10 min. ahead");
////                                      }
////                                    }
////                                  }
//                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 10),
                              width: double.infinity,
                              height: 60,
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 80,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: _isTimeManual ? selectedColor : Colors.grey),
                                      borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Center(
                                      child: Text(_isTimeManual ? chosenTime == null ? "00" : "${chosenTime.hourOfPeriod.toString().padLeft(2,"0")}" : "00",style: TextStyle(
                                        color: _isTimeManual ? selectedColor : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20
                                      ),),
                                    ),
                                  ),
                                  Container(
                                    height: 60,
                                    margin: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Center(
                                      child: Text(":",style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17,
                                        color: _isTimeManual ? selectedColor : Colors.grey
                                      ),)
                                    ),
                                  ),
                                  Container(
                                    width: 80,
                                    height: 60,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: _isTimeManual ? selectedColor : Colors.grey),
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Center(
                                      child: Text(_isTimeManual ? chosenTime == null ? "00" : "${chosenTime.minute.toString().padLeft(2,"0")}" : "00",style: TextStyle(
                                          color: _isTimeManual ? selectedColor : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20
                                      ),),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    alignment: AlignmentDirectional.topStart,
                                    child: Text(_isTimeManual ? chosenTime == null ? "--" : "${chosenTime.format(context).split(' ')[1]}" : "--",style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17
                                    ),),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    ),
  );
  Widget productCards(Map data)=> Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 5,right: 20,left: 20),
    color: Colors.grey[200],
    padding: const EdgeInsets.all(10),
    child: Column(
      children: [
        Row(
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  color: Colors.grey[100],
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: data['product']['images'].length > 0 ? NetworkImage("https://ekaon.checkmy.dev${data['product']['images'][0]['url']}") : AssetImage("assets/images/no-image-available.png")
                  )
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: Text("${data['product']['name']}",maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(
                        fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                      ),),
                    ),
                    Container(
                      width: double.infinity,
                      child: Text("Php${double.parse(data['product']['price'].toString()).toStringAsFixed(2)}",maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(
                          fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryColor
                      ),),
                    ),
                    data['selected_variations'] != null && data['selected_variations'].length > 0 ? Container(
                      width: double.infinity,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: double.infinity,
                            child: Text("Variations :",style: TextStyle(
                                fontSize: Theme.of(context).textTheme.bodyText1.fontSize
                            ),),
                          ),
                          for(var variation in data['selected_variations'])...{
                            Container(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  Container(
                                    width: Theme.of(context).textTheme.bodyText1.fontSize/2,
                                    height: Theme.of(context).textTheme.bodyText1.fontSize/2,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100),
                                        color: Colors.black
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text("${variation['details']['name']}"),
                                  ),
                                  Text(variation['details']['price'] == 0 ? "" : "+${variation['details']['price']}")
                                ],
                              ),
                            )
                          }
                        ],
                      ),
                    ) : Container()
                  ],
                ),
              ),
            ),
            Container(
              child: Text("${data['quantity']}x",style: TextStyle(
                  fontWeight: FontWeight.w600
              ),),
            )
          ],
        ),
        Divider(),
        Container(
          width: double.infinity,
          child: Text("Total : Php${priceChecker.calculateProductTotal(data)}"),
        )
      ],
    )
  );
  Widget myInfo() => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 20),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: <Widget>[
        locInfo(),
        Divider(),
        contactNumber(),
        Divider(),
        emailInfo(),
        brokenLiness()
      ],
    ),
  );

  Container emailInfo() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.email),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text("${user_details.email}",style: TextStyle(
              fontSize: Percentage().calculate(num: scrh, percent: scrw > 700 ? 2 : 2.2)
          ),maxLines: 1,overflow: TextOverflow.ellipsis,),
        ),
      ],
    ),
  );
  Container contactNumber() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.phone_in_talk),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text("$chosenNumber",style: TextStyle(
              fontSize: Percentage().calculate(num: scrh, percent: scrw > 700 ? 2 : 2.2)
          ),maxLines: 1,overflow: TextOverflow.ellipsis,),
        ),
        StreamBuilder<List<ContactNumber>>(
          stream: contactListner.stream,
          builder: (context, snapshot) => snapshot.hasData ? GestureDetector(
              onTap: () {
              showBottomsheet(buttons: [
                for(var button in snapshot.data)...{
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text("${button.number}"),
                    onTap: (){
                      Navigator.of(context).pop(null);
                      setState(() {
                        chosenNumber = button.number;
                      });
//                      useDeliveryAddress(data: forButton);
//                      Navigator.of(context).pop(null);
                    },
                  )
                }
              ],specialButton: false);
              },
                child: Text("Edit",style: TextStyle(
                    color: kPrimaryColor,
                    decoration: TextDecoration.underline
                ),),
            ) : Container()
        )
      ],
    ),
  );
  Container locInfo() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 25,
          height: 25,
          child: Image.asset("assets/images/location_icon.png"),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: Text("${StringFormatter(string: user_details.first_name).titlize()} ${StringFormatter(string: user_details.last_name).titlize()}",style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: Percentage().calculate(num: scrh, percent: scrw > 700 ? 2 : 2.2)
                  ),),
                ),
                Container(
                  width: double.infinity,
                  child: Text(_chosenLocation == null ? "Unspecified" : "${_chosenLocation['address']}",style: TextStyle(
                    fontSize: Percentage().calculate(num: scrh, percent: scrw > 700 ? 1.5 : 1.7)
                  ),),
                )
              ],
            ),
          ),
        ),
        StreamBuilder<List>(
          stream: myAddress.stream$,
          builder: (context, snapshot) => snapshot.hasData ?  GestureDetector(
            onTap: (){
              showBottomsheet(buttons: [
                for(var forButton in snapshot.data)...{
                  ListTile(
                    leading: Icon(Icons.location_city_rounded),
                    title: Text("${forButton['address']}"),
                    onTap: (){
                      useDeliveryAddress(data: forButton);
                      Navigator.of(context).pop(null);
                    },
                  )
                }
              ], specialButton: true);
            },
              child: Text("Edit",style: TextStyle(
                  color: kPrimaryColor,
                  decoration: TextDecoration.underline
              ),),
            ) : Container()
        )
      ],
    ),
  );
  Widget brokenLiness()=> Container(
    margin: const EdgeInsets.only(top: 40),
    width: double.infinity,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        for(var x =0; x< scrw~/40;x++)...{
//          x < scrw ~/50 ? Spacer() : Container(),
          Container(
            height: 7.0,
            width: 10,
            color: Colors.grey[400],
          ),
        }
      ],
    ),
  );
}
