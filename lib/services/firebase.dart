

import 'dart:convert';
import 'dart:io';
import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/services/convo_listener.dart';
import 'package:ekaon/services/message_listener.dart';
import 'package:ekaon/services/new_message_listener.dart';
import 'package:ekaon/services/order_listener.dart';
import 'package:ekaon/services/order_notifier.dart';
import 'package:ekaon/services/store.dart';
import 'package:ekaon/services/store_orders_listener.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ekaon/global/interrupts.dart';
import 'package:ekaon/global/variables.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Firebase {
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  FirebaseAnalytics analytics = FirebaseAnalytics();
  Future getFcmToken() async {
    fcmToken = await _firebaseMessaging.getToken();
  }
  Future messageHandler(Map message, context,{bool onMessage = false, bool isSimulator = false}) async {
    print("Firebase Data : $message");
    print("Simulator : $isSimulator");
    if(Platform.isAndroid){
      if(messageListener.getCurrentChatroomId() != int.parse(message['data']['chatroom_id'].toString())){
        if(onMessage){
          Interrupts().showMessageFlush(context,sender: message['notification']['title'],message: message['notification']['body'],picture: message['data']['picture']);
        }
        if(messageListener.hasFetched()){
          messageListener.updateConvo(int.parse(message['data']['chatroom_id'].toString()), {
            'id' : int.parse(message['data']['id'].toString()),
            "message" : message['data']['message'],
            "sender_id" : int.parse(message['data']['sender_id']),
            'created_at' : message['data']['created_at'],
            "images" : json.decode(message['data']['images']),
          });
          messageListener.updateCount(newCount: messageListener.getChatroomCount(int.parse(message['data']['chatroom_id'].toString())) + 1,chatroomId: int.parse(message['data']['chatroom_id']));
        }else{
          newMessageCounter.updateCount(newMessageCounter.current + 1);
        }
      }else{
        if(message['data']['new_message'] == null){
          await messageListener.seen(int.parse(message['data']['chatroom_id'].toString()));
          await convoListener.appendNewConvo(obj: {
            'id' : int.parse(message['data']['id'].toString()),
            'chat_room_id' : int.parse(message['data']['chatroom_id']),
            'sender_id' : int.parse(message['data']['sender_id']),
            'message' : message['data']['message'],
            'images' : json.decode(message['data']['images']),
            'created_at' : message['data']['created_at']
          });
          await Future.delayed(Duration(milliseconds: 600));
          convoListener.scrollController.animateTo(convoListener.scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 700), curve: Curves.fastLinearToSlowEaseIn);
        }else{
          await messageListener.fullAppend(message['data']['new_message']);
          newMessageCounter.updateCount(newMessageCounter.current + 1);
        }
      }
    }else{
      if(messageListener.getCurrentChatroomId() != int.parse(message['chatroom_id'].toString())){
        if(onMessage){
          showMessage(isSimulator, onMessage, context, message);
        }
        if(messageListener.hasFetched()){
          if(isSimulator){
            messageListener.updateConvo(int.parse(message['chatroom_id'].toString()), {
              "id" : int.parse(message['id'].toString()),
              "message" : message['message'],
              "sender_id" : int.parse(message['sender_id']),
              'created_at' : message['created_at'],
              'images' : json.decode(message['images'])
            });
          }else{
            messageListener.updateConvo(int.parse(message['chatroom_id'].toString()), {
              "id" : int.parse(message['id'].toString()),
              "message" : message['message'],
              "sender_id" : int.parse(message['sender_id']),
              'created_at' : message['created_at'],
              'images' : json.decode(message['images'])
            });
          }
          messageListener.updateCount(newCount: messageListener.getChatroomCount(int.parse(message['chatroom_id'].toString())) + 1,chatroomId: int.parse(message['chatroom_id']));
        }else{
          newMessageCounter.updateCount(newMessageCounter.current + 1);
        }

      }else{
        if(message['new_message'] == null){
          await messageListener.seen(message['chatroom_id']);
          if(isSimulator){
            convoListener.appendNewConvo(obj: {
              "id" : int.parse(message['id'].toString()),
              'chat_room_id' : int.parse(message['chatroom_id']),
              'sender_id' : int.parse(message['sender_id']),
              'message' : message['message'],
              'created_at' : message['created_at'],
              'images' : json.decode(message['images'])
            });
          }else{
            convoListener.appendNewConvo(obj: {
              "id" : int.parse(message['id'].toString()),
              'chat_room_id' : int.parse(message['chatroom_id']),
              'sender_id' : int.parse(message['sender_id']),
              'message' : message['message'],
              'created_at' : message['created_at'],
              'images' : json.decode(message['images'])
            });
          }
        }else{
          await messageListener.fullAppend(message['data']['new_message']);
          newMessageCounter.updateCount(newMessageCounter.current + 1);
        }
      }
    }
  }
  showMessage(bool isSimulator, bool onMessage,context,message){
    if(isSimulator){
      Interrupts().showMessageFlush(context,sender: message['notification']['title'],message: message['notification']['body'],picture: message['picture']);
    }else{
      Interrupts().showMessageFlush(context,sender: message['aps']['alert']['title'],message: message['aps']['alert']['body'],picture: message['picture']);
    }
  }
  bool simulCheck(bool isSimul) {
    return isSimul;
  }
  Future pushNotificationListen(context) async {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if(Platform.isAndroid){
          if(message['data']['purchasing'] != null && message['data']['purchasing'].toString() == "true"){
            Interrupts().showClickableFlush(context, message: message['notification']['body'], title: message['notification']['title']);
            storeOrderNotifierListener.update(storeOrderNotifierListener.current + 1);
            if(myStoreDetails != null){
              await Store().orders(store_id: myStoreDetails['id']).then((value) {
                if(value != null){
                  storeOrdersListener.updateData(value);
                }
              });
            }
          }
          if(message['data']['is_message'] != null && message['data']['is_message'].toString() == "true") {
            await this.messageHandler(message, context, onMessage: true);
          }
          if(message['data']['type'] != null && message['data']['type'] == "order_update"){
            if(!isAtOrderDetails){
              Interrupts().showClickableFlush(context, message: message['notification']['body'], title: message['notification']['title'],isTransaction: true);
            }
            orderListener.updateStatus(orderId: int.parse(message['data']['order_id'].toString()), status: int.parse(message['data']['status'].toString()));
          }
        }else{
          if(message['purchasing'] != null && message['purchasing'].toString() == "true"){
            if(message['aps'] == null){
              Interrupts().showClickableFlush(context, message: message['notification']['body'], title: message['notification']['title']);
            }else{
              Interrupts().showClickableFlush(context, message: message['aps']['alert']['body'], title: message['aps']['alert']['title']);
            }
            storeOrderNotifierListener.update(storeOrderNotifierListener.current + 1);
            if(myStoreDetails != null){
              await Store().orders(store_id: myStoreDetails['id']).then((value) {
                if(value != null){
                  storeOrdersListener.updateData(value);
                }
              });
            }
          }
          if(message['is_message'] != null && message['is_message'].toString() == "true"){
            await this.messageHandler(message, context,onMessage: true, isSimulator: message['aps'] == null);
          }
          if(message['type'] != null && message['type'] == "order_update"){
            if(!isAtOrderDetails){
              if(simulCheck(message['aps'] == null)){
                Interrupts().showClickableFlush(context, message: message['notification']['body'], title: message['notification']['title'], isTransaction: true);
              }else{
                Interrupts().showClickableFlush(context, message: message['aps']['alert']['body'], title: message['aps']['alert']['title'],isTransaction: true);
              }
            }
            orderListener.updateStatus(orderId: int.parse(message['order_id'].toString()), status: int.parse(message['status'].toString()));
          }
        }
      },
      onResume: (Map<String, dynamic> message) async {
        print("Resume : $message");
        if(Platform.isAndroid){
          if(message['data']['purchasing'] != null && message['data']['purchasing'].toString() == "true"){
            storeOrderNotifierListener.update(storeOrderNotifierListener.current + 1);
            if(myStoreDetails != null){
              await Store().orders(store_id: myStoreDetails['id']).then((value) {
                if(value != null){
                  storeOrdersListener.updateData(value);
                }
              });
            }
          }
          if(message['data']['is_message'] != null && message['data']['is_message'].toString() == "true") {
            await this.messageHandler(message, context);
          }
          if(message['data']['type'] != null && message['data']['type'] == "order_update"){
            orderListener.updateStatus(orderId: int.parse(message['order_id'].toString()), status: int.parse(message['status'].toString()));
          }
        }else{
          if(message['purchasing'] != null && message['purchasing'].toString() == "true"){
            storeOrderNotifierListener.update(storeOrderNotifierListener.current + 1);
            if(myStoreDetails != null){
              await Store().orders(store_id: myStoreDetails['id']).then((value) {
                if(value != null){
                  storeOrdersListener.updateData(value);
                }
              });
            }
          }
          if(message['is_message'] != null && message['is_message'].toString() == "true"){
            await this.messageHandler(message, context, isSimulator: message['aps'] == null);
          }
          if(message['type'] != null && message['type'] == "order_update"){
            orderListener.updateStatus(orderId: int.parse(message['order_id'].toString()), status: int.parse(message['status'].toString()));
          }
        }
        return;
      },

      onLaunch: (Map<String, dynamic> message) async {
        print("on launch : $message");
        if(Platform.isAndroid){
          if(message['data']['purchasing'] != null && message['data']['purchasing'].toString() == "true"){
            storeOrderNotifierListener.update(storeOrderNotifierListener.current + 1);
            if(myStoreDetails != null){
              await Store().orders(store_id: myStoreDetails['id']).then((value) {
                if(value != null){
                  storeOrdersListener.updateData(value);
                }
              });
            }
          }
          if(message['data']['is_message'] != null && message['data']['is_message'].toString() == "true") {
            await this.messageHandler(message, context);
          }
          if(message['data']['type'] != null && message['data']['type'] == "order_update"){
            orderListener.updateStatus(orderId: int.parse(message['order_id'].toString()), status: int.parse(message['status'].toString()));
          }
        }else{
          await this.messageHandler(message, context, isSimulator: message['aps'] == null);
          if(message['purchasing'] != null && message['purchasing'].toString() == "true"){
            storeOrderNotifierListener.update(storeOrderNotifierListener.current + 1);
            if(myStoreDetails != null){
              await Store().orders(store_id: myStoreDetails['id']).then((value) {
                if(value != null){
                  storeOrdersListener.updateData(value);
                }
              });
            }
          }
          if(message['is_message'] != null && message['is_message'].toString() == "true"){
            await this.messageHandler(message, context, isSimulator: message['aps'] == null);
          }
          if(message['type'] != null && message['type'] == "order_update"){
            orderListener.updateStatus(orderId: int.parse(message['order_id'].toString()), status: int.parse(message['status'].toString()));
          }
        }
        return;
      }
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
    });
  }
  Future sendNotification(ownerFcmToken) async {
    String fullname = "${user_details.first_name[0].toUpperCase()}${user_details.first_name.substring(1)} ${user_details.last_name[0].toUpperCase()}${user_details.last_name.substring(1)}";
    print(ownerFcmToken);
    print("Sending....");
    await _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body':
            'Hi! Mr./Mrs./Ms. $fullname wants to purchase your product',
            'title': 'Purchasing your product'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'purchasing' : true
          },
          'to': "$ownerFcmToken",
        },
      ),
    );
  }
  Future messageSend(fcmToken,sender,message,chatroomId,picture,senderId,messageId,date,{List images}) async {

    await _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': images.length > 0 ? "Sent a photo" : message,
            'title': sender
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'is_message' : 'true',
            'message' : message == "" ? null : "$message",
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'chatroom_id' : chatroomId.toString(),
            'picture' : "$picture",
            'id' : "$messageId",
            'sender_id' : "$senderId",
            "created_at" : "$date",
            "images" : images,
          },
          'to': "$fcmToken",
        },
      ),
    );
  }
  Future newMessageSend(fcmToken,sender,message,data, List image) async {
    await _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': message,
            'title': sender
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'is_message' : 'true',
            'message' : '$message',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'new_message' : '$data',
            'images' : image
          },
          'to': "$fcmToken",
        },
      ),
    );
  }
  Future sendOrderNotification(ownerFcmToken, body, title, orderId,status) async {
    await _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': body,
            'title': title
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'type' : "order_update",
            'status' : '$status',
            'order_id' : '$orderId'
          },
          'to': "$ownerFcmToken",
        },
      ),
    );
  }
}