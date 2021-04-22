import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/services/firebase.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
class StoreOrdersListener{
  BehaviorSubject<List> _orders = BehaviorSubject.seeded(null);
  Stream get stream$ => _orders.stream;
  List get current => _orders.value;

  updateData(List data)
  {
//    data.sort((a,b)=>int.parse(a['id']).compareTo(int.parse(b['id'])));
    _orders.add(data);
    print("ADDED DATA : ${this.current}");
  }
  updateStatus(int orderId, int status)
  {
    print("UPDATE");
    if(status > 0){
      this.current.where((element) => element['id'] == orderId).toList()[0]['status'] = status;
    }else{
      print("REJECT $orderId");
      try{
        this.current.where((element) => element['id'] == orderId).toList()[0]['status'] = status;
        print("NEW ORDERS : ${this.current}");
        print("remove successful!");

      }catch(e){
        print("removing order error $e");
      }
    }
//    this.current.sort((a,b)=>int.parse(a['id']).compareTo(int.parse(b['id'])));
    _orders.add(this.current);
    this.updateStatusFromServer(orderId, status);

  }
  append({Map obj})
  {
    this.current.add(obj);
//    this.current.sort((a,b)=>int.parse(a['id']).compareTo(int.parse(b['id'])));
    _orders.add(this.current);
  }
  initAppend(orderId)
  {
    this.current.add({
      "id" : orderId,
      "details" : null
    });
//    this.current.sort((a,b)=>int.parse(a['id']).compareTo(int.parse(b['id'])));
    _orders.add(this.current);
    getDetailsFromServer(orderId);
  }
  getDetailsFromServer(orderId) async {
    try{
      final respo = await http.get("$url/v1/orderDetails/$orderId",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      if(respo.statusCode == 200){
        append(obj: data);
      }
      return false;
    }catch(e){
      return false;
    }
  }
  updateStatusFromServer(orderId, status) async {
    try{
      final respo = await http.put("$url/v1/order/$orderId/updateStatus/$status",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      if(respo.statusCode == 200) {
        Fluttertoast.showToast(msg: "You updated Order #${orderId.toString().padLeft(5,'0')}");
        for(var token in data['fcm_tokens']){
          Firebase().sendOrderNotification(token['fcm_token'], "Your order is ${status > 0 ? status == 1 ? "now being prepared" : status == 2 ? "being delivered" : "completed" : "rejected"}", "Order id ${orderId.toString().padLeft(5,'0')}", orderId, status);
        }
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }

}

StoreOrdersListener storeOrdersListener = StoreOrdersListener();