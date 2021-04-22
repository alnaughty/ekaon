import 'dart:io';
import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/services/position_listener.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math' show cos, sqrt, asin;

class Distancer {
  Future<bool> isWithin({double latitude, double longitude}) async {
    var x = await geoTranslate(latitude: myPosition.current.latitude, longitude: myPosition.current.longitude);
    var y = await geoTranslate(latitude: latitude, longitude: longitude);
    if(y.contains(x) || x.contains(y)){
      return true;
    }
    return false;
  }
  Future<String> geoTranslate({double latitude, double longitude, bool isFull = false}) async{
    Coordinates _coordinates = new Coordinates(latitude, longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(_coordinates);
    var first = addresses.first;
    if(!isFull){
      return first.locality;
    }else{
      return first.addressLine;
    }
  }

  Future<String> getDifference({Coordinates chosenCoordinate, Coordinates storeCoordinate}) async {
    double distance = await Geolocator().distanceBetween(storeCoordinate.latitude, storeCoordinate.longitude, chosenCoordinate.latitude, chosenCoordinate.longitude);
    String inKm = (distance/1000).toStringAsFixed(2);
    return inKm;
  }
  Future<Map> getCurrentLocation() async {
    Map data;
    if(myPosition.current != null){
      var address = await geoTranslate(latitude: myPosition.current.latitude, longitude: myPosition.current.longitude,isFull: true);
      data = {
        "address": address,
        "longitude" : myPosition.current.longitude,
        "latitude" : myPosition.current.latitude
      };
      return data;
    }else{
      var geolocator = await Geolocator().getCurrentPosition();
      myPosition.manualUpdate(geolocator);
      var address = await geoTranslate(longitude: geolocator.longitude,latitude: geolocator.latitude,isFull: true);
      data = {
        "address" : address,
        "longitude" : geolocator.longitude,
        "latitude" : geolocator.latitude,
      };
      return data;
    }
  }

  Future<Position> getExclusiveLocation() async {
    var geolocator = await Geolocator().getCurrentPosition();
    return geolocator;
  }
}

Distancer distancer = Distancer();