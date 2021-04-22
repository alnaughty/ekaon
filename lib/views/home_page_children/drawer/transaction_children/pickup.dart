import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/order_listener.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/home_page_children/drawer/transaction_children/order_details.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class PickupTransaction extends StatefulWidget {
  @override
  _PickupTransactionState createState() => _PickupTransactionState();
}

class _PickupTransactionState extends State<PickupTransaction> {
  double getTotal(Map data) {
    double total = 0.0;
    for(var x in data['details'])
    {
      total += x['sub_total'];
    }
    return total;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: StreamBuilder<List>(
        stream: orderListener.stream$,
        builder: (context, result) {
          try{
            List data = result.data.where((element) => int.parse(element['isDelivery'].toString()) == 0).toList();
            if(data.length > 0 ) {
              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (_, index) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 10),
                    color: Colors.grey[200],
                    child: ListTile(
                      title: Text(StringFormatter(string: "order ${data[index]['id'].toString().padLeft(5,'0')}").titlize(),style: TextStyle(
                          color: kPrimaryColor
                      ),),
                      subtitle: Text(StringFormatter().orderStatus(data[index]['status'], true)),
                      onTap: () =>Navigator.push(context, PageTransition(
                          child: OrderDetailsWithTracker(orderId: int.parse(data[index]['id'].toString()))
                      )),
                    ),
                  )
              );
            }
            return Center(
              child: Text("You have no order to pickup",style: TextStyle(
                  fontSize: Theme.of(context).textTheme.headline6.fontSize - 3,
                  fontWeight: FontWeight.w600
              ),),
            );
          }catch(e){
            return MyWidgets().errorBuilder(context,error: e.toString());
          }
        },
      )
    );
  }
}
