import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/services/discount_listener.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class Discount {
  Future check(storeId, code) async {
    try{
      final respo = await http.get("$url/v1/discount/validate/$storeId/$code",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);

      if(respo.statusCode == 200){
        return data['data'];
      }
      Fluttertoast.showToast(msg: "Code not found");
      return null;
    }catch(e){
      return null;
    }
  }
  Future update({
    @required String code,
    @required String amount,
    @required String minSpend,
    @required DateTime validity,
    @required bool isPercentage,
    @required Color color,
    @required int id
  }) async {
    try{
      final respo = await http.post("$url/v1/discount/update",headers: {
        "accept" : "application/json"
      },body: {
        "code" : code,
        "store_id" : "${myStoreDetails['id']}",
        "on_reach" : minSpend,
        "type" : isPercentage ? "1" : "0",
        "value" : amount,
        "valid_until" : "$validity",
        "color" : "$color",
        "id" : "$id"
      });
      var data = json.decode(respo.body);
      if(respo.statusCode == 200){
        discountListener.update(id, data['data']);
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
  Future add({@required String code, @required String amount, @required String minSpend, @required DateTime validity, @required bool isPercentage, @required Color color}) async {
    try{
      final respo = await http.post("$url/v1/discount/add",headers: {
        "accept" : "application/json"
      }, body: {
        "code" : code,
        "store_id" : "${myStoreDetails['id']}",
        "on_reach" : minSpend,
        "type" : isPercentage ? "1" : "0",
        "value" : amount,
        "valid_until" : "$validity",
        "color" : "$color"
      });
      var data = json.decode(respo.body);
      print(data);
      if(respo.statusCode == 200){
        discountListener.append(data['data']);
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }

  Future remove({int id}) async {
    try{
      final respo = await http.delete("$url/v1/discount/delete/$id",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      if(respo.statusCode == 200){
        discountListener.remove(id);
        Fluttertoast.showToast(msg: "Removed successfully");
        return true;
      }
      Fluttertoast.showToast(msg: "Error ${respo.statusCode} ${respo.reasonPhrase}");
      return false;
    }catch(e){
      print(e);
      return false;
    }
  }

  Future get({int store_id}) async {
    try{
      Map<String, dynamic> body;
      if(user_details == null){
        body = {
          "store_id" : "$store_id"
        };
      }else{
        body = {
          "store_id" : "$store_id",
          "user_id" : "${user_details.id}"
        };
      }
      final respo = await http.post("$url/v1/discount/get",headers: {
        "accept" : "application/json"
      },body: body);
      var data = json.decode(respo.body);
      print("VOUCHER DATA : $data");
      if(respo.statusCode == 200){
        return data;
      }
      return null;
    }catch(e){
      return null;
    }
  }

  Future collect({int discountId}) async {
    try{
      final respo = await http.post("$url/v1/discount/collect",headers: {
        "accept" : "application/json"
      }, body: {
        "discount_id" : "$discountId",
        "user_id" : "${user_details.id}"
      });
      if(respo.statusCode == 200){
        Fluttertoast.showToast(msg: "Voucher collected");
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
}