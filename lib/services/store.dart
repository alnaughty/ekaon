import 'dart:convert';
import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/services/distancer.dart';
import 'package:ekaon/services/position_listener.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:http/http.dart' as http;

class Store{
  Future get({int page}) async {
    try{
      Map<String,dynamic> body;
      if(myPosition.current == null){
        body = null;
      }else{
        body = {
          "userLat" : "${myPosition.current.latitude} ",
          "userLong" : "${myPosition.current.longitude}"
        };
      }
      final respo = await http.post("$url/v1/storeFencing",headers: {
        "Accept" : "application/json"
      },body: body);
      var data = json.decode(respo.body);
//      print("DATA : ${data['data']}");
      if(respo.statusCode == 200) {
        return data;
      }
      return null;
    }catch(e){
      return null;
    }
  }
  Future details(toSearch) async {
    try{
      var respo = await http.get("$toSearch", headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      print("QR DATA : $data");
      Fluttertoast.showToast(msg: "${data['message']}");
      if(respo.statusCode == 200){
        return data['store_details'];
      }
      return null;
    }catch(e){
      print(e);
      Fluttertoast.showToast(msg: "$e");
      return null;
    }
  }
  Future search(text) async{
    try{
      final respo = await http.get("$url/v1/searchStore/$text",headers: {
        "Accept" : "application/json"
      });
      var data = json.decode(respo.body);
      print(data);
      if(respo.statusCode == 200) {
        List dd = [];
        for(var x in data['stores']){
          if(await distancer.isWithin(latitude: x['latitude'], longitude: x['longitude'])){
            dd.add(x);
          }
        }
        return dd;
      }
      return null;
    }catch(e){
      return null;
    }
  }

  Future create(Map body) async {
    try {
//      Map body;
//      if(chosenLoc == null){
//        body = {
//          "name": name,
//          "address": address,
//          "delivery_charge_per_km": deliveryCharge.toString(),
//        };
//      }else{
//        body = {
//          "name": name,
//          "address": address,
//          "latitude": chosenLoc.latLng.latitude.toString(),
//          "longitude": chosenLoc.latLng.longitude.toString(),
//          "delivery_charge_per_km": deliveryCharge.toString(),
//        };
//      }
      var respo = await http.post("$url/createStore", headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $token"
      }, body: body);
      var data = json.decode(respo.body);
      print("DATA : $data");
      print(respo.statusCode);
      if (respo.statusCode == 200) {

        return data;
      }
      Fluttertoast.showToast(
          msg:
          "An error has occurred,${respo.statusCode} ${respo.reasonPhrase}");
      return null;
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "$e");
      return null;
    }
  }
  Future getMyStore() async {
    try {
      final respo = await http.get("$url/store", headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        "Accept": "application/json"
      });
      var data = json.decode(respo.body);
      print("Data : $data");
      if (respo.statusCode == 200) {
        return data['store'];
      }
      Fluttertoast.showToast(
          msg: "Error ${respo.statusCode}, ${respo.reasonPhrase}");
      return null;
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error has occurred, please contact app administrator");
      return null;
    }
  }
  Future update(
      bool isAddress, address, latitude, longitude, name, data, sID) async {
    try {
      final respo = await http.post("$url/update/store",
          headers: {
            HttpHeaders.authorizationHeader: "Bearer $token",
            "Accept": "application/json"
          },
          body: isAddress
              ? {
            "s_id": sID.toString(),
            "address": address,
            "longitude": "$longitude",
            "latitude": "$latitude"
          }
              : {"s_id": sID.toString(), "$name": "$data"});
      var result = json.decode(respo.body);
      print(result);
      if (respo.statusCode == 200) {
        Fluttertoast.showToast(msg: "${result['message']}");
        return true;
      }
      Fluttertoast.showToast(
          msg: "Error ${respo.statusCode}, ${respo.reasonPhrase}");
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }
  Future changePicture(base64Image,ext,String name) async {
    try{
      final respo = await http.post("$url/upload/store/picture",headers: {
        "Accept" : "application/json",
        HttpHeaders.authorizationHeader : "Bearer $token"
      }, body: {
        "image" : "data:image/$ext;base64,$base64Image",
        "s_id" : myStoreDetails['id'].toString(),
        "name" : name
      });
      var data = json.decode(respo.body);
      print(data);
      if(respo.statusCode == 200)
      {
        Fluttertoast.showToast(msg: "${data['message']}");
        myStoreDetails['picture'] = data['details']['picture'];
        return true;
      }
      Fluttertoast.showToast(msg: "Error ${respo.statusCode}, ${respo.reasonPhrase}");
      return false;
    }catch(e){
      print("DP $e");
      return false;
    }
  }
  Future getProducts({int storeId}) async {
    try{
      final respo = await http.get("$url/v1/getProducts/$storeId",headers: {
        "Accept" : "application/json"
      });
      var data = json.decode(respo.body);
      if(respo.statusCode == 200){
        return data['products'];
      }
      return null;
    }catch(e){
      return null;
    }
  }
  Future<List> orders({store_id}) async {
    try{
      final respo = await http.get("$url/v1/storeOrders/$store_id",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      print("Orders : $data");
      if(respo.statusCode == 200){
        return data;
      }
      return null;
    }catch(e){
      print("FETCH ORDER ERROR: $e");
      return null;
    }
  }
  Future updateDeliveryState() async {
    try{

      final respo = await http.put("$url/v1/updateDeliveryState/${myStoreDetails['id']}/${myStoreDetails['hasDelivery']}",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      Fluttertoast.showToast(msg: "${data['message']}, delivery is ${myStoreDetails['hasDelivery'] == 1 ? "enabled" : "disabled"}");
      if(respo.statusCode == 200){
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
  Future updateStoreState() async {
    try{
      final respo = await http.put("$url/v1/updateStoreState/${myStoreDetails['id']}/${myStoreDetails['storeOpen']}",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      Fluttertoast.showToast(msg: "${data['message']}, store is now ${myStoreDetails['storeOpen'] == 1 ? "Open" : "Closed"}");
      if(respo.statusCode == 200){
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
  Future getStoreDeliveyState(storeId) async {
    try{
      final respo = await http.get("$url/v1/getStoreStatus/$storeId",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      if(respo.statusCode == 200){
        return data;
      }
      return null;
    }catch(e){
      print("LOCAL ERROR : $e");
      return null;
    }
  }
  
  Future getFeaturedPhotos(int storeId) async {
    try{
      final respo = await http.get("$url/v1/getFeaturedPhoto/$storeId",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      if(respo.statusCode == 200){
        return data['data'];
      }
      return null;
    }catch(e){
      print("Error $e");
      return null;
    }
  }
  Future addFeaturedPhoto(String base64, String name, String ext, int storeId, int position) async {
    try{
      final respo = await http.post("$url/v1/addFeatured/photo",headers: {
        "accept" : "application/json"
      }, body: {
        "image" : "data:image/$ext;base64,$base64",
        "position" : "$position",
        "store_id" : "$storeId",
        "name" : "$name"
      });
      var data = json.decode(respo.body);
      Fluttertoast.showToast(msg: "${data['message']}");
      if(respo.statusCode == 200){
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
  Future removeFeaturedPhoto(id) async {
    try{
      final respo = await http.delete("$url/v1/deleteFeaturedPhoto/$id",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      Fluttertoast.showToast(msg: "${data['message']}");
      if(respo.statusCode == 200){
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
}