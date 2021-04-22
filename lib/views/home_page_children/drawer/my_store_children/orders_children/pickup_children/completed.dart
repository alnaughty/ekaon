import 'package:ekaon/global/constant.dart';
import 'package:ekaon/services/store_orders_listener.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/orders_children/order_details.dart';
import 'package:ekaon/views/home_page_children/drawer/transaction_children/service.dart';
import 'package:ekaon/views/map_page.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:page_transition/page_transition.dart';

class CompletedPickup extends StatefulWidget {
  @override
  _CompletedPickupState createState() => _CompletedPickupState();
}

class _CompletedPickupState extends State<CompletedPickup> {
  Text report(String text) => Text("$text",style: TextStyle(
      color: kPrimaryColor,
      fontWeight: FontWeight.w600,
      fontSize: 16.5
  ),);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.infinity,
          child: StreamBuilder<List>(
            stream: storeOrdersListener.stream$,
            builder: (context, result) {
              if(result.hasData){
                List data = result.data.where((element) => element['isDelivery'] == 0).toList();
                if(data != null) {
                  return Container(
                    width: double.infinity,
                    child: data.where((element) => element['status'] == 3).toList().length > 0 ? Scrollbar(
                      child: ListView(
                        children: <Widget>[
                          for(var x=0;x<data.where((element) => element['status'] == 3).toList().length;x++)...{
                            Container(
                              height: 90,
                              width: double.infinity,
                              color: Colors.white,
                              child: FlatButton(
                                  onPressed: (){
                                    Navigator.push(context, PageTransition(child: OrderDetailPage(data.where((element) => element['status'] == 3).toList()[x]), type: PageTransitionType.leftToRightWithFade));
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(1000),
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                alignment: AlignmentDirectional.center,
                                                image: data[x]['orderer']['profile_picture'] == null ? AssetImage("assets/images/no-image-available.png") : NetworkImage('https://ekaon.checkmy.dev${data[x]['orderer']['profile_picture']}')
                                            )
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              width: double.infinity,
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child:  Text("Order #${data[x]['id'].toString().padLeft(5,'0')}",style: TextStyle(
                                                      color: kPrimaryColor,
                                                      fontWeight: FontWeight.w700,
                                                    ),),
                                                  ),
                                                  FutureBuilder(
                                                    future: Trans(orderer: Coordinates(data[x]['latitude'], data[x]['longitude']), store: Coordinates(data[x]['store']['latitude'], data[x]['store']['longitude'])).getTotal(data[x]),
                                                    builder: (context, result) => result.hasData ? Text("₱${double.parse(result.data.toString()).toStringAsFixed(2)}",style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight: FontWeight.w700,
                                                    ),) : Container(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              child: InkWell(
                                                onTap: (){
                                                  Navigator.push(context, PageTransition(
                                                      child: MapPage(
                                                          name: "${StringFormatter(string: data[x]['orderer']['first_name']).titlize()} ${StringFormatter(string: data[x]['orderer']['last_name']).titlize()}",
                                                          longitude: data[x]['longitude'],
                                                          latitude: data[x]['latitude']
                                                      )
                                                  ));
                                                },
                                                child: Text("${data[x]['address']}",maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(
                                                    color: Colors.black,
//                              decoration: TextDecoration.underline,
                                                    fontStyle: FontStyle.italic
                                                ),),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                              ),
                            ),
                          }
                        ],
                      ),
                    ) : Center(
                      child: this.report("No completed orders for today"),
                    ),
                  );
                }
              }
              return Container(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(kPrimaryColor),
                  ),
                ),
              );
            },
          )
      ),
    );
  }
}
