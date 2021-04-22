import 'package:ekaon/global/constant.dart';
import 'package:ekaon/services/order_notifier.dart';
import 'package:ekaon/services/store_orders_listener.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/orders_children/order_product_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PendingPickup extends StatefulWidget {
  @override
  _PendingPickupState createState() => _PendingPickupState();
}

class _PendingPickupState extends State<PendingPickup> {
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
                    child: data.where((element) => element['status'] == 0).toList().length > 0 ? Scrollbar(
                      child: ListView(
                        children: <Widget>[
                          for(var x=0;x<data.where((element) => element['status'] == 0).toList().length;x++)...{
                            Container(
                              width: double.infinity,
                              height: 90,
                              child: OrderBox(
                                [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: kPrimaryColor,
                                          borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: FlatButton(
                                        onPressed: (){
                                          Navigator.of(context).pop();
                                          storeOrdersListener.updateStatus(int.parse(data.where((element) => element['status'] == 0).toList()[x]['id'].toString()), 1);
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                        child: Center(
                                          child: Text("Accept",style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15
                                          ),),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[900],
                                          borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: FlatButton(
                                        onPressed: (){
                                          Navigator.of(context).pop();
                                          storeOrdersListener.updateStatus(int.parse(data.where((element) => element['status'] == 0).toList()[x]['id'].toString()), -1);
                                          storeOrderNotifierListener.update(storeOrderNotifierListener.current - 1);
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                        child: Center(
                                          child: Text("Reject",style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15
                                          ),),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                data: data.where((element) => element['status'] == 0).toList()[x],
                                actions: [
                                  IconSlideAction(
                                    iconWidget: Icon(Icons.check,color: Colors.white,),
                                    color: kPrimaryColor,
                                    onTap: (){
                                      storeOrdersListener.updateStatus(int.parse(data.where((element) => element['status'] == 0).toList()[x]['id'].toString()), 1);
                                    },
                                  ),
                                  IconSlideAction(
                                    iconWidget: Icon(Icons.close,color: Colors.white,),
                                    color: Colors.grey[900],
                                    onTap: (){
                                      storeOrdersListener.updateStatus(int.parse(data.where((element) => element['status'] == 0).toList()[x]['id'].toString()), -1);
                                      storeOrderNotifierListener.update(storeOrderNotifierListener.current - 1);
                                    },
                                  )
                                ],
                              ),
                            )
                          }
                        ],
                      ),
                    ) : Center(
                      child: this.report("No pending orders"),
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
