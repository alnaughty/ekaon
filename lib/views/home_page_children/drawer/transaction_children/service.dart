import 'package:ekaon/services/distancer.dart';
import 'package:ekaon/services/distancer_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';

class Trans{
  double distancia = 0.0;
  double alt_distance = 0.0;
  final Coordinates orderer;
  final Coordinates store;
  Trans({@required this.orderer,@required this.store});
  Future<double> getTotal(Map data) async {
    double total = 0.0;
    for(var x in data['details'])
    {
      total+= x['sub_total'];
    }
//    await distanceSetter();
    return total + (this.distancia * data['store']['delivery_charge_per_km']);
  }

//  Future<void> distanceSetter({bool real = false}) async {
//    try{
//      double dd = await distanceService.calculateDistance(destination: Position(latitude: this.store.latitude, longitude: this.store.longitude));
////      double dd = double.parse(await distancer.getDifference(chosenCoordinate: this.orderer, storeCoordinate: this.store));
//      if(dd >= 1 && !real){
//        this.distancia = dd;
//      }
//      this.alt_distance = dd;
//    }catch(e){
//      print("ERROR $e");
//    }
//  }
//  Future<double> getDistance() async {
//    await distanceSetter(real: true);
//    return this.alt_distance;
//  }
//  Future<double> getCharge(double storeCharge) async {
//    await distanceSetter();
//    return this.distancia * storeCharge;
//  }
}