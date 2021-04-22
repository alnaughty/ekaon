import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/interrupts.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/cart.dart';
import 'package:ekaon/services/discount.dart';
import 'package:ekaon/services/discount_collected_listener.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/pricer.dart';
import 'package:ekaon/services/slidable_service.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/home_page_children/checkout_page.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/ticket_clipper.dart';
import 'package:ekaon/views/home_page_children/new_cart_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
class NewCartPage extends StatefulWidget {
  @override
  _NewCartPageState createState() => _NewCartPageState();
}

class _NewCartPageState extends State<NewCartPage> {
  Map selectedOrder;
  bool _showVouchers = false;
  SlidableController _slidableController = new SlidableController();
  List vouchers;
  bool _isLoading = false;
  getVouchers(int storeId) async {
    setState(() {
      vouchers = null;
    });
    Discount().get(store_id: storeId).then((value) {
      if(value != null){
        setState(() {
          vouchers = value['data'];
        });
      }
    });
  }

  double getCartSubtotal() {
//    Map cartData = cartAuth.current[_selectedCartIndex];
    double result = 0.0;
    for(var total in selectedOrder['details'])
    {
      result += total['total'];
    }
    return result;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(cartAuth.current.length > 0){
      setState(() {
        selectedOrder = cartAuth.current[0];
      });
    }
  }
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
//  getDistance() async {
//    var dd = await distancer.getDifference(storeCoordinate: new Coordinates(selectedOrder['store']['latitude'], selectedOrder['store']['longitude']), chosenCoordinate: new Coordinates(_chosenLocation['latitude'], _chosenLocation['longitude']));
//    setState(() {
//      distance = double.parse(dd);
//    });
//  }
//  double getCharge(){
//    getDistance();
//    double _charge = distance * cartAuth.current[_selectedCartIndex]['store']['delivery_charge_per_km'];
//    return _charge;
//  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          key: _key,
          bottomSheet: _showVouchers ? BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2,sigmaY: 2),
            child: AnimatedContainer(
              width: double.infinity,
              duration: Duration(milliseconds: 600),
              height: Percentage().calculate(num: scrh,percent: vouchers != null ? vouchers.length == 0 ? 20 : 80 : 10),
              color: Colors.grey[300],
              child: vouchers == null ? Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                  ),
                ),
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
                          child: Text("Vouchers",style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                          ),),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => setState(() => _showVouchers = false),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: vouchers.length == 0 ? Center(
                      child: Text("No Available voucher for you."),
                    ) : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: <Widget>[
                        for(var voucher in vouchers)...{
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
                                                            color: kPrimaryColor,
                                                            borderRadius: BorderRadius.circular(5)
                                                        ),

                                                        child: FlatButton(
                                                          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                                          onPressed: () async {
                                                            if(user_details != null){
                                                              await Discount().collect(discountId: voucher['id']).then((value) {
                                                                if(value){
                                                                  discountCollected.append(voucher);
                                                                  setState(() {
                                                                    vouchers.remove(voucher);
                                                                  });
                                                                }
                                                              });
                                                            }
                                                          },
                                                          child: Text("Collect",style: TextStyle(
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
            ),
          ) : null,
          resizeToAvoidBottomPadding: Platform.isIOS,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(
              color: Colors.black
            ),
            title: Text("My cart",style: TextStyle(
              color: Colors.black
            ),),
            centerTitle: true,
            actions: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 10),
                child: Image.asset("assets/images/logo.png", width: 50,),
              )
            ],
          ),
          body: Container(
            width: double.infinity,
            color: Colors.grey[100],
            child: Column(
              children: <Widget>[
                Expanded(
                  child: StreamBuilder(
                    stream: cartAuth.stream$,
                    builder: (context, result) => !result.hasData ? Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),),
                    ) : result.data.length > 0 ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                      itemCount: result.data.length,
                      itemBuilder: (context, index) => Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[300],
                              blurRadius: 3,
                              offset: Offset(3,3)
                            )
                          ]
                        ),
                        child: Column(
                          children: [
                            FlatButton(
                              padding: const EdgeInsets.all(0),
                              onPressed: (){
                                if(selectedOrder != null && selectedOrder['store']['id'].toString() == result.data[index]["store"]['id'].toString()){
                                  setState(() => selectedOrder = null);
                                }else{
                                  setState(() => selectedOrder = result.data[index]);
                                }
                              },
                              child: Column(
                                children: <Widget>[
                                  Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                                      decoration: BoxDecoration(
                                          color: kPrimaryColor,
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(7))
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(selectedOrder != null && selectedOrder['store']['id'].toString() == result.data[index]["store"]['id'].toString() ? Icons.radio_button_checked : Icons.radio_button_unchecked,color: Colors.white,),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Container(
                                                width: double.infinity,
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Text("${StringFormatter(string: result.data[index]['store']['name']).titlize()}",style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                                                          fontWeight: FontWeight.w700
                                                      ),maxLines: 1, overflow: TextOverflow.ellipsis,),
                                                    ),
                                                    Container(
                                                      child: FlatButton(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                                                        onPressed: (){
                                                          setState(() {
                                                            _showVouchers = true;
                                                          });
                                                          getVouchers(int.parse(result.data[index]['store']['id'].toString()));
                                                        },
                                                        child: Center(
                                                          child: Text("Get vouchers",style: TextStyle(
                                                              color: Colors.white.withOpacity(0.9),
                                                            fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                                                          ),),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                            ),
                                          )
                                        ],
                                      )
                                  ),
                                  for(var products in result.data[index]['details'])...{
                                    Container(
                                      color: Colors.white,
                                      child: Slidable(
                                        controller: _slidableController,
                                        key: Key(products['id'].toString()),
                                        actionPane: SlidableService().getActionPane(result.data[index]['details'].indexOf(products)),
                                        secondaryActions: [
                                          IconSlideAction(
                                            iconWidget: Icon(Icons.visibility_sharp, color: Colors.white,),
                                            caption: "View",
                                            color: Colors.grey[900],
                                            onTap: (){
                                              showCartDetails(result.data[index]['id'],data: products,store_id: result.data[index]['store_id']);
                                            },
                                          ),
                                          IconSlideAction(
                                            iconWidget: Icon(Icons.remove,color: Colors.white,),
                                            caption: "Remove",
                                            color: kPrimaryColor,
                                            onTap: ()async {
                                              if(result.data[index]['details'].length > 1){
                                                await cartAuth.removeProduct(id: products['id'], storeId: products['product']['store_id']);

                                              }else{
                                                print("AS");
                                                //remove cart
                                                await cartAuth.removeCart(cartId: result.data[index]['id']);
                                                setState(() {
//                                      _selectedCartIndex = null;
                                                });
                                              }
                                            },
                                          ),

                                        ],
                                        child: ListTile(
                                          tileColor: Colors.white,
                                          title: Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.symmetric(vertical: 10),
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                  width: 60,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius: BorderRadius.circular(10),
                                                      image: DecorationImage(
                                                          image: products['product']['images'].length > 0 ? NetworkImage("https://ekaon.checkmy.dev${products['product']['images'][0]['url']}") : AssetImage("assets/images/no-image-available.png"),
                                                          fit: BoxFit.cover
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.grey[400],
                                                            offset: Offset(3,3)
                                                        )
                                                      ]
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
                                                          child: Text("${StringFormatter(string: products['product']['name']).titlize()}",style: TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                            fontSize: Theme.of(context).textTheme.subtitle1.fontSize
                                                          ),maxLines: 2, overflow: TextOverflow.ellipsis,),
                                                        ),
                                                        Container(
                                                          width: double.infinity,
                                                          child: Text("Php${priceChecker.calculateProductTotal(products).toStringAsFixed(2)}",style: TextStyle(
                                                              color: Colors.deepOrangeAccent,
                                                              fontSize: Theme.of(context).textTheme.subtitle1.fontSize - 2,
                                                              fontWeight: FontWeight.w400
                                                          ),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 90,
                                                  height: 40,
                                                  padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 0),
                                                  decoration: BoxDecoration(
                                                      color: kPrimaryColor,
                                                      borderRadius: BorderRadius.circular(5)
                                                  ),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Container(
                                                          child: FlatButton(
                                                            padding: const EdgeInsets.all(0),
                                                            onPressed: (){
                                                              if(products['quantity'] > 1){
                                                                setState(() {
                                                                  products['quantity']--;
                                                                  products['total'] = double.parse((double.parse(products['product']['price'].toString()) * products['quantity']).toString());
                                                                });
                                                              }
                                                            },
                                                            child: Center(
                                                              child: Icon(Icons.remove,size: 15,color: Colors.white,),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Text("${products['quantity']}",style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w600
                                                      ),),
                                                      Expanded(
                                                        child: Container(
                                                          child: FlatButton(
                                                            padding: const EdgeInsets.all(0),
                                                            onPressed: (){
                                                              setState(() {
                                                                products['quantity']++;
                                                                products['total'] = double.parse((double.parse(products['product']['price'].toString()) * products['quantity']).toString());
                                                              });
                                                            },
                                                            child: Center(
                                                              child: Icon(Icons.add,size: 15,color: Colors.white,),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  },
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                              child: Text("Additional price included (e.g. variations/add-ons price)",textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.grey[400]
                              ),),
                            ),
//                        Container(
//                          width: double.infinity,
//                          decoration: BoxDecoration(
//                            color: Colors.white,
//                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))
//                          ),
//                          alignment: AlignmentDirectional.center,
//                          child: FlatButton(
//                            onPressed: (){
//                              showCartDetails(data: result.data[index]);
////                              Navigator.push(_key.currentContext, PageTransition(child: CartDetailsPage(index: index, cartDetail: result.data[index]), type: PageTransitionType.downToUp));
//                            },
//                            child: Text("View Cart Details",style: TextStyle(
//                                fontWeight: FontWeight.w600,
//                                fontStyle: FontStyle.italic,
//                                color: kPrimaryColor,
//                                fontSize: Theme.of(context).textTheme.subtitle1.fontSize
//                            ),
//                          ),
//                        ))
                          ],
                        ),
                      ),
                    ) : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Image.asset("assets/images/empty_cart.png",),
                          ),
                          Text("Your cart is Empty",style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),)
                        ],
                      ),
                    ),
                  ),
                ),
                selectedOrder == null ? Container() : Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  padding: EdgeInsets.symmetric(horizontal: Percentage().calculate(num: scrw, percent: 10),vertical: Percentage().calculate(num: scrw, percent: 5)),
                  height: Percentage().calculate(num: scrh,percent: 13.5),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
//                      color: Colors.red,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                child: RichText(
                                  text: TextSpan(
                                    text: "Charge/km : ",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: Percentage().calculate(num: scrh, percent: scrw > 700 ? 1.3 : 1.6)
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "${selectedOrder == null ? "₱ 0.00" : double.parse(selectedOrder['store']['delivery_charge_per_km'].toString()) >= 1 ? "Php${double.parse(selectedOrder['store']['delivery_charge_per_km'].toString()).toStringAsFixed(2)}" : "Free"}",
                                        style: TextStyle(
                                          color: kPrimaryColor
                                        )
                                      )
                                    ]
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                child: RichText(
                                  text: TextSpan(
                                    text: "Subtotal : ",
                                    style: TextStyle(
                                      color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: Percentage().calculate(num: scrh, percent: scrw > 700 ? 1.6 : 1.9)
                                    ),
                                    children: [
                                      TextSpan(
                                          text: "₱ ${selectedOrder == null ? "0.00" : "${priceChecker.calculateSubtotal(data: selectedOrder)}"}",
                                          style: TextStyle(
                                              color: kPrimaryColor
                                          )
                                      )
                                    ]
                                  ),
                                )
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              color: selectedOrder == null ? Colors.grey[900] : kPrimaryColor,
                              borderRadius: BorderRadius.circular(7)
                            ),
                            child: FlatButton(
                              onPressed: selectedOrder == null ? null : (){
                                if(verType != 2){
                                  Fluttertoast.showToast(msg: "You are not a verified user, please verify", toastLength: Toast.LENGTH_LONG);
                                }else{
                                  Navigator.push(context, PageTransition(child: CheckoutPage(toCheckout: selectedOrder), type: PageTransitionType.leftToRightWithFade));
//                                  setState(() {
//                                    selectedOrder = null;
//                                  });
                                }
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7)
                              ),
                              child: Center(
                                child: Text("Checkout",style: TextStyle(
                                  color: Colors.white
                                ),),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        _isLoading ? MyWidgets().loader() : Container()
      ],
    );
  }

  showCartDetails(cart_id,{@required Map data, @required int store_id}) {
    print(data);
    PageController _pageController = new PageController(initialPage: 0);
    return showModalBottomSheet(
        context: _key.currentContext,
        builder: (context) => Container(
          height: Percentage().calculate(num: scrh,percent: 25) + (data['selected_variations'] != null && data['selected_variations'].length != 0 ? 150 : 0),
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 60,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[200],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300],
                        offset: Offset(3,3),
                        blurRadius: 3
                      )
                    ],
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: data['product']['images'].length == 0 ? AssetImage("assets/images/no-image-available.png") : NetworkImage("https://ekaon.checkmy.dev${data['product']['images'][0]['url']}")
                    )
                  ),
                ),
                title: Text("${StringFormatter(string: data['product']['name']).titlize()}"),
                subtitle: RichText(
                  text: TextSpan(
                    text: "Original price : ",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Php${double.parse(data['product']['price'].toString()).toStringAsFixed(2)}",
                        style: TextStyle(
                          color: kPrimaryColor
                        )
                      )
                    ]
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text("Quantity :",style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyText1.fontSize
                      ),),
                    ),
                    Text("${data['quantity']}")
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text("Subtotal :",style: TextStyle(
                          fontSize: Theme.of(context).textTheme.bodyText1.fontSize
                      ),),
                    ),
                    Text("Php${priceChecker.calculateProductTotal(data).toStringAsFixed(2)}")
                  ],
                ),
              ),
              if(data['selected_variations'] != null && data['selected_variations'].length != 0)...{
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Text("Variations :",style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodyText1.fontSize
                  ),),
                ),
                Container(
                  width: double.infinity,
                  height: 100,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                  ),
                  child: PageView(
                    children: [
                      for(var variation in data['product']['variations'])...{
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Text("${variation['variation']['name']}",style: TextStyle(
                                fontWeight: FontWeight.w600
                              ),),
                            ),
                            Expanded(
                              child: Container(
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    for(var sub_variation in variation['variation']['details'])...{
                                      GestureDetector(
                                        onTap: sub_variation['id'] == data['selected_variations'][data['product']['variations'].indexOf(variation)]['details']['id'] ? null : (){
                                          Navigator.of(context).pop(null);
                                          List vars = [];
                                          for(var selection in data['selected_variations']){
                                            vars.add(selection['details']['id']);
                                          }
                                          int _index = data['product']['variations'].indexOf(variation);

                                          String foo_var_first = vars.join(',');
                                          vars[_index] = sub_variation['id'];
                                          String foo_var = vars.join(',');
                                          print("NEW : $foo_var");
                                          print("OLD : $foo_var_first");

                                          if(cartAuth.checkIfProductExists(
                                              productIds: data['product']['id'],
                                              variation_ids: vars.length == 0 ? null : foo_var,
                                              data: cartAuth.current.where((element) => element['store_id'] == store_id).toList()[0])){
                                            //if exists show interrupt confirmation
                                            Interrupts().showCartProductConfirmation(context, onYes: (){
                                              Navigator.of(_key.currentContext).pop(null);
                                              cartAuth.exist(
                                                  cart_id: cart_id,
                                                  quantity: data['quantity'],
                                                  indexToDelete: cartAuth.getIndexOf(
                                                      productId: data['product']['id'],
                                                    variation_ids: vars.length == 0 ? null : foo_var_first,
                                                    data: cartAuth.current.where((element) => element['store_id'] == store_id).toList()[0]
                                                  ),
                                                indexToUpdate: cartAuth.getIndexOf(
                                                    productId: data['product']['id'],
                                                    variation_ids: vars.length == 0 ? null : foo_var,
                                                    data: cartAuth.current.where((element) => element['store_id'] == store_id).toList()[0]
                                                ),
                                              ).whenComplete(() => setState(() => _isLoading = false));
                                              //add old to new
                                            });
                                          }else{
                                            setState(() {
                                              data['selected_variations'][data['product']['variations'].indexOf(variation)]['details'] = sub_variation;
                                            });
                                          }
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 20),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: sub_variation['id'] == data['selected_variations'][data['product']['variations'].indexOf(variation)]['details']['id'] ? kPrimaryColor : Colors.grey[200]
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("${sub_variation['name']}",style: TextStyle(
                                                color: sub_variation['id'] == data['selected_variations'][data['product']['variations'].indexOf(variation)]['details']['id'] ? Colors.white : Colors.black54
                                              ),),
                                              Text(sub_variation['price'] == 0 ? "Free" : "Php${double.parse(sub_variation['price'].toString()).toStringAsFixed(2)}",style: TextStyle(
                                                  color: sub_variation['id'] == data['selected_variations'][data['product']['variations'].indexOf(variation)]['details']['id'] ? Colors.white : Colors.black54
                                              ),)
                                            ],
                                          ),
                                        ),
                                      )
                                    }
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      }
                    ],
                  )
                )
              }
            ],
          ),
        )
    );
  }
}
