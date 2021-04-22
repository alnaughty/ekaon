import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
class DiscountCollected {
  BehaviorSubject<List> _collected = BehaviorSubject.seeded(null);
  Stream get stream$ => _collected.stream;
  List get current => _collected.value;

  updateAll(List data){
    _collected.add(data);
  }
  append(Map data){
    if(this.current == null)
    {
      List nData = [];
      nData.add(data);
      _collected.add(nData);
    }else{
      this.current.add(data);
      _collected.add(this.current);
    }
  }
  formatter({List data}){

    if(this.current == null){
      List da = [];
      for(var collections in data){
        da.add(collections['voucher']);
      }
      _collected.add(da);
    }else{
      for(var collections in data){
        this.current.add(collections['voucher']);
      }
      _collected.add(this.current);
    }
  }
  Future fetchFromServer() async {
    try{
      final respo = await http.get("$url/v1/discount/collections/${user_details.id}",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      print("DATA : $data");
      if(respo.statusCode == 200){
        this.formatter(data: data['data']);
        return this.current;
      }
      return null;
    }catch(e){
      return null;
    }
  }
}

DiscountCollected discountCollected = DiscountCollected();