import 'package:ekaon/global/constant.dart';
import 'package:ekaon/services/order_notifier.dart';
import 'package:ekaon/services/store_orders_listener.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/orders_children/order_product_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
class PreparingDelivery extends StatefulWidget {
  @override
  _PreparingDeliveryState createState() => _PreparingDeliveryState();
}

class _PreparingDeliveryState extends State<PreparingDelivery> {
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
                List data = result.data.where((element) => element['isDelivery'] == 1).toList();
                if(data != null) {
                  return Container(
                    width: double.infinity,
                    child: data.where((element) => element['status'] == 1).toList().length > 0 ? Scrollbar(
                      child: ListView(
                        children: <Widget>[
                          for(var x=0;x<data.where((element) => element['status'] == 1).toList().length;x++)...{
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
                                          storeOrdersListener.updateStatus(int.parse(data.where((element) => element['status'] == 1).toList()[x]['id'].toString()), 2);
                                        },
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5)
                                        ),
                                        child: Center(
                                          child: Text("Deliver",style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15
                                          ),),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                                data: data.where((element) => element['status'] == 1).toList()[x],
                                actions: [
                                  IconSlideAction(
                                    iconWidget: Icon(Icons.check,color: Colors.white,),
                                    color: kPrimaryColor,
                                    onTap: (){
                                      storeOrdersListener.updateStatus(int.parse(data.where((element) => element['status'] == 1).toList()[x]['id'].toString()), 2);
                                    },
                                  ),
                                ],
                              ),
                            )
                          }
                        ],
                      ),
                    ) : Center(
                      child: this.report("No order is being prepared"),
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
