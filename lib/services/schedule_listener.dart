import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class ScheduleListener{
  BehaviorSubject<List> _days = BehaviorSubject.seeded(null);
  Stream get stream$ => _days.stream;
  List get current => _days.value;
  updateAll({List data}) {
    _days.add(data);
  }
  strToTime(String time, int index) {
//    String tt = time.split('-')[index];
    if(time == "null"){
      return time;
    }
    return time.split('-')[index].replaceAll(" ", "");
  }
  activate(id){
    for(var x in this.current){
      if(x['id'].toString() == "$id"){
        x['activate'] = 1;
      }else{
        x['activate'] = 0;
      }
    }
//    Fluttertoast.showToast(msg: "You have activated a schedule");
    _days.add(this.current);
  }
  deactivate(id){
    for(var x in this.current){
      x['activate'] = 0;
    }
//    Fluttertoast.showToast(msg: "You have deactivated all schedule");
    _days.add(this.current);
  }
  append(Map data){
    this.current.add(data);
    _days.add(this.current);
  }
  remove(id){
    this.current.removeWhere((element) => element['id'] == id);
    _days.add(this.current);
  }
  void updateAllTime(String time, bool isOpen) {
    for(var data in this.current){
      if(isOpen){
          data['open_time'] = time;
      }else{
          data['close_time'] = time;
      }
        data['active'] = true;
    }
    _days.add(this.current);
  }
  void removeAllTimes(){
    for(var data in this.current){
        data['open_time'] = null;
        data['close_time'] = null;
        data['active'] = false;
    }
  }
  Future manageStatusServer(id,int type) async{
    try{
      final respo = await http.put("$url/v1/store_schedule/statusManager/$id/$type",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      print(data);
      Fluttertoast.showToast(msg: "${data['message']}");
      if(respo.statusCode == 200){
        if(type == 0){
          this.deactivate(id);
        }else{
          this.activate(id);
        }
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
  Future removeServer(id) async {
    try{
      final respo = await http.delete("$url/v1/store_schedule/remove/$id",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      Fluttertoast.showToast(msg: "${data['message']}");
      if(respo.statusCode == 200){
        this.remove(id);
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
  Future getFromServer() async {
    try{
      final respo = await http.get("$url/v1/store_schedule/get/${myStoreDetails['id']}",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      print("TO FORMAT : $data");
      if(respo.statusCode != 200){
        Fluttertoast.showToast(msg: "Error ${respo.statusCode}, ${respo.reasonPhrase}");
      }
      _days.add(data['schedule']);
      return false;
    }catch(e){
      return true;
    }
  }
  Future addOrUpdateServer(String days, String time) async {
    try{
      final respo = await http.post("$url/v1/store_schedule/add",headers: {
        "accept" : "application/json"
      }, body: {
        "store_id" : "${myStoreDetails['id']}",
        "days" : "$days",
        "time" : "$time",
        'activate' : "1",
      });
      var data = json.decode(respo.body);
      print("SCHEDULE : $data");
      Fluttertoast.showToast(msg: "${data['message']}");
      print(respo.statusCode);
      if(respo.statusCode == 200){
        this.append(data['data']);
        this.activate(data['data']['id']);
//        updateAll(data: data['data']);
//        this.formatter(data: data['data']);
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }

  stringFuser(String openTime, String closeTime) {
    return openTime+ " - " + closeTime;
  }
//  Future updateServer(String mon, String tue, String wed, String thu, String fri,String sat, String sun) async {
//    try{
//      final respo = await http.post("$url/v1/store_schedule/update",headers: {
//        "accept" : "application/json"
//      }, body: {
//        "store_id" : "${myStoreDetails['id']}",
//        "mon" : mon,
//        "tue" : tue,
//        "wed" : wed,
//        "thu" : thu,
//        "fri" : fri,
//        "sat" : sat,
//        "sun" : sun
//      });
//    }catch(e){
//
//    }
//  }
  Future<bool> toAdd() async {
    return this.current.where((element) => element['open_time'].toString() == "null" && element['close_time'].toString() == "null").toList().length  == 7;
  }
//  Future<bool> is247() async {
//    var tempOpn = this.current[0]["open_time"].toString();
//    var tempCls = this.current[0]['close_time'].toString();
//    for(var x =1;x< this.current.length;x++){
//      print("$tempOpn == ${this.current[x]['open_time']}");
//      print("$tempCls == ${this.current[x]['close_time']}");
//      if(tempOpn != this.current[x]['open_time'].toString() && tempCls != this.current[x]['close_time'].toString()){
//        return false;
//      }
//    }
//    return true;
//  }
}
ScheduleListener scheduleListener = ScheduleListener();