import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
class MyRatedStores{
  BehaviorSubject<List> _stores = BehaviorSubject.seeded(null);
  Stream get stream$ => _stores.stream;
  List get current => _stores.value;

  updateAll({List data})
  {
    _stores.add(data);
  }
  appendData({Map data})
  {
    displayData.where((element) => element['id'] == data['store_id']).toList()[0]['rating'].add(data);
    this.current.add(data);
    _stores.add(this.current);
  }
  bool isStoreRated({int storeId}){
    for(var rated in this.current){
      if(int.parse(rated['store_id'].toString()) == storeId){
        return true;
      }
    }
    return false;
  }
  Future addRatingServer(storeId,rate,message) async {
    try{
      Map<String,dynamic> body;
      if(message.isNotEmpty){
        body = {
          "store_id" : "$storeId",
          "rate" : "$rate",
          "submitted_by_user_id" : "${user_details.id}",
          "message" : "$message"
        };
      }else{
        body = {
          "store_id" : "$storeId",
          "rate" : "$rate",
          "submitted_by_user_id" : "${user_details.id}",
        };
      }
      final respo = await http.post("$url/v1/addStoreRating",headers: {
        "accept" : "application/json"
      },body: body);
      var data = json.decode(respo.body);
      Fluttertoast.showToast(msg: "${data['message']}");
      if(respo.statusCode == 200){
        this.appendData(data: data['data']);
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
//  fetchAllFromServer() async {
//    try{
//      final respo = await http.get("$url/v1/getMyRated/${userDetails['id']}/1",headers: {
//        "accept" : "application/json"
//      });
//      var data = json.decode(respo.body);
//      print(data);
//      if(respo.statusCode == 200){
//        this.updateAll(data: data['data']);
//      }
//      return null;
//    }catch(e){
//      return null;
//    }
//  }
}
MyRatedStores myRatedStores = MyRatedStores();