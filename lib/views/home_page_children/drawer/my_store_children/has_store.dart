import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/interrupts.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/distancer.dart';
import 'package:ekaon/services/location_picker.dart';
import 'package:ekaon/services/my_product_listener.dart';
import 'package:ekaon/services/order_notifier.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/products.dart';
import 'package:ekaon/services/slidable_service.dart';
import 'package:ekaon/services/store.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/add_product_image.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/categories.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/add_product.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/crud_featured_photo.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/discount_page.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/edit_product.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/inventory_page.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/scheduling_page.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/social_media_share.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/orders.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/update_store_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share/share.dart';

class MyStoreViewPage extends StatefulWidget {
//  void showTextField(BuildContext context){
//    context.findAncestorStateOfType<_MyStoreViewPageState>().popUpTextField();
//  }
  @override
  _MyStoreViewPageState createState() => _MyStoreViewPageState();
}

class _MyStoreViewPageState extends State<MyStoreViewPage> {
  SlidableController _slidableController = new SlidableController();
  ProductAuth _productAuth = new ProductAuth();
  ScrollController _scrollController = new ScrollController();
  TextEditingController _productName = new TextEditingController();
  TextEditingController _productDescription = new TextEditingController();
  TextEditingController _price = new TextEditingController();
  var selectedMealType = "No";
  Store store = new Store();
  bool _isLoading = false;
  bool _showScrollable = true;
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  _getMyStore() async {
    var dd = await store.getMyStore();
    if (dd != null) {
      setState(() {
        myStoreDetails = dd;
      });
    }
    if(myProductListener.current.length == 0)
    {
      await _getMyProducts();
    }
    print("Store: $myStoreDetails");
  }

  _getMyProducts() async {
    var dd = await store.getProducts(storeId: myStoreDetails['id']);
    if(dd != null){
      myProductListener.update(newData: dd);
    }
  }
  bool _updatingDeliveryState = false;
  bool _updatingStoreState = false;
  checker() async {
    if(myStoreDetails==null){
      await _getMyStore();
    }

  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  void initState() {
    // TODO: implement initState
    super.initState();
    checker();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Stack(
      children: <Widget>[
        Scaffold(
          resizeToAvoidBottomPadding: Platform.isIOS,
          key: _key,
          body: OrientationBuilder(
            builder: (context, orientation) => SafeArea(
              child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: myStoreDetails == null ? Center(
                    child: Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),),
                    ),
                  ) : Scrollbar(
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: <Widget>[
                        SliverAppBar(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          actions: <Widget>[
                            IconButton(
                              icon: Container(
                                width: 25,
                                height: 25,
                                child: Center(
                                  child: Image.asset("assets/images/edit_image.png",color: kPrimaryColor,),
                                ),
                              ),
                              onPressed: () => Navigator.push(context, PageTransition(child: StorePictureUpdate())),
                            )
                          ],
                          pinned: false,
                          snap: false,
                          floating: true,
                        expandedHeight: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: orientation == Orientation.portrait ? 40 : 70),
                          flexibleSpace: FlexibleSpaceBar(
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                image: DecorationImage(
                                  image: myStoreDetails['picture'] == null ? AssetImage("assets/images/default_store.png") : NetworkImage("https://ekaon.checkmy.dev${myStoreDetails['picture']}"),
                                  fit: BoxFit.cover
                                )
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                            delegate: SliverChildListDelegate([
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                width: double.infinity,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: title(label: "${myStoreDetails['name']}".toUpperCase()),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: kPrimaryColor,),
                                      onPressed: ()=>edit("Store name", TextInputType.text, "name"),
                                    )
                                  ],
                                )
                              ),
                              Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                  width: double.infinity,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text("${myStoreDetails['address']}",style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: scrw > 700 ? scrw / 35 : scrw / 25,
                                            fontWeight: FontWeight.w400,
                                            decoration: TextDecoration.underline)),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit, color: kPrimaryColor,),
                                        onPressed: () async {
                                          try{
                                            LocationResult data = await locationPicker.update(context);
                                            if(data != null){
                                              if(data.address == null) {
                                                var dd = await distancer.geoTranslate(latitude: data.latLng.latitude, longitude: data.latLng.longitude);
                                                setState(() {
                                                  myStoreDetails['address'] = dd;
                                                  myStoreDetails['latitude'] = data.latLng.latitude;
                                                  myStoreDetails['longitude'] = data.latLng.longitude;
                                                });
                                              }else{
                                                setState(() {
                                                  myStoreDetails['address'] = data.address;
                                                  myStoreDetails['latitude'] = data.latLng.latitude;
                                                  myStoreDetails['longitude'] = data.latLng.longitude;
                                                });
                                              }
                                              store.update(true, myStoreDetails['address'], myStoreDetails['latitude'], myStoreDetails['longitude'], "", "", myStoreDetails['id']);
                                            }
                                          }catch(e){
                                            Fluttertoast.showToast(msg: "Please enable location permission");
                                          }
                                        },
                                      )
                                    ],
                                  )
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                width: double.infinity,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text("Store is ${myStoreDetails['storeOpen'] == 1 ? "Open" : "Closed"}",style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15.5
                                      ),),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        setState(() {
                                          if(myStoreDetails['storeOpen'] == 1){
                                            myStoreDetails['storeOpen'] = 0;
                                          }else{
                                            myStoreDetails['storeOpen'] = 1;
                                          }
                                        });
                                        if(!_updatingStoreState){
                                          setState(() {
                                            _updatingStoreState = true;
                                          });
                                          await Store().updateStoreState().whenComplete(() {
                                            setState(() {
                                              _updatingStoreState = false;
                                            });
                                          });
                                        }
                                      },
                                      icon: Container(
                                        width: 35,
                                        height: 35,
                                        child: Image.asset("assets/images/${myStoreDetails['storeOpen'] == 1 ? "enable" : "disable"}.png",color: myStoreDetails['storeOpen'] == 1 ? kPrimaryColor : Colors.grey,),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                width: double.infinity,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text("Delivery is ${myStoreDetails['hasDelivery'] == 1 ? "enabled" : "disabled"}",style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                        fontSize: Theme.of(context).textTheme.subtitle1.fontSize
                                      ),),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        setState(() {
                                          if(myStoreDetails['hasDelivery'] == 1){
                                            myStoreDetails['hasDelivery'] = 0;
                                          }else{
                                            myStoreDetails['hasDelivery'] = 1;
                                          }
                                        });
                                        if(!_updatingDeliveryState){
                                          setState(() {
                                            _updatingDeliveryState = true;
                                          });
                                          await Store().updateDeliveryState().whenComplete(() {
                                            setState(() {
                                              _updatingDeliveryState = false;
                                            });
                                          });
                                        }
                                      },
                                      icon: Container(
                                        width: 35,
                                        height: 35,
                                        child: Image.asset("assets/images/${myStoreDetails['hasDelivery'] == 1 ? "enable" : "disable"}.png",color: myStoreDetails['hasDelivery'] == 1 ? kPrimaryColor : Colors.grey,),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              myStoreDetails['delivery_charge_per_km'] != null &&  myStoreDetails['delivery_charge_per_km'] != 0 && myStoreDetails['hasDelivery'] != 0 ? Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                width: scrw,
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  children: <Widget>[
//                                Icon(FontAwesomeIcons.moneyBill,
//                                    color: kPrimaryColor, size: srcrw > 700 ? scrw / 25 : scrw / 15),
                                    Expanded(
                                      child: Row(
                                        children: <Widget>[
                                          Text("Delivery charge : ",style: TextStyle(
                                            fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black54
                                          ),),
                                          Text("₱",style: TextStyle(
                                            color: Colors.orange,
                                            fontSize: scrw > 700 ? scrw / 35 : scrw / 25,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w600,)),
                                          Expanded(
                                            child: Text(" ${double.parse(myStoreDetails['delivery_charge_per_km'].toString()).toStringAsFixed(2)}",style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: scrw > 700 ? scrw / 35 : scrw / 25,
                                              fontWeight: FontWeight.w600,)),
                                          )
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: (){
                                        edit("Delivery charge", TextInputType.numberWithOptions(signed: true), "delivery_charge_per_km");
                                      },
                                      icon: Icon(Icons.edit, color: kPrimaryColor,),
                                    )
                                  ],
                                ),
                              ) : Container(),

                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          text: "Standard Delivery Time",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600,
                                              fontSize: 15.5
                                          ),
                                          children: [
                                            TextSpan(
                                              text: "\n${myStoreDetails['standard_delivery_time'] == null ? "Unspecified" : "${myStoreDetails['standard_delivery_time']} minute(s) from customer's current time"}",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500
                                              )
                                            )
                                          ]
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: (){
                                        edit("Standard Delivery Time", TextInputType.number, "standard_delivery_time",
                                            subtitle: "Standard delivery time is in minutes, we will accept and show your input in minutes.");
                                      },
                                      icon: Icon(Icons.edit, color: kPrimaryColor,),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 60,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    border: Border(top: BorderSide(color: Colors.grey[300].withOpacity(0.5)))
                                ),
                                child: FlatButton(
                                  onPressed: () async {
                                    Navigator.push(context, PageTransition(child: CudFeaturedPhoto()));
                                  },
                                  child: Row(
//                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        width: 25,
                                        height: 25,
                                        child: Center(
                                          child: Image.asset("assets/images/featured_photo.png"),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text("Featured photo",style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600
                                      ),),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 60,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    border: Border(top: BorderSide(color: Colors.grey[300].withOpacity(0.5)))
                                ),
                                child: FlatButton(
                                  onPressed: () async {
                                    Navigator.push(context, PageTransition(child: SchedulePage(),type: PageTransitionType.leftToRightWithFade));
                                  },
                                  child: Row(
//                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
//                                      Container(
//                                        width: 25,
//                                        height: 25,
//                                        child: Center(
//                                          child: Image.asset("assets/images/featured_photo.png"),
//                                        ),
//                                      ),
                                      Icon(Icons.schedule,color: Colors.amber,),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text("Schedule",style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600
                                      ),),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 60,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                    border: Border(top: BorderSide(color: Colors.grey[300].withOpacity(0.5)))
                                ),
                                child: FlatButton(
                                  onPressed: () async {
                                    Navigator.push(context, PageTransition(child: SharePage(), type: null));
//                                    await Share.share("TEST", subject: "TEST DESC");
                                  },
                                  child: Row(
//                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        width: 25,
                                        height: 25,
                                        child: Center(
                                          child: Image.asset("assets/images/share.png",color: Colors.blue,),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text("Share my store on",style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600
                                      ),),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                height: 60,
                                decoration: BoxDecoration(
                                  border: Border.symmetric(vertical: BorderSide(color: Colors.grey[300].withOpacity(0.5)))
                                ),
                                child: FlatButton(
                                  onPressed: (){
                                    setState(() => hasNewOrder = false);
                                    Navigator.push(context, PageTransition(child: StoreOrders()));
                                  },
                                  child: Row(
//                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        width: 25,
                                        height: 25,
                                        child: Center(
                                          child: Image.asset("assets/images/food_order.png",color: kPrimaryColor,),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text("Orders",style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600
                                      ),),
                                      const Spacer(),
                                      Container(
                                        child: StreamBuilder(
                                          stream: storeOrderNotifierListener.stream$,
                                          builder: (context,result) => result.hasData ? result.data == 0 ? Container() : Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.circular(10000)
                                            ),
                                            child: Text("${result.data}",style: TextStyle(
                                                color: Colors.white
                                            ),),
                                          ) : Container(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,

                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                height: 60,
                                decoration: BoxDecoration(
                                    border: Border.symmetric(vertical: BorderSide(color: Colors.grey[300].withOpacity(0.5)))
                                ),
                                child: FlatButton(
                                  onPressed: (){
                                    Navigator.push(context, PageTransition(child: InventoryPage()));
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: 25,
                                        height: 25,
                                        child: Center(
                                          child: Image.asset("assets/images/inventory.png",color: Colors.orange,),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Text("Sales Statistics",style: TextStyle(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600
                                        ),),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                height: 60,
                                decoration: BoxDecoration(
                                    border: Border.symmetric(vertical: BorderSide(color: Colors.grey[300].withOpacity(0.5)))
                                ),
                                child: FlatButton(
                                  onPressed: (){
                                    Navigator.push(context, PageTransition(child: DiscountPage()));
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: 25,
                                        height: 25,
                                        child: Center(
                                          child: Image.asset("assets/images/discount.png",color: Colors.green,),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Text("Discounts",style: TextStyle(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600
                                        ),),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                width: double.infinity,
                                height: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: orientation == Orientation.portrait ? 9 : 13),
                                child: MyWidgets().button(pressed: (){
                                  Navigator.push(context, PageTransition(child: AddProduct(), type: PageTransitionType.downToUp));
//                                  popUpTextField();
//                                  if(_showScrollable){
//                                    setState(() {
//                                      _showScrollable = false;
//                                    });
//                                  }
                                }, child: Text("Add new product",style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: scrw > 700 ? scrw/35 : scrw/25
                                ),),color: kPrimaryColor),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              StreamBuilder<List>(
                                stream: myProductListener.$stream,
                                builder: (context, result) {
                                  if(result.hasData){
                                    return Column(
                                      children: <Widget>[
                                        for(var x = 0;x < result.data.length;x++)...{
                                          Slidable(
                                            closeOnScroll: true,
                                            controller: _slidableController,
                                            key: Key(x.toString()),
                                            actionPane: SlidableService().getActionPane(x),
                                            child: Container(
                                              width: double.infinity,
                                              height: 100,
                                              child: FlatButton(
                                                color: Colors.grey[100].withOpacity(0.5),
                                                onPressed: (){
                                                  Navigator.push(context, PageTransition(child: EditProduct(productData: result.data[x])));
                                                },
                                                child: Row(
                                                  children: <Widget>[
                                                    //Image
                                                    Container(
                                                      width: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: orientation == Orientation.portrait ? 10 : 20),
                                                      height: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: orientation == Orientation.portrait ? 10 : 20),
                                                      decoration: BoxDecoration(
                                                          color: Colors.grey[300],
                                                          borderRadius: BorderRadius.circular(10000),
                                                          boxShadow: [
                                                            BoxShadow(
                                                                color: Colors.grey[400],
                                                                offset: Offset(3,3),
                                                                blurRadius: 2
                                                            )
                                                          ],
                                                          image: DecorationImage(
                                                              image: result.data[x]['images'].length > 0 ? NetworkImage("https://ekaon.checkmy.dev/${result.data[x]['images'][0]['url']}") : AssetImage("assets/images/no-image-available.png"),
                                                              fit: BoxFit.cover,
                                                              alignment: AlignmentDirectional.center
                                                          )
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        margin: const EdgeInsets.only(left: 10),
                                                        padding: const EdgeInsets.all(10),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: <Widget>[
                                                            Container(
                                                              width: double.infinity,
                                                              child: Text("${result.data[x]['name']}",style: TextStyle(
                                                                  color: Colors.black54,
                                                                  fontSize: 20,
                                                                  fontWeight: FontWeight.w600
                                                              ),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                                            ),
                                                            Container(
                                                              width: double.infinity,
                                                              child: Text("${result.data[x]['description']}",style: TextStyle(
                                                                  color: Colors.black54,
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.w400
                                                              ),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                                            ),
                                                            Container(
                                                              width: double.infinity,
                                                              child: Text("₱ ${double.parse(result.data[x]['price'].toString()).toStringAsFixed(2)}", style: TextStyle(
                                                                  color: Colors.orangeAccent
                                                              ),),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    result.data[x]['is_meal'] > 0 ? Container(
                                                      width: 25,
                                                      height: 25,
                                                      child: Center(
                                                        child: Image.asset("assets/images/meal.png", color: kPrimaryColor,),
                                                      ),
                                                    ) : Container()
                                                  ],
                                                ),
                                              ),
                                            ),
                                            secondaryActions: [
                                              IconSlideAction(
                                                iconWidget: Icon(Icons.delete,color: Colors.white,),
                                                color: kPrimaryColor,
                                                onTap: (){
                                                  Interrupts().showProductDeletion(context, "${StringFormatter(string: result.data[x]['name']).titlize()}", "TEST", (){
                                                    Navigator.of(context).pop(null);
                                                    setState(() {
                                                      _isLoading = true;
                                                    });
                                                    _productAuth.deleteProduct(productId: int.parse(result.data[x]['id'].toString())).whenComplete(() => setState(()=> _isLoading = false));
                                                  });
                                                },
                                              )
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          )
                                        }
                                      ],
                                    );
                                  }else{
                                    return Center(
                                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),),
                                    );
                                  }
                                },
                              )
                            ]))
                      ],
                    ),
                  )
              ),
            ),
          )
        ),
        _isLoading ? MyWidgets().loader() : Container()
      ],
    );
  }

  Text title({String label})
  {
    return Text("$label",style: TextStyle(
      color: kPrimaryColor,
      fontSize: 22,
      fontWeight: FontWeight.w700
    ),);
  }
  edit(label, TextInputType inputType, name,{String subtitle}) {
    TextEditingController dd = new TextEditingController();
    return showGeneralDialog(
//        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            alignment: AlignmentDirectional.topCenter,
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaY: 4,sigmaX: 4),
                child: Container(
                  color: Colors.black54,
                  width: scrw,
                  height: scrh,
                  alignment: AlignmentDirectional.topCenter,
                  child: Container(
                    width: scrw,
                    height: Percentage().calculate(num: scrh, percent: 30),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        color: Colors.white),
                    child: Material(
                      color: Colors.transparent,
                      child: ListView(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: scrh / 30),
                            width: scrw,
                            child: Theme(
                              data: ThemeData(
                                primaryColor: kPrimaryColor
                              ),
                              child: TextField(
                                controller: dd,
                                maxLines: null,
                                keyboardType: inputType,
//                            controller: _productName,
                                autofocus: true,
                                style: TextStyle(color: kPrimaryColor),
                                cursorColor: kPrimaryColor,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: kPrimaryColor)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: kPrimaryColor)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide:
                                        BorderSide(color: kPrimaryColor)),
                                    labelText: label,
                                    labelStyle: TextStyle(color: kPrimaryColor)),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          subtitle != null ? Container(
                            width: double.infinity,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.warning,color: Colors.amber,),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text("$subtitle",style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600
                                  ),),
                                )
                              ],
                            ),
                          ) : Container(),
                          SizedBox(
                            height: scrh / 30,
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: scrh / 40),
                            width: scrw,
                            height: scrh > 700 ? scrh / 15 : scrh / 12,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child: RaisedButton(
                                      color: kPrimaryColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5)),
                                      onPressed: () {
                                        Navigator.of(context).pop(null);
                                      },
                                      child: Center(
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: scrw > 700
                                                  ? scrw / 35
                                                  : scrw / 25),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: scrw / 50,
                                ),
                                Expanded(
                                  child: Container(
                                    child: RaisedButton(
                                      color: Colors.green,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5)),
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        if (dd.text.isNotEmpty) {
                                          Navigator.of(context).pop(null);
                                          setState(() {
                                            myStoreDetails['$name'] = dd.text;
                                          });
//                                          if(name == "name"){
//                                            setState(() {
//                                              myStoreDetails['name'] = dd.text;
//                                            });
//                                          }else if(name == "standard_delivery_time"){
//                                            setState(() {
//                                              myStoreDetails['name'] = dd.text;
//                                            });
//
//                                          }else{
//                                            setState(() {
//                                              myStoreDetails['delivery_charge_per_km'] = dd.text;
//                                            });
//                                          }
                                          store.update(false, "", "", "", "$name", "${dd.text}", myStoreDetails['id'].toString());
                                        }else{
                                          Fluttertoast.showToast(msg: "Please fill the field");
                                        }
                                      },
                                      child: Center(
                                        child: Text(
                                          "Submit",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: scrw > 700
                                                  ? scrw / 35
                                                  : scrw / 25),
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
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
  }
//  popUpTextField() {
//    List<String> isMeal = ["Yes", "No"];
//    return showGeneralDialog(
////        barrierColor: Colors.black.withOpacity(0.5),
//        transitionBuilder: (context, a1, a2, widget) {
//          final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
//          return Transform(
//            alignment: AlignmentDirectional.topCenter,
//            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
//            child: GestureDetector(
//              onTap: (){
//                FocusScope.of(context).unfocus();
//              },
//              child: GestureDetector(
//                onTap: ()=>Navigator.of(context).pop(null),
//                child: BackdropFilter(
//                  filter: ImageFilter.blur(sigmaX: 4,sigmaY: 4),
//                  child: Container(
//                    width: double.infinity,
//                    height: double.infinity,
//                    color: Colors.black54,
//                    alignment: AlignmentDirectional.topCenter,
//                    child: Container(
//                      width: double.infinity,
//                      height: scrh/2.1,
//                      padding: EdgeInsets.symmetric(horizontal: 20),
//                      decoration: BoxDecoration(
//                          color: Colors.white
//                      ),
//                      child: Material(
//                        color: Colors.transparent,
//                        child: ListView(
//                          children: <Widget>[
//                            Container(
//                              width: double.infinity,
//                              child: Row(
//                                children: <Widget>[
//                                  Icon(Icons.info_outline,color: Colors.amber[700],),
//                                  const SizedBox(
//                                    width: 10,
//                                  ),
//                                  Expanded(
//                                    child: Text("Some fields might not be visible, scroll down to view",style: TextStyle(
//                                      fontWeight: FontWeight.bold,
//                                      color: Colors.black54
//                                    ),),
//                                  )
//                                ],
//                              ),
//                            ),
//                            const SizedBox(
//                              height: 10,
//                            ),
//                            MyWidgets().customTextField(label: 'Product name', color: Colors.grey[900],controller: _productName),
//                            const SizedBox(
//                              height: 10,
//                            ),
//                            MyWidgets().customTextField(label: 'Product description', color: Colors.grey[900],controller: _productDescription,type: TextInputType.multiline,),
//                            const SizedBox(
//                              height: 10,
//                            ),
//                            MyWidgets().customTextField(label: 'Price', color: Colors.grey[900],controller: _price, type: TextInputType.number),
//                            const SizedBox(
//                              height: 10,
//                            ),
////                        Container(
////                          margin: EdgeInsets.only(top: scrh/60),
////                          width: double.infinity,
////                          child: TextField(
////                            controller: _price,
////                            keyboardType: TextInputType.number,
////                            autofocus: true,
////                            style: TextStyle(
////                                color: Colors.white
////                            ),
////                            cursorColor: Colors.white,
////                            decoration: InputDecoration(
////                                border: OutlineInputBorder(
////                                    borderSide: BorderSide(color: Colors.white)
////                                ),
////                                focusedBorder: OutlineInputBorder(
////                                    borderSide: BorderSide(color: Colors.white)
////                                ),
////                                enabledBorder: OutlineInputBorder(
////                                    borderSide: BorderSide(color: Colors.white)
////                                ),
////                                labelText: "Product Price",
////                                labelStyle: TextStyle(
////                                    color: Colors.white
////                                )
////                            ),
////                          ),
////                        ),
//                            Container(
//                              margin: EdgeInsets.only(top: scrh/60),
//                              width: double.infinity,
//                              child: Text("Is this a meal?",style: TextStyle(
//                                color: Colors.black54,
//                                fontSize: 17
//                              ),),
//                            ),
//                            Container(
//                              decoration: BoxDecoration(
//                                border: Border.all(color: Colors.black54),
//                                borderRadius: BorderRadius.circular(5)
//                              ),
//                              padding: EdgeInsets.symmetric(horizontal: 20),
//                              width: double.infinity,
//                              child: DropdownButtonHideUnderline(child: DropdownButton(
//                                isExpanded: true,
//                                iconEnabledColor: Colors.black54,
//                                dropdownColor: Colors.white,
//                                items: isMeal.map((e) => DropdownMenuItem(child: Text("$e",style: TextStyle(
//                                  color: Colors.black
//                                ),),value: e,)).toList(),
//                                value: selectedMealType,
//                                onChanged: (e){
//                                  print(e);
//                                  setState(() {
//                                    selectedMealType = e;
//                                  });
//                                },
//                              )),
//                            ),
//                            Container(
//                              margin: EdgeInsets.only(top: scrh/60),
//                              decoration: BoxDecoration(
//                                  border: Border.all(color: Colors.black54),
//                                  borderRadius: BorderRadius.circular(5)
//                              ),
//                              width: double.infinity,
//                              height: 60,
//                              padding: const EdgeInsets.symmetric(vertical: 6),
//                              child: FlatButton(
//                                onPressed: (){
//                                  Navigator.of(context).pop(null);
//                                  Navigator.push(context, PageTransition(child: CategoriesPage(parentContext: _key.currentContext,),type: PageTransitionType.downToUp));
//                                },
//                                child: chosenCatsNames.length > 0 ? ListView(
//                                  scrollDirection: Axis.horizontal,
//                                  children: <Widget>[
//                                    for(var x in chosenCatsNames)...{
//                                      Container(
//                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//                                        margin : const EdgeInsets.only(right: 10),
//                                        decoration: BoxDecoration(
//                                            border: Border.all(color: Colors.black54,width: 2),
//                                            borderRadius: BorderRadius.circular(5)
//                                        ),
//                                        child: Center(
//                                          child: Text("$x",style: TextStyle(
//                                              color: Colors.black54
//                                          ),),
//                                        ),
//                                      ),
//                                    }
//                                  ],
//                                ) : Text("Choose categories",style: TextStyle(
//                                    color: Colors.black54
//                                ),),
//                              ),
//                            ),
//                            SizedBox(
//                              height: scrh/30,
//                            ),
//                            Container(
//                              margin: EdgeInsets.only(bottom: scrh/40),
//                              width: scrw,
//                              height: scrh > 700 ? scrh/15 : scrh/12,
//                              child: Row(
//                                children: <Widget>[
//                                  Expanded(
//                                    child: Container(
//                                      child: RaisedButton(
//                                        color: kPrimaryColor,
//                                        shape: RoundedRectangleBorder(
//                                            borderRadius: BorderRadius.circular(5)
//                                        ),
//                                        onPressed: (){
//                                          Navigator.of(context).pop(null);
//                                          _productName.clear();
//                                          _productDescription.clear();
//                                          _price.clear();
//                                        },
//                                        child: Center(
//                                          child: Text("Cancel",style: TextStyle(
//                                              color: Colors.white,
//                                              fontSize: scrw > 700 ? scrw/35 : scrw/25
//                                          ),),
//                                        ),
//                                      ),
//                                    ),
//                                  ),
//                                  SizedBox(
//                                    width: scrw/50,
//                                  ),
//                                  Expanded(
//                                    child: Container(
//                                      child: RaisedButton(
//                                        color: Colors.grey[900],
//                                        shape: RoundedRectangleBorder(
//                                            borderRadius: BorderRadius.circular(5)
//                                        ),
//                                        onPressed: (){
//                                          FocusScope.of(context).unfocus();
//                                          if(_productName.text.isNotEmpty && _productDescription.text.isNotEmpty && _price.text.isNotEmpty && chosenCatsIds.length > 0){
//                                            String stringsCatIds = chosenCatsIds.toString().replaceAll("[", '').replaceAll("]", "");
//                                            if(_price.text != "0"){
//
//                                              Navigator.of(context).pop(null);
//                                              setState(() {
//                                                _isLoading = true;
//                                              });
//                                              _productAuth.add(myStoreDetails['id'], _productName.text, _productDescription.text, _price.text, stringsCatIds,selectedMealType).then((value) async {
//                                                if(value != null){
//                                                  _price.clear();
//                                                  _productName.clear();
//                                                  _productDescription.clear();
//                                                  chosenCatsIds.clear();
//                                                  chosenCatsNames.clear();
//                                                  setState(() {
//                                                    selectedMealType = "No";
//                                                  });
//                                                  Navigator.pushReplacement(_key.currentContext, PageTransition(child: UploadProductImage(data: value, isInit: true,)));
//                                                }
//                                              }).whenComplete(() => setState(()=> _isLoading = false));
//                                            }else{
//                                              Fluttertoast.showToast(msg: "You can't add a free product");
//                                            }
//                                          }else{
//                                            Fluttertoast.showToast(msg: "Please dont leave a field empty");
//                                          }
//                                        },
//                                        child: Center(
//                                          child: Text("Submit",style: TextStyle(
//                                              color: Colors.white,
//                                              fontSize: scrw > 700 ? scrw/35 : scrw/25
//                                          ),),
//                                        ),
//                                      ),
//                                    ),
//                                  )
//                                ],
//                              ),
//                            )
//                          ],
//                        ),
//                      ),
//                    ),
//                  ),
//                ),
//              ),
//            ),
//          );
//        },
//        transitionDuration: Duration(milliseconds: 200),
//        barrierDismissible: true,
//        barrierLabel: '',
//        context: context,
//        pageBuilder: (context, animation1, animation2) {});
//  }
}
