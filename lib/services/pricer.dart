import 'package:ekaon/services/distancer.dart';
import 'package:ekaon/services/distancer_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';

class PriceChecker {

  double calculateTotal(double subTotal, {@required bool isDelivery, @required double deliveryCharge}) {
    double total = subTotal;
    if(isDelivery){
        total += deliveryCharge;
    }else{
        total = subTotal;
    }
    return total;
  }
  double calculateSubtotal({Map data}){
    double total = 0.0;
    for(var product in data['details']){
      total += double.parse(product['total'].toString());
      if(product['selected_variations'] != null && product['selected_variations'].length > 0){
        for(var variation in product['selected_variations']){
          total += double.parse(variation['details']['price'].toString()) * double.parse(product['quantity'].toString());
        }
      }
    }

    return total;
  }
  double calculateProductTotal(Map data){
    double total = double.parse(data['total'].toString());
    for(var selected in data['selected_variations']){
      total += double.parse(selected['details']['price'].toString()) * double.parse(data['quantity'].toString());
    }
    return total;
  }
//  getTotal({@required Map storeData,@required Map customerData, @required double subTotal,@required bool isDelivery}) async {
//    double deliveryCharge = 0.0;
//    double distance = 0.0;
//    distance = await distanceService.calculateDistance(,destination: Position(
//      latitude: double.parse(storeData['latitude'].toString()),
//      longitude: double.parse(storeData['longitude'].toString())
//    ));
////    var dd = await distancer.getDifference(
////        storeCoordinate: new Coordinates(storeData['latitude'], storeData['longitude']),
////        chosenCoordinate: new Coordinates(customerData['latitude'], customerData['longitude']));
////    distance = double.parse(dd);
//      deliveryCharge = distance * double.parse(storeData['delivery_charge_per_km'].toString());
//      if(deliveryCharge >= 1){
//        deliveryCharge = distance * double.parse(storeData['delivery_charge_per_km'].toString());
//      }else{
//        deliveryCharge = 0.0;
//      }
//      return this.calculateTotal(subTotal, isDelivery: isDelivery, deliveryCharge: deliveryCharge);
//  }
//  Future<double> getDeliveryCharge({@required Map storeData,@required Map customerData, @required double subTotal,@required bool isDelivery}) async {
//    double deliveryCharge = 0.0;
//    double distance = 0.0;
//    distance = await distanceService.calculateDistance(
//      destination: Position(
//          latitude: double.parse(storeData['latitude'].toString()),
//          longitude: double.parse(storeData['longitude'].toString())
//      )
//    );
////    var dd = await distancer.getDifference(
////        storeCoordinate: new Coordinates(storeData['latitude'], storeData['longitude']),
////        chosenCoordinate: new Coordinates(customerData['latitude'], customerData['longitude']));
////    distance = double.parse(dd);
//    deliveryCharge = distance * double.parse(storeData['delivery_charge_per_km'].toString());
//    if(deliveryCharge >= 1){
//      deliveryCharge = distance * double.parse(storeData['delivery_charge_per_km'].toString());
//    }else{
//      deliveryCharge = 0.0;
//    }
//    return deliveryCharge;
//  }
}
PriceChecker priceChecker = PriceChecker();