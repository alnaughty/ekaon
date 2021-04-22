import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/services/order_notifier.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/store_orders_listener.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/orders_children/delivery_children/completed.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/orders_children/delivery_children/delivering.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/orders_children/delivery_children/pending.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/orders_children/delivery_children/preparing.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/orders_children/order_product_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
//import 'package:pusher/pusher.dart';
//import 'package:pusher_websocket_flutter/pusher.dart' as listener;
class StoreDelivery extends StatefulWidget {
  @override
  _StoreDeliveryState createState() => _StoreDeliveryState();
}

class _StoreDeliveryState extends State<StoreDelivery> with SingleTickerProviderStateMixin {
  int tabIndex = 0;
  List topBar = [
    {
      "name" : "Pending",
      "index" : 0,
    },
    {
      "name" : "Preparing",
      "index" : 1,
    },
    {
      "name" : "Delivering",
      "index" : 2,
    },
    {
      "name" : "Complete",
      "index" : 3,
    }
  ];
  List<Widget> _contents = [PendingDelivery(),PreparingDelivery(),DeliveringDelivery(),CompletedDelivery()];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  Text report(String text) => Text("$text",style: TextStyle(
    color: kPrimaryColor,
    fontWeight: FontWeight.w600,
    fontSize: 16.5
  ),);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          bottom: PreferredSize(
              child: Container(
                width: double.infinity,
                height: 50,
                child: Row(
                  children: <Widget>[
                    for(var topNav in topBar)...{
                      Expanded(
                        child: FlatButton(
                          onPressed: ()=> setState(()=> tabIndex = topNav['index']),
                          child: Center(
                            child: tabIndex == topNav['index'] ? Padding(
                              padding: const EdgeInsets.all(2),
                              child: FittedBox(
                                child: Text("${topNav['name']}",style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),),
                              ),
                            ) : Text("${topNav['name']}",style: TextStyle(
                            fontSize: 12.5,//15
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.7)
                            ),)
                          ),
                        ),
                      )
                    }
                  ],
                ),
              ),
              preferredSize: Size(double.infinity, 50)),
        ),
      ),
      body: AnimatedSwitcher(
        child: _contents[tabIndex],
        duration: Duration(milliseconds: 600),
      )
    );
  }
}
