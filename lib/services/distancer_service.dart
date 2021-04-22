import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/services/distancer.dart';
import 'package:ekaon/services/position_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:math' show cos, sqrt, asin;

class DistanceService {
  Future<String> getRouteCoordinates(LatLng l1, LatLng l2)async{
    try{
      String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=$apiKey";
      var response =  await http.get(url);
      Map data = json.decode(response.body);
      return data['routes'][0]["overview_polyline"]["points"].toString();
    }catch(e){
      print("ERROR : $e");
      return null;
    }
  }
  Set<Polyline> createRoute(String encondedPoly, LatLng latLng) {
    final Set<Polyline> _polyLines = {};
    _polyLines.add(Polyline(
        polylineId: PolylineId(latLng.toString()),
        width: 4,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.red));
    return _polyLines;
  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  Future<double> calculateDistance(Position me,{Position destination}) async {
    try{
      print(me);
      if(myPosition != null && destination != null){
        Position _northeastCoordinates;
        Position _southwestCoordinates;
        List<LatLng> polylineCoordinates = [];
        double miny = (me.latitude <= destination.latitude)
            ? me.latitude
            : destination.latitude;
        double minx = (me.longitude <= destination.longitude)
            ? me.longitude
            : destination.longitude;
        double maxy = (me.latitude <= destination.latitude)
            ? destination.latitude
            : me.latitude;
        double maxx = (me.longitude <= destination.longitude)
            ? destination.longitude
            : me.longitude;
        _southwestCoordinates = Position(latitude: miny, longitude: minx);
        _northeastCoordinates = Position(latitude: maxy, longitude: maxx);
        polylineCoordinates = await this.getPolyLineCoordinates(me, destination);
        double totalDistance = 0.0;
        for (int i = 0; i < polylineCoordinates.length - 1; i++) {
          totalDistance += _coordinateDistance(
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude,
            polylineCoordinates[i + 1].latitude,
            polylineCoordinates[i + 1].longitude,
          );
        }
        double result = double.parse(totalDistance.toStringAsFixed(2));
        if(result == 0.0){
          return double.parse(await distancer.getDifference(chosenCoordinate: Coordinates(me.latitude, me.longitude), storeCoordinate: Coordinates(destination.latitude, destination.longitude)));
        }
        return result;
      }
      return null;
    }catch(e){
      print("Error : $e");
      return null;
    }
  }
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
  Future<List<LatLng>> getPolyLineCoordinates(Position start, Position destination) async {
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      apiKey, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    return polylineCoordinates;
  }
}
DistanceService distanceService = DistanceService();