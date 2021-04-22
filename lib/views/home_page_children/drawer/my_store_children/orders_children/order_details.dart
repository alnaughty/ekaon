import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/services/distancer_service.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/position_listener.dart';
import 'package:ekaon/services/pricer.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/home_page_children/compose_message.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/ticket_clipper.dart';
import 'package:ekaon/views/map_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailPage extends StatefulWidget {
  final Map data;
  final List<Widget> buttons;
  OrderDetailPage(this.data,{this.buttons});
  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  double charge = 0.0;
  double getSubTotals() {
    double subtotal = 0.0;
    for(var x in widget.data['cart']['details']){
      setState(() {
        subtotal += double.parse(x['total'].toString());
      });
    }
    return subtotal;
  }
//  getCharge() async {
//    double dd = await PriceChecker().getDeliveryCharge(storeData: widget.data['store'], customerData: widget.data, subTotal: getSubTotals(), isDelivery: widget.data['isDelivery'].toString() == "1" ? true : false);
//    setState(() {
//      charge = dd;
//    });
//  }
  Future<double> get chargeGetter async {
    double distance = await distanceService.calculateDistance(
        Position(
          latitude: widget.data['latitude'],
          longitude: widget.data['longitude']
        ),
        destination: Position(
          latitude: widget.data['store']['latitude'],
          longitude: widget.data['store']['longitude']
        )
    );
    setState(() {
      charge = distance * double.parse(widget.data['store']['delivery_charge_per_km'].toString());
    });
  }
  double discount(){
    return (getSubTotals() + charge) - widget.data['total'];
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    chargeGetter;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: Platform.isIOS,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Order details",style: TextStyle(
          color: Colors.black
        ),),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    color: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                    child: Text("ORDER${widget.data['id'].toString().padLeft(5,'0')}",style: TextStyle(
                        color: Colors.white,
                        fontSize: Percentage().calculate(num: scrw, percent: 4),
                        fontWeight: FontWeight.w600
                    ),),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: buyerInfo(),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  for(var details in widget.data['cart']['details'])...{
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(1000),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: details['product']['images'].length == 0 ? AssetImage("assets/images/no-image-available.png") : NetworkImage("https://ekaon.checkmy.dev${details['product']['images'][0]['url']}")
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey[400],
                                      offset: Offset(3,3),
                                      blurRadius: 1.5
                                  )
                                ]
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: double.infinity,
                                  child: Text("${details['product']['name']}",style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: Percentage().calculate(num: scrw,percent: scrw > 700 ? 3.5 : 3.8)
                                  ),maxLines: 2, overflow: TextOverflow.ellipsis,),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: Text("Php${double.parse(details['total'].toString()).toStringAsFixed(2)}",style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: Percentage().calculate(num: scrw,percent: scrw > 700 ? 3.5 : 3.8),
                                      color: Colors.grey
                                  ),maxLines: 2, overflow: TextOverflow.ellipsis,),
                                )
                              ],
                            ),
                          ),
                          Container(
                            child: Text("${details['quantity']}x",style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: Percentage().calculate(num: scrw,percent: scrw > 700 ? 3.5 : 3.8)
                            ),),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  },
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                    child: brokenLines(count: 15),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Subtotal :",style: TextStyle(
                            fontSize: Percentage().calculate(num: scrw , percent: scrw > 700 ? 3.3 : 3.5),
                            fontWeight: FontWeight.bold,
                        )),
                        Text("Php${getSubTotals().toStringAsFixed(2)}",style: TextStyle(
                          fontSize: Percentage().calculate(num: scrw , percent: scrw > 700 ? 3.3 : 3.5),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey
                        ),)
                      ],
                    ),
                  ),

                  widget.data['isDelivery'] == 1 ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Delivery charge :",style: TextStyle(
                          fontSize: Percentage().calculate(num: scrw , percent: scrw > 700 ? 3.3 : 3.5),
                          fontWeight: FontWeight.bold,
                        )),
                        Text("Php${charge.toStringAsFixed(2)}",style: TextStyle(
                            fontSize: Percentage().calculate(num: scrw , percent: scrw > 700 ? 3.3 : 3.5),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey
                        ),)
                      ],
                    ),
                  ) : Container(),
                  const SizedBox(
                    height: 10,
                  ),
                  if(discount() > 0)...{
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Discount :",style: TextStyle(
                            fontSize: Percentage().calculate(num: scrw , percent: scrw > 700 ? 3.3 : 3.5),
                            fontWeight: FontWeight.bold,
                          )),
                          Text("Php${discount().toStringAsFixed(2)}",style: TextStyle(
                              fontSize: Percentage().calculate(num: scrw , percent: scrw > 700 ? 3.3 : 3.5),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey
                          ),)
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  },

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text("Total :",style: TextStyle(
                          fontSize: Percentage().calculate(num: scrw , percent: scrw > 700 ? 3.3 : 3.5),
                          fontWeight: FontWeight.bold,
                        )),
                        Text("Php${double.parse(widget.data['total'].toString()).toStringAsFixed(2)}",style: TextStyle(
                            fontSize: Percentage().calculate(num: scrw , percent: scrw > 700 ? 3.3 : 3.5),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey
                        ),)
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                    child: brokenLines(count: 15),
                  ),
                  widget.data['order_instruction'].toString() != "null" ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                    child: Text("Instruction :",style: TextStyle(
                        fontSize: Percentage().calculate(num: scrw , percent: scrw > 700 ? 3.6 : 3.8),
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor
                    ),),
                  ) : Container(),
                  widget.data['order_instruction'].toString() != "null" ? Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text("${widget.data['order_instruction']}",style: TextStyle(
                        fontSize: Percentage().calculate(num: scrw , percent: scrw > 700 ? 3.3 : 3.5),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey
                    )),
                  ) : Container()
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlineButton(
                onPressed: (){
                  Navigator.push(context, PageTransition(child: ChatBox(recipient: widget.data['orderer'],isStore: false,storeOwnerId: user_details.id, storeId: myStoreDetails['id'],storeDetails: myStoreDetails,)));
                },
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text("Message buyer",style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600]
                  ),),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            widget.buttons != null ? Container(
              width: double.infinity,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: widget.buttons,
              ),
            ) : Container(),
            const SizedBox(
              height: 20,
            )
          ],
        )
      ),
    );
  }
  Widget buyerInfo() => Column(
    children: <Widget>[
      Container(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.location_on,color: Colors.black,),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: FlatButton(
                padding: const EdgeInsets.all(0),
                onPressed: (){
                  Navigator.push(context, PageTransition(
                      child: MapPage(
                          name: "${StringFormatter(string: widget.data['orderer']['first_name']).titlize()} ${StringFormatter(string: widget.data['orderer']['last_name']).titlize()}",
                          longitude: widget.data['longitude'],
                          latitude: widget.data['latitude']
                      )
                  ));
                },
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: Text("${StringFormatter(string: widget.data['orderer']['first_name']).titlize()} ${StringFormatter(string: widget.data['orderer']['last_name']).titlize()}",style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3.5 : 4)
                      ),),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: double.infinity,
                      child: Text("${widget.data['address']}",maxLines: 2, overflow: TextOverflow.ellipsis ,style: TextStyle(
                          fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3.3 : 3.8),
                          color: Colors.grey[500]
                      ),),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      const SizedBox(
        height: 15,
      ),
      Container(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.phone_in_talk,color: Colors.black,),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  for(var numbers in widget.data['orderer']['contact_numbers'])...{
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(

                        onTap: () async {
                          String toLaunch = "tel://${numbers['number']}";
//                          await launch("tel: $toLaunch");
                          if(await canLaunch("$toLaunch")){
                            await launch("$toLaunch");
                          }else{
                            Fluttertoast.showToast(msg: "Could not launch ${numbers['number']}");
                          }
                        },
                        child: Text("${numbers['number']}",style: TextStyle(
                          color: Colors.blue,
                          fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3.3 : 3.8),
                          decoration: TextDecoration.underline,
                        ),),
                      ),
                    )
                  }
                ],
              ),
            )
          ],
        ),
      ),
      const SizedBox(
        height: 15,
      ),
      Container(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.email,color: Colors.black,),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                child: Text("${widget.data['orderer']['email']}",style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3.5 : 4)
                ),),
              ),
            )
          ],
        ),
      ),
      const SizedBox(
        height: 15,
      ),
      Container(
        width: double.infinity,
        child: Row(
          children: <Widget>[
            Icon(Icons.access_time,color: Colors.black,),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text("${DateFormat().add_jm().format(DateTime.parse(widget.data['time'].toString()))}",style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                  fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3.5 : 4)
              ),),
            )
          ],
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            for(var x=0;x<20;x++)...{
              Container(
                width: 10,
                height: 5,
                color: Colors.grey[400],
              )
            }
          ],
        ),
      ),

    ],
  );
}
