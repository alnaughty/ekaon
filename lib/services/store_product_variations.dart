import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class ProductVariationListener
{
  BehaviorSubject<List> _data =  BehaviorSubject.seeded(null);
  Stream get stream$ => _data.stream;
  List get current => _data.value;

  updateAll({List data}){
    _data.add(data);
  }
  append({Map data}) {
    this.current.add(data);
    _data.add(this.current);
  }
  Future create(Map body) async {
    try{
      await http.post("$url/v1/product-variation/create",headers: {
        "accept" : "application/json"
      },body: body).then((respo) {
        var data = json.decode(respo.body);
        print("data : $data");
        if(respo.statusCode == 200){
          this.append(data: data);
        }
      });
    }catch(e){

    }
  }
  Future fetchFromServer() async {
    try{
      await http.get("$url/v1/product-variation/store/${myStoreDetails['id']}").then((respo){
        var data = json.decode(respo.body);
        print(data);
        this.updateAll(data: data['variations']);
        return data;
      });
      return [];
    }catch(e){
      return [];
    }
  }
}
ProductVariationListener productVariationListener = ProductVariationListener();