import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/services/authentication.dart';
import 'package:ekaon/services/cart.dart';
import 'package:ekaon/services/firebase.dart';
import 'package:ekaon/services/order_listener.dart';
import 'package:ekaon/views/home_page.dart';
import 'package:ekaon/views/home_page_children/drawer/transaction_children/order_details.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

class Order {
  Future add(context,{List cart_data, int ownerId, int storeId,int cartId,Map location, int isDelivery,DateTime time,String orderI = '', double total, withDiscount}) async {
    try{
      print("ORDERING...");
      Map body = {
        "user_id" : user_details.id.toString(),
        "address" : location['address'],
        "longitude" : location['longitude'].toString(),
        "latitude" : location['latitude'].toString(),
        "isDelivery" : isDelivery.toString(),
        "time" : time.toString(),
        "cart_id" : cartId.toString(),
        "store_id" : storeId.toString(),
        'order_instruction' : orderI,
        "total" :"$total",
        "with_discount" : "$withDiscount"
      };
      if(cart_data.length > 0 ){
        body['cart_data'] = "$cart_data";
      }
      final respo = await http.post("$url/v1/addOrder",headers: {
        "Accept" : "application/json",
      }, body: body);
      var data = json.decode(respo.body);
      print(data);
//      Fluttertoast.showToast(msg: "${data['message']}");
      if(respo.statusCode == 200){
        orderListener.addNew(object: data['data']);
        Navigator.push(context, PageTransition(child: HomePage(showAd: false,)));
        print("Returned");
        Navigator.push(context, PageTransition(child: OrderDetailsWithTracker(orderId: int.parse(data['data']['id'].toString()))));
        cartAuth.removeCart(cartId: cartId,removeLocal: true);
        Fluttertoast.showToast(msg: "Order added");
        await Auth().getFCMTokens(ownerId).then((value) {
          if(value != null){
            for(var fcmToken in value){
              Firebase().sendNotification(fcmToken['fcm_token']);
            }
          }
        });
        return data['data'];
      }
      Fluttertoast.showToast(msg: "Error ${respo.statusCode}, ${respo.reasonPhrase}");
      return null;
    }catch(e){
      print("XXX $e");
      return null;
    }
  }
  Future remove({int orderId}) async {
    try{
      final respo = await http.delete("$url/v1/removeOrder/$orderId",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      if(respo.statusCode == 200){
        Fluttertoast.showToast(msg: "${data['message']}");
        return true;
      }
      Fluttertoast.showToast(msg: "Error ${respo.statusCode}, ${respo.reasonPhrase}");
      return false;
    }catch(e){
      Fluttertoast.showToast(msg: "An unexpected error occurred");
      return false;
    }
  }
  Future<int> getStatus({int orderId}) async {
    try{
      final respo = await http.get("$url/v1/getStatus/$orderId",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      print("DATA : $data");
      if(respo.statusCode == 200){
        return data['status'];
      }
      return null;
    }catch(e){
      print("ERROR : $e");
      return null;
    }
  }
  Future orderDate({int storeId, String date}) async {
    try{
      var respo = await http.post("$url/v1/getOrderByDate",headers: {
        "accept" : "application/json"
      },body: {
        "date" : "$date",
        "store_id" : "$storeId"
      });
      var data = json.decode(respo.body);
//      print("DATA : $data");
      if(respo.statusCode == 200){
        return data;
      }
      return null;
    }catch(e){
      print(e);
      return null;
    }
  }
}