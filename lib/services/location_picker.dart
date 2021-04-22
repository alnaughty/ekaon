import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/services/distancer.dart';
import 'package:ekaon/services/position_listener.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyLocationPicker {
  Future<LocationResult> show(context) async {
    try{
      LocationResult result = await showLocationPicker(
        context,
        apiKey,
        resultCardConfirmIcon: Icon(Icons.check),
        initialCenter: LatLng(myPosition.current != null && myPosition.current.latitude != null ?myPosition.current.latitude: 0.0,myPosition != null && myPosition.current.longitude != null ?myPosition.current.longitude : 0.0),
        myLocationButtonEnabled: true,
        layersButtonEnabled: true,
      );
      if (result != null) {
        return result;
      }
      return null;
    }catch(e){
      Fluttertoast.showToast(msg: "Location permission is disabled, please enable.", toastLength: Toast.LENGTH_LONG);
    }
  }

  update(context) async {
    LocationResult dd = await show(context);
    return dd;
  }
}

MyLocationPicker locationPicker = MyLocationPicker();