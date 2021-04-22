import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StringFormatter{
  final String string;
  StringFormatter({this.string});
  String titlize() {
    return this.string[0].toUpperCase() + this.string.substring(1);
  }

  String time(){
    return DateFormat().add_jm().format(DateTime.parse(this.string));
  }

  Color stringToColor(){
    Color color = Color(int.parse(this.string.substring(6).replaceAll(")", "")));
//    Color color = this.string as Color;
    return color;
  }

  String orderStatus(int status, bool isDelivery){
    if(status == 0){
      return "Pending";
    }else if(status == 1){
      return "Preparing";
    }else if(status == 2){
      return isDelivery ? "Delivering" : "Ready for pickup";
    }else if(status == 3){
      return "Complete";
    }else if(status == -1){
      return "Rejected";
    }else{
      return "Cancelled";
    }
  }
}