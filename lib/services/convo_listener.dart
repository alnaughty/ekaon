import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/services/authentication.dart';
import 'package:ekaon/services/firebase.dart';
import 'package:ekaon/services/message_listener.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class ConvoListener {
  BehaviorSubject<Map> _convo = BehaviorSubject.seeded(null);
  Stream get stream => _convo.stream;
  Map get current => _convo.value;
  ScrollController scrollController = new ScrollController();
  updateAll({Map obj}) async {
    _convo.add(obj);
    await Future.delayed(Duration(milliseconds: 600));
    this.scrollController.animateTo(this.scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 700), curve: Curves.fastLinearToSlowEaseIn);
  }
  append(String senderName, String senderPicture, {Map toSend, List images}) async
  {

    this.current['conversation'].add(toSend);
    _convo.add(this.current);
    await this.sendServer(senderName, senderPicture,toSend['customer_id'], toSend['store_id'], toSend['store_owner_id'], toSend['sender_type'], toSend['message'], toUpdate: this.current['conversation'],images: images);
    await Future.delayed(Duration(milliseconds: 600));
    this.scrollController.animateTo(this.scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 700), curve: Curves.fastLinearToSlowEaseIn);
//    if(this.current['conversation'].length > 0){
//
//    }else{
//      this.current['conversation'].add(toSend);
//      _convo.add(this.current);
//      await this.sendServer(senderName, senderPicture,toSend['customer_id'], toSend['store_id'], toSend['store_owner_id'], toSend['sender_type'], toSend['message'], toUpdate: this.current['conversation'],isNew: true);
//      await Future.delayed(Duration(milliseconds: 600));
//      this.scrollController.animateTo(this.scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 700), curve: Curves.fastLinearToSlowEaseIn);
//    }
  }
  appendNewConvo({Map obj}) async {
    this.current['conversation'].add(obj);
    _convo.add(this.current);
    await Future.delayed(Duration(milliseconds: 600));
    this.scrollController.animateTo(this.scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 700), curve: Curves.fastLinearToSlowEaseIn);
  }
  updateStatus(List convo,Map newData)
  {
    convo[convo.length - 1] = newData;
    this.current['conversation'] = convo;
    this._convo.add(this.current);
  }
  updateMessageId(List toUpdate, int id){
    toUpdate[toUpdate.length-1]['id'] = id;
    this.current['conversation'] = toUpdate;
    _convo.add(this.current);
  }
  sendServer(sender, senderPicture ,customerId,storeId,storeOwnerId,senderType,message,{List toUpdate, List images}) async {
    try{
      Map body = {
        "customer_id" : "$customerId",
        "store_id" : "$storeId",
        "store_owner_id" : "$storeOwnerId",
        "sender_type" : "$senderType",

      };
      if(images.length > 0){
        body['photos'] = images.toString();
      }
      if(message != ""){
        body['message'] = "$message";
      }
      final respo =  await http.post("$url/v1/addMessage",headers: {
        "accept" : "application/json",
      },body: body);
      var data = json.decode(respo.body);
      print('MESSAGE from SERVER : $data');
      if(respo.statusCode == 200){
        if(toUpdate.length - 1 == 0)
        {
          this.updateMessageId(toUpdate, int.parse(data['details']['last_convo']['id'].toString()));
          await updateStatus(toUpdate, data['details']['last_convo']);
          messageListener.fullAppend(data['details']);
          for(var token in data['details']['recipient_tokens']){
            Firebase().messageSend(
                token['fcm_token'],
                sender,
                message,
                data['details']['last_convo']['chat_room_id'],
                senderPicture,
                user_details.id,
                data['details']['last_convo']['id'],
                data['details']['last_convo']['created_at'],
              images: images
            );
          }
          messageListener.updateChatroomId(data['details']['last_convo']['chat_room_id']);
        }else{
          data['data']['sender_id'] = int.parse(data['data']['sender_id'].toString());
          await updateStatus(toUpdate, data['data']);
          messageListener.updateChatroomId(data['data']['chat_room_id']);
          messageListener.updateConvo(data['data']['chat_room_id'], {
            "id" : int.parse(data['data']['id'].toString()),
            "chat_room_id" : int.parse(data['data']['chat_room_id'].toString()),
            "sender_id" : int.parse(data['data']['sender_id'].toString()),
            "sender_type" : int.parse(data['data']['sender_type'].toString()),
            "message" : "${data['data']['message']}",
            "created_at" : "${data['data']['created_at']}",
            "images" : data['data']['images'],
          });
          await Auth().getFCMTokens(customerId == user_details.id ? storeOwnerId : customerId).then((value) {
            if(value != null){
              for(var token in value){
                Firebase().messageSend(
                    token['fcm_token'],
                    sender,
                    message,
                    data['data']['chat_room_id'],
                    senderPicture,
                    user_details.id,
                    data['data']['id'],
                    data['data']['created_at'],
                    images: data['data']['images']
                );
              }
            }
          });
          messageListener.updateChatroomId(data['data']['chat_room_id']);
        }
        return true;
      }
      return false;
    }catch(e){
      print("ERROR $e");
      return false;
    }
  }
  getConvo({customerId,storeId,storeOwnerId}) async {
    try{
      final respo = await http.post("$url/v1/getChatConvo",headers: {
        "accept" : "application/json"
      },body: {
        "customer_id" : "$customerId",
        "store_id" : "$storeId",
        "store_owner_id" : "$storeOwnerId",
        "user_id" : "${user_details.id}"
      });
      var data = json.decode(respo.body);
      print("DATA : $data");
      if(respo.statusCode == 200) {
        this.updateAll(obj: data['data']);
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
  String format(String date) {
    DateTime parsed;
    if(date.contains('T')){
      parsed = DateTime.parse("${date.split("T")[0]}").add(Duration(hours: 8));
    }else{
      parsed = DateTime.parse("${date.split(" ")[0]}").add(Duration(hours: 8));
    }

    if(this.isToday(parsed)){
//      return "${parsed.toString() == DateTime.now().toString().split(' ')[0]}";
      return "Today at ${DateFormat().add_jms().format(DateTime.parse(date).add(Duration(hours: 8)))}";
      return DateFormat().add_jms().format(parsed);
    }else if(this.isYesterday(parsed)){
      return "Yesterday at ${DateFormat().add_jms().format(DateTime.parse(date).add(Duration(hours: 8)))}";
    }
    return DateFormat("yMMMMd").add_jms().format(parsed);
    return "NOT TOdAY $date";
    DateFormat().format(DateTime.parse(date));
  }
  bool isToday(DateTime date) {
    if(date.difference(DateTime.now()).inDays != 0){
      return false;
    }
    return true;
  }
  bool isYesterday(DateTime date){
    if(DateTime.now().subtract(Duration(days: 1)).difference(date).inDays != 0){
      return false;
    }
    return true;
  }
}

ConvoListener convoListener = ConvoListener();