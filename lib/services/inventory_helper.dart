import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InventoryHelper{
  final List data;
  InventoryHelper({@required this.data});
  List productIds = [];
  getProductIds() {
    for(var items in data){
      for(var product in items['details']){
        if(!productIsPresent(product['product_id'])){
          productIds.add({
            "product_id" : product['product_id'],
            "sold" : product['quantity'],
            'total' : product['sub_total'],
            "time" : items['updated_at'],
            "product_name" : product['product']['name'],
            "image" : product['product']['images'],
            "color" : randomColorGenerator(),
            "breakdown" : [{
              "order_id" : items['id'],
              'product_id' : product['product_id'],
              "time" : items['updated_at'],
              "qty" : product['quantity'],
              "price" : product['sub_total']
            }]
          });
        }else{
          productIds.where((element) => element['product_id'] == product['product_id']).toList()[0]['sold'] += product['quantity'];
          productIds.where((element) => element['product_id'] == product['product_id']).toList()[0]['total'] += product['sub_total'];
          productIds.where((element) => element['product_id'] == product['product_id']).toList()[0]['breakdown'].add({
            "order_id" : items['id'],
            'product_id' : product['product_id'],
            "time" : items['updated_at'],
            "qty" : product['quantity'],
            "price" : product['sub_total']
          });
        }
      }
    }
    return this.productIds;
  }

  Map getGraph({List data, DateTime date}){
    DateTime threeHoursAgo = date.subtract(Duration(hours: 3));
    List threeHAgo = data.where((element) {
      DateTime elementalTime = DateTime.parse(element['time']).add(Duration(hours: 8));
      return elementalTime.isBefore(threeHoursAgo);
    }).toList();
    List currentData = data.where((element) {
      DateTime elementalTime = DateTime.parse(element['time']).add(Duration(hours: 8));
      return elementalTime.isAfter(threeHoursAgo);
    }).toList();
    Map f =
      {
        "late" : threeHAgo,
        "current" : currentData
      };
    print("To check : $f");
    return f;
  }
  breakDownBreaker(List source) {
    List broken = [];
    for(var data in source){
      broken += data['breakdown'];
    }
    return broken;
  }
  getStatistical(List source, {String type, int statType}) {
    //type = time, qty, price
    //statType = 0=> min, 1=>median, 2=>max
    List data = this.breakDownBreaker(source);
    if(statType == 0){
      return getMin(data, type);
    }else if(statType == 1){
      return getMedian(data, type);
    }else{
      return getMax(data, type);
    }
  }

  List traverse() {
    List dd = [];
    List<int> product_ids = [];
    for(var order in this.data){
      for(var item in order['cart']['details']){
        if(!product_ids.contains(item['product_id'])){
          product_ids.add(item['product_id']);
          dd.add({
            "name" : item['product']['name'],
            'quantity' : item['quantity'],
            'total' : item['total'],
          });
        }else{
          dd[product_ids.indexOf(item['product_id'])]['quantity'] += item['quantity'];
          dd[product_ids.indexOf(item['product_id'])]['total'] += item['total'];
        }
      }
    }
    return dd;
  }
//  double getSpot(List source, String type, Map toCompare){
//    List dd = this.breakDownBreaker(source);
//    if(type == 'price'){
//      dd.sort((a,b){
//        double aPrice = double.parse(a['price'].toString());
//        double bPrice = double.parse(b['price'].toString());
//        return aPrice.compareTo(bPrice);
//      });
////      return dd.indexOf(toCompare);
//    }else{
//      dd.sort((a,b){
//        DateTime aDate = DateTime.parse(a['time']);
//        DateTime bDate = DateTime.parse(b['time']);
//        return aDate.compareTo(bDate);
//      });
////      return dd.indexOf(toCompare);
//    }
//
//  }
  getMax(List data, String type){
    if(type == "time"){
      data.sort((a,b){
        DateTime aDate = DateTime.parse(a['time']).add(Duration(hours: 8));
        DateTime bDate = DateTime.parse(b['time']).add(Duration(hours: 8));
        return aDate.compareTo(bDate);
      });
      return DateTime.parse(data[data.length - 1]['$type']).add(Duration(hours: 8));
//      return DateFormat().add_jm().format(DateTime.parse(data[data.length - 1]['$type']).add(Duration(hours: 8)));
    }else if(type == 'qty'){
      data.sort((a,b){
        int aDate = int.parse(a['$type'].toString());
        int bDate = int.parse(b['$type'].toString());
        return aDate.compareTo(bDate);
      });
    }else{
      data.sort((a,b){
        double aDate = double.parse(a['$type'].toString());
        double bDate = double.parse(b['$type'].toString());
        return aDate.compareTo(bDate);
      });
    }

    return data[data.length - 1]['$type'];
  }
  getMedian(List data, String type){
    if(type == "time"){
      data.sort((a,b){
        DateTime aDate = DateTime.parse(a['$type']);
        DateTime bDate = DateTime.parse(b['$type']);
        return aDate.compareTo(bDate);
      });
      int medIndex = data.length~/2;
      return DateFormat().add_jm().format(DateTime.parse(data[medIndex]['$type']).add(Duration(hours: 8)));
    }else if(type == 'qty'){
      data.sort((a,b){
        int aDate = int.parse(a['$type'].toString());
        int bDate = int.parse(b['$type'].toString());
        return aDate.compareTo(bDate);
      });
    }else{
      data.sort((a,b){
        double aDate = double.parse(a['$type'].toString());
        double bDate = double.parse(b['$type'].toString());
        return aDate.compareTo(bDate);
      });
    }
    int medIndex = data.length~/2;
    return data[medIndex]['$type'];
  }
  getMin(List data, String type){
    if(type == "time"){
      data.sort((a,b){
        DateTime aDate = DateTime.parse(a['$type']);
        DateTime bDate = DateTime.parse(b['$type']);
        return bDate.compareTo(aDate);
      });
      return DateFormat().add_jm().format(DateTime.parse(data[data.length - 1]['$type']).add(Duration(hours: 8)));
    }else if(type == 'qty'){
      data.sort((a,b){
        int aDate = int.parse(a['$type'].toString());
        int bDate = int.parse(b['$type'].toString());
        return bDate.compareTo(aDate);
      });
    }else{
      data.sort((a,b){
        double aDate = double.parse(a['$type'].toString());
        double bDate = double.parse(b['$type'].toString());
        return bDate.compareTo(aDate);
      });
    }

    return data[data.length - 1]['$type'];
  }
  Color randomColorGenerator() {
    Color randomVal = Colors.primaries[math.Random().nextInt(Colors.primaries.length)];
    return randomVal;
  }
  double getTotalAmount() {
    double amount = 0.0;
    for(var items in this.getProductIds()){

      amount += items['total'];
    }
    return amount;
  }
  int getTotalSold() {
    int sold = 0;
    for(var items in this.getProductIds()){
      sold += items['sold'];
    }
    return sold;
  }
  bool productIsPresent(productId){
    for(var product in productIds){
      if(product['product_id'] == productId){
        return true;
      }
    }
    return false;
  }
  getProductBuyers(int productId) {
    List buyers = [];
//    for(var item in data){
//      Map productData;
//      for(var product in item['details']){
//        if(product['product_id'] == productId){
//          productData = product;
//        }
//      }
////      print("Product Data : $productData");
//      if(buyerIsPresent(item['orderer']['id'], buyers))
//      {
//        buyers.add({
//          "details" : item['orderer'],
//          "total_sold" : buyers.where((element) => element['details']['id'] == item['orderer']['id']).toList()[0]['total_sold'] += productData['quantity'],
//          "total_payment" : buyers.where((element) => element['details']['id'] == item['orderer']['id']).toList()[0]['total_payment'] += productData['sub_total'],
//        });
//      }else{
//        try{
//          buyers.add({
//            "details" : item['orderer'],
//            "total_sold" : productData['quantity'],
//            "total_payment" : productData['sub_total']
//          });
//        }catch(e){
//          buyers.add({
//            "details" : item['orderer'],
//            "total_sold" : 0,
//            "total_payment" : 0
//          });
//        }
//      }
//    }
    return buyers;
  }
  bool buyerIsPresent(buyerId, List buyers){
    for(var buyer in buyers){
      if(buyer['id'] == buyerId){
        return true;
      }
    }
    return false;
  }
}