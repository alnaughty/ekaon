import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class VoteAuth{
  Future vote(storeId, int likeOrdislike) async {
    try{
      final respo = await http.post("$url/v1/vote",headers: {
        "Accept":"application/json"
      }, body: {
        "user_id": user_details.id.toString(),
        "store_id" : storeId.toString(),
        "like_or_dislike" : likeOrdislike.toString()
      });
      var data = json.decode(respo.body);
      if(respo.statusCode == 200){
        Fluttertoast.showToast(msg: "${data['message']}");
        return true;
      }
      Fluttertoast.showToast(msg: "Error ${respo.statusCode}, ${respo.reasonPhrase}");
      return false;
    }catch(e){
      Fluttertoast.showToast(msg: "An error has occurred");
      return true;
    }
  }
}