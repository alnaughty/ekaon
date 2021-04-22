import 'dart:convert';
import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/services/preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
class User {
  Future uploadPicture(String image, String name, String ext) async{
    try{
      final respo = await http.post("$url/upload/user/picture",body: {
        "image" : "data:image/$ext;base64,$image",
        "name" : name
      },headers: {
        HttpHeaders.authorizationHeader : "Bearer $token",
      });
      var data = json.decode(respo.body);
      Fluttertoast.showToast(msg: "${data['message']}");
      if(respo.statusCode == 200){
        user_details.profile_picture = data['details']['profile_picture'];
        return true;
      }
      return false;
    }catch(e){
      print("$e");
      Fluttertoast.showToast(msg: "An error has occurred, your file may be too large.");
      return false;
    }
  }

  Future update(newEmail, newFirstName, newLast,context) async{
    try{
      final respo = await http.post("$url/updateUser", headers: {
        HttpHeaders.authorizationHeader : "Bearer $token",
        "Accept" : "application/json"
      }, body: {
        "email" : newEmail,
        "first_name" : newFirstName,
        "last_name" : newLast
      });
      var data = json.decode(respo.body);
      print("$data");
      if(respo.statusCode == 200){
        Fluttertoast.showToast(msg: "Update Success");
        Preferences().saveData(savedPass, data['update']['email']);
        return true;
      }
      Fluttertoast.showToast(msg: "Error updating, please try again later");
      return false;
    }catch(e){
      print(e);
      return false;
    }
  }
}