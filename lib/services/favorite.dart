import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class Favorite {
  Future manage({String key, String value}) async {
    try{
      final respo = await http.post("$url/v1/controlFavorite",headers: {
        "Accept" : "application/json"
      },body: {
        "user_id" : user_details.id.toString(),
        "$key" : "$value"
      });
//      var data = json.decode(respo.body);
      if(respo.statusCode == 200){
        Fluttertoast.showToast(msg: "Successful");
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
}