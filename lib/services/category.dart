import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as  http;

class Categories{
  Future get() async {
    try{
      final respo = await http.get("$url/v1/getCategories",headers: {
        "Accept" : "application/json"
      });
      var data = json.decode(respo.body);
      print(data);
      if(respo.statusCode == 200)
      {
        return data['categories'];
      }
      return null;
    }catch(e)
    {
      return null;
    }
  }

  Future add(name, storeId,base64) async {
    try{
      final respo = await http.post("$url/v1/addCats",headers: {
        "Accept" : "application/json"
      }, body: {
        "name": name,
        "store_id" : storeId.toString(),
        "image" : "data:image/jpeg;base64,$base64"
      });
      var data = json.decode(respo.body);
      print(data);
      if(respo.statusCode == 200)
      {
        Fluttertoast.showToast(msg: "${data['message']}");
        return data['data'];
      }
      Fluttertoast.showToast(msg: "Error ${respo.statusCode}, ${respo.reasonPhrase}");
      return null;
    }catch(e){
      return null;
    }
  }
}