import 'dart:convert';
import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/distancer_service.dart';
import 'package:ekaon/services/my_rated_stores_listener.dart';
import 'package:ekaon/services/order.dart';
import 'package:ekaon/services/order_listener.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/store_orders_listener.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/services/your_rated_products_listener.dart';
import 'package:ekaon/views/home_page_children/compose_message.dart';
import 'package:ekaon/views/home_page_children/drawer/transaction_children/rate_product.dart';
import 'package:ekaon/views/home_page_children/drawer/transaction_children/service.dart';
import 'package:ekaon/views/home_page_children/not_navbar/store_details.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
//import 'package:pusher/pusher.dart';
//import 'package:pusher_websocket_flutter/pusher.dart' as listener;

class OrderDetailsWithTracker extends StatefulWidget {
  final int orderId;
  OrderDetailsWithTracker({Key key, @required this.orderId}) : super(key : key);

  @override
  _OrderDetailsWithTrackerState createState() => _OrderDetailsWithTrackerState();
}

class _OrderDetailsWithTrackerState extends State<OrderDetailsWithTracker> {
//  double total = 0.0;
  var state;
//  int data['status'] = 0;
  List deliveryTrack = [
    {
      "name" : "Pending",
      "status" : 0,
      "image" : "assets/images/pending.png"
    },
    {
      "name" : "Preparing",
      "status" : 1,
      "image" : 'assets/images/preparing.png'
    },
    {
      "name" : "On delivery",
      "status" : 2,
      "image" : 'assets/images/food_delivering.png'
    },
    {
      "name" : "Complete",
      "status" : 3,
      "image" : "assets/images/payment_success.png"
    }
  ];
  List pickUpTrack = [
    {
      "name" : "Pending",
      "status" : 0,
      "image" : "assets/images/pending.png"
    },
    {
      "name" : "Preparing",
      "status" : 1,
      "image" : 'assets/images/preparing.png'
    },
    {
      "name" : "Waiting",
      "status" : 2,
      "image" : 'assets/images/food_ready.png'
    },
    {
      "name" : "Complete",
      "status" : 3,
      "image" : "assets/images/payment_success.png"
    }
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(this.mounted){
      getState();
      setState(() {
        isAtOrderDetails = true;
      });
    }
  }

  getState() async {
    var dd = await Order().getStatus(orderId: widget.orderId);
    if(dd != null){
      orderListener.updateStatus(orderId: widget.orderId,status: dd);
    }
  }
  Future<double> calculateTotal(data) async {
    double total = 0.0;
    for(var product in data['cart']['details']){
      total += double.parse(product['total'].toString());
    }
    double delCharge = await distanceService.calculateDistance(
        Position(
          latitude: data['latitude'],
          longitude: data['longitude'],
        ),
        destination: Position(
            latitude: data['store']['latitude'],
            longitude: data['store']['longitude']
        )
    ) * double.parse(data['store']['delivery_charge_per_km'].toString());
    if(data['isDelivery']){
      total += delCharge;
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    setState(() {
      isAtOrderDetails = false;
    });
//    disconnect();
  }
  @override
  Widget build(BuildContext context) {
    try{
      return Scaffold(
        resizeToAvoidBottomPadding: Platform.isIOS,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
              color: Colors.black54
          ),
          title: Image.asset("assets/images/logo.png",width: 60,),
          centerTitle: true,
        ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: () {
//          sendData();
//        },
//        child: Icon(Icons.send),
//      ),
        body: SafeArea(
          child: StreamBuilder<List>(
              stream: orderListener.stream$,
              builder: (context, order) {
                if(order.hasData) {
                  Map data = order.data.where((element) => element['id'] == widget.orderId).toList()[0];
                  if(data != null){
                    return Container(
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: ListView(
                        children: <Widget>[
                          AnimatedContainer(
                            width: double.infinity,
                            height: data['status'] < 0 ? 20 : 0,
                            duration: Duration(
                                milliseconds: 600
                            ),
                            color: Colors.red,
                            child: Center(
                              child: Text(data['status'] == -1 ?  "Order rejected" : "Order cancelled",style: TextStyle(
                                  color: Colors.white
                              ),),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          //Tracker Icons
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            width: double.infinity,
                            child: Row(
                              children: <Widget>[
                                if(data['isDelivery'] == 1)...{
                                  for(var x =0;x < deliveryTrack.length;x++)...{
                                    x != 0 ? Expanded(
                                      child: Container(
                                        height: 5,
                                        color: deliveryTrack[x]['status'] <= data['status'] ? kPrimaryColor : Colors.grey[300],
                                      ),
                                    ) : Container(),
                                    Container(
                                      width: 50,
                                      height: 50,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(1000),
                                        color: deliveryTrack[x]['status'] <= data['status'] ? kPrimaryColor : Colors.grey[300],
                                      ),
                                      child: Center(
                                        child: Image.asset(deliveryTrack[x]['image'],color: deliveryTrack[x]['status'] <= data['status'] ? Colors.white : Colors.grey[600],),
                                      ),
                                    ),
                                  }
                                }else...{
                                  for(var x =0;x < pickUpTrack.length;x++)...{
                                    x != 0 ? Expanded(
                                      child: Container(
                                        height: 5,
                                        color: pickUpTrack[x]['status'] <= data['status'] ? kPrimaryColor : Colors.grey[300],
                                      ),
                                    ) : Container(),
                                    Container(
                                      width: 50,
                                      height: 50,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(1000),
                                        color: pickUpTrack[x]['status'] <= data['status'] ? kPrimaryColor : Colors.grey[300],
                                      ),
                                      child: Center(
                                        child: Image.asset(pickUpTrack[x]['image'],color: pickUpTrack[x]['status'] <= data['status'] ? Colors.white : Colors.grey[600],),
                                      ),
                                    ),
                                  }
                                }
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                if(data['isDelivery'] == 1)...{
                                  for(var x =0;x < deliveryTrack.length;x++)...{
                                    Container(
                                        width: 60,
                                        padding: EdgeInsets.all(5),
                                        child: Center(
                                          child: Text(deliveryTrack[x]['name'],style: TextStyle(
                                            fontSize: 11,
                                            color: deliveryTrack[x]['status'] <= data['status'] ? kPrimaryColor : Colors.grey[600],
                                          ),textAlign: TextAlign.center,),
                                        )
                                    ),
                                  }
                                }else...{
                                  for(var x =0;x < pickUpTrack.length;x++)...{
                                    Container(
                                        width: 60,
                                        padding: EdgeInsets.all(5),
                                        child: Center(
                                          child: Text(pickUpTrack[x]['name'],style: TextStyle(
                                            fontSize: 11,
                                            color: pickUpTrack[x]['status'] <= data['status'] ? kPrimaryColor : Colors.grey[600],
                                          ),textAlign: TextAlign.center,),
                                        )
                                    ),
                                  }
                                }
                              ],
                            ),
                          ),
                          //Delivery/Orderer info
                          data['isDelivery'] == 1 ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.symmetric(vertical: BorderSide(color: Colors.grey[400]))
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 20,
                                  height: 20,
                                  child: Image.asset("assets/images/location_icon.png",color: Colors.green[600],),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        width: double.infinity,
                                        child: Text("Delivery Address",style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: Text("${StringFormatter(string: user_details.first_name).titlize()} ${StringFormatter(string: user_details.last_name).titlize()}",style: TextStyle(
                                            color: Colors.grey
                                        ),),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: Text("${data['address']}",style: TextStyle(
                                            color: Colors.grey
                                        ),),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ) : Container(),

                          //Charge info
                          data['isDelivery'] == 1 ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.symmetric(vertical: BorderSide(color: Colors.grey[400]))
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 25,
                                  height: 25,
                                  child: Image.asset("assets/images/del_motor.png",color: Colors.green[600],),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        width: double.infinity,
                                        child: Text("Delivery info",style: TextStyle(
                                            fontWeight: FontWeight.w600
                                        ),),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: Text("${data['store']['delivery_charge_per_km'] == 0 ? "FREE" : "Store Charge/km : ₱ ${double.parse(data['store']['delivery_charge_per_km'].toString()).toStringAsFixed(2)}"}",style: TextStyle(
                                            color: Colors.grey
                                        ),),
                                      ),

                                      Container(
                                          width: double.infinity,
                                          child: FutureBuilder(
                                            future: distanceService.calculateDistance(
                                                Position(
                                                    latitude: data['latitude'],
                                                    longitude: data['longitude']
                                                ),
                                                destination: Position(
                                                    latitude: data['store']['latitude'],
                                                    longitude : data['store']['longitude']
                                                )
                                            ),
                                            builder: (context,result) => result.hasData ? Text("Calculated Distance : ${result.data} km",style: TextStyle(
                                                color: Colors.grey
                                            ),) : Container(),
                                          )
                                      ),
                                      Container(
                                          width: double.infinity,
                                          child: FutureBuilder(
                                            future: distanceService.calculateDistance(
                                                Position(
                                                    latitude: data['latitude'],
                                                    longitude: data['longitude']
                                                ),
                                                destination: Position(
                                                    latitude: data['store']['latitude'],
                                                    longitude : data['store']['longitude']
                                                )
                                            ),
                                            builder: (context,result) => result.hasData ? Text("Delivery charge : ${result.data * double.parse(data['store']['delivery_charge_per_km'].toString())}",style: TextStyle(
                                                color: Colors.grey
                                            ),) : Container(),
                                          )
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ) : Container(),
                          //Order ID
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.symmetric(vertical: BorderSide(color: Colors.grey[400]))
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text("Order ID"),
                                ),
                                Container(
                                  child: Text("${data['id'].toString().padLeft(5,'0')}",style: TextStyle(
                                      color: kPrimaryColor
                                  ),),
                                )
                              ],
                            ),
                          ),
                          //Visit Shop
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(bottom: BorderSide(color: Colors.grey[400]))
                            ),
                            child: FlatButton(
                              onPressed: () => Navigator.push(context, PageTransition(child: StoreDetailsPage(data: data['store']))),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: Percentage().calculate(num: scrh,percent: 3),
                                    height: Percentage().calculate(num: scrh,percent: 3),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(1000),
                                        color: Colors.grey[300],
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey[400],
                                              offset: Offset(2,2),
                                              blurRadius: 2
                                          ),
                                        ],
                                        image: DecorationImage(
                                            alignment: AlignmentDirectional.center,
                                            fit: BoxFit.cover,
                                            image: data['store']['picture'] != null ? NetworkImage("https://ekaon.checkmy.dev${data['store']['picture']}") : AssetImage("assets/images/default_store.png")
                                        )
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text("${data['store']['name']}",style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54
                                    ),),
                                  ),
                                  Container(
                                    child: Text("Visit Shop"),
                                  ),
                                  Icon(Icons.chevron_right)
                                ],
                              ),
                            ),
                          ),
                          //Products
                          OrientationBuilder(
                              builder: (context, orient) {
                                return Container(
//                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                    alignment: AlignmentDirectional.centerStart,
                                    child: ListView.builder(
                                      itemCount: data['cart']['details'].length,
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context , index) => Container(

                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    width: Percentage().calculate(num: scrw,percent: orient == Orientation.portrait ? 10 : 15),
                                                    height: Percentage().calculate(num: scrw,percent: orient == Orientation.portrait ? 10 : 15),
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: data['cart']['details'][index]['product']['images'].length > 0 ? NetworkImage("https://ekaon.checkmy.dev${data['cart']['details'][index]['product']['images'][0]['url']}") : AssetImage("assets/images/no-image-available.png")
                                                        )
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                      child: Container(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: <Widget>[
                                                            Container(
                                                              width: double.infinity,
                                                              child: Text("${StringFormatter(string: data['cart']['details'][index]['product']['name']).titlize()}",maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.right,),
                                                            ),
                                                            Container(
                                                              width: double.infinity,
                                                              child: Text("${StringFormatter(string: data['cart']['details'][index]['product']['description']).titlize()}",maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.right,style: TextStyle(
                                                                  color: Colors.grey[600]
                                                              ),),
                                                            ),
                                                            Container(
                                                              width: double.infinity,
                                                              child: Text("${data['cart']['details'][index]['quantity']}x",maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.right,style: TextStyle(
                                                                  color: Colors.grey[600]
                                                              ),),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                  )
                                                ],
                                              ),
                                            ),
                                            Divider(),
                                            Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 20),
                                              width: double.infinity,
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text("Subtotal"),
                                                  ),
                                                  Text("₱ ${double.parse(data['cart']['details'][index]['total'].toString()).toStringAsFixed(2)}",style: TextStyle(
                                                      color: kPrimaryColor
                                                  ),)
                                                ],
                                              ),
                                            ),
                                            data['status'] == 3 && !yourRatedProductsListener.productIsRated(int.parse(data['cart']['details'][index]['product']['id'].toString())) ? Container(
                                              width: double.infinity,
                                              margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  borderRadius:  BorderRadius.circular(5.0),
                                                  color: kPrimaryColor
                                              ),
                                              child: FlatButton(
                                                onPressed: ()=> Navigator.push(context, PageTransition(child: RateProduct(data: data['cart']['details'][index]['product'],isProduct: true,), type: null)),
                                                child: Center(
                                                  child: Text("RATE",style: TextStyle(
                                                      color: Colors.white
                                                  ),),
                                                ),
                                              ),
                                            ) : Container(),
                                            Divider()
                                          ],
                                        ),
                                      ),
                                    )
                                );
                              }
                          ),
                          //Payment
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(bottom: BorderSide(color: Colors.grey[400]))
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: double.infinity,
                                  child: Text("Total Payment",style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w400
                                  ),),
                                ),
                                Container(
                                    width: double.infinity,
                                    child: Row(
                                      children: <Widget>[
                                        Text("Order Total",style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold
                                        ),),
                                        Expanded(
                                          child: Container(
                                              alignment: Alignment.centerRight,
                                              child: Text("Php ${double.parse(data['total'].toString())}",style: TextStyle(
                                                  color: kPrimaryColor,
                                                  fontWeight: FontWeight.bold
                                              ),)
                                          ),
                                        ),
                                      ],
                                    )
                                )
                              ],
                            ),
                          ),
                          //Order details
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(bottom: BorderSide(color: Colors.grey[400]))
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text("Order ID",style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey
                                        ),),
                                      ),
                                      Text("${data['id'].toString().padLeft(5,'0')}")
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text("Order Date",style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey
                                        ),),
                                      ),
                                      Text("${DateFormat("MMMM dd, yyyy").format(DateTime.parse(data['created_at'].toString().split('T')[0]))}",style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13
                                      ),)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(color: Colors.grey,),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: OutlineButton(
                                    onPressed: (){
                                      Navigator.push(context, PageTransition(child: ChatBox(recipient: user_details.toJson(), isStore: true, storeId: data['store']['id'], storeOwnerId: data['store']['owner']['id'], storeDetails: data['store'])));
                                    },
                                    color: Colors.grey,
                                    child: Center(
                                      child: Text("Message Seller"),
                                    ),
                                  ),
                                ),
                                data['status'] == 0 ? const SizedBox(width: 20,) : Container(),
                                data['status'] == 0 ? Expanded(
                                  child: OutlineButton(
                                    onPressed: (){
                                      setState(() {
                                        data['status'] = -2;
                                      });
                                      storeOrdersListener.updateStatusFromServer(data['id'], -2);
                                    },
                                    color: Colors.red,
                                    focusColor: Colors.red,
                                    child: Center(
                                      child: Text("Cancel Order",style: TextStyle(
                                          color: Colors.red
                                      ),),
                                    ),
                                  ),
                                ) : Container()
                              ],
                            ),
                          ),
                          if(!myRatedStores.isStoreRated(storeId: int.parse(data['store']['id'].toString())))...{
                            Divider(color: Colors.black54,),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20),

                              child: Container(
                                decoration: BoxDecoration(
                                    color: kPrimaryColor,
                                    borderRadius: BorderRadius.circular(5)
                                ),
                                child: FlatButton(
                                  padding: const EdgeInsets.all(0),
                                  onPressed: ()=>Navigator.push(context, PageTransition(child: RateProduct(data: data['store'],isProduct: false,), type: null)),
                                  child: Center(
                                    child: Text("Rate store",style: TextStyle(
                                        color: Colors.white
                                    ),),
                                  ),
                                ),
                              ),
                            ),

                          },
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    );
                  }else{
                    return Container(
                      child: Center(
                        child: Text("An error occurred please try again"),
                      ),
                    );
                  }
                }
                return Container();
              }
          ),
        ),
      );
    }catch(e){
      return MyWidgets().errorBuilder(context, error: e.toString());
    }
  }
}