import 'package:http/http.dart';
//import 'package:pusher/pusher.dart' as ThePusher;
//import 'package:pusher_websocket_flutter/pusher.dart';

//class MyPusher{
//  Future initConnection() async {
//    try{
//      await Pusher.init('de64e7f089b97fe57c12', PusherOptions(cluster: "ap1",));
//    }catch(e){
//      print(e);
//    }
//  }
//
//  Future sendData({int orderId, int status}) async {
//    ThePusher.PusherOptions options = new ThePusher.PusherOptions(encrypted: true);
//    ThePusher.Pusher _pusher = new ThePusher.Pusher("1076547", "de64e7f089b97fe57c12", "c07fd6adadae66866572", options);
//    Map data = {
//      "order_id" : orderId,
//      "status" : status
//    };
//    ThePusher.Response response = await _pusher.trigger(['ekaon-channel'], '$orderId', data);
//  }
//}