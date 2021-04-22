import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/services/convo_listener.dart';
import 'package:ekaon/services/new_message_listener.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class MessageListener {
  BehaviorSubject<List> _messages = BehaviorSubject.seeded(null);
  Stream get stream$ => _messages.stream;
  List get current => _messages.value;
  int currentChatRoomId;
  int getCurrentChatroomId()
  {
    return this.currentChatRoomId;
  }
  updateChatroomId(id)
  {
    this.currentChatRoomId = id;
  }
  fullAppend(Map data) {

    if(this.current == null){
      List newData = [];
      newData.add(data);
      _messages.add(newData);
    }else{
      this.current.add(data);
      _messages.add(this.current);
    }

  }
  updateCount({int newCount, int chatroomId}) async {
    print("UPDATING COUNT to $newCount");
    this.current.where((element) => element['id'] == chatroomId).toList()[0]['new_messages'] = newCount;

    newMessageCounter.countFetcher(this.current);
    _messages.add(this.current);


  }
  sortByDate(List data) {
    data.sort((a,b){
      DateTime aDate = DateTime.parse(a['last_convo']['created_at'].toString());
      DateTime bDate = DateTime.parse(b['last_convo']['created_at'].toString());
      return bDate.compareTo(aDate);
    });
    _messages.add(data);
  }
  int getChatroomCount(int chatroomId) {
    int data = this.current.where((element) => element['id'] == chatroomId).toList()[0]['new_messages'];
    if(data != null) {
      return data;
    }
    return 0;
  }

  updateAll({List data}) {
    if(data != null){
      this.sortByDate(data);
      newMessageCounter.countFetcher(data);
    }
    _messages.add(data);
  }
  appendAndUpdate({Map data}) async {
    Map toAdd = await convoListener.getConvo(customerId: data['customer_id'],storeOwnerId: data['store_owner_id'],storeId: data['store_id']);
    this.current.add(toAdd);
    _messages.add(this.current);
  }
  bool chatRoomExists(chatroomId) {
    for(var d in this.current){
      if(d['id'] == chatroomId){
        return true;
      }
    }
    return false;
  }
  bool hasFetched(){
    if(this.current == null){
      return false;
    }
    return true;
  }
  updateConvo(int chatroomId,Map obj) {
    print("ID: $chatroomId");

    this.current.where((element) => element['id'] == chatroomId).toList()[0]['last_convo'] = obj;
    _messages.add(this.current);
    this.sortByDate(this.current);
  }
  getMessagesServer() async {
    try{
      final respo = await http.get("$url/v1/getMessages/${user_details.id}",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      print("Messages : $data");
      if(respo.statusCode == 200){
        this.updateAll(data: data['messages']);
        return true;
      }
      this.updateAll(data: null);
      Fluttertoast.showToast(msg: "An error has occurred while processing your request, ${respo.statusCode}");
      return false;
    }catch(e){
      this.updateAll(data: null);
      Fluttertoast.showToast(msg: "Server error, please contact administrator");
      return false;
    }
  }
  seen(chatroomId) async {
    try{
      final respo = await http.put("$url/v1/seen/${user_details.id}/$chatroomId",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      print("Data : $data");
      if(respo.statusCode == 200) {
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
}
MessageListener messageListener = MessageListener();

