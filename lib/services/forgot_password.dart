import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/services/authentication.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordAuth {
  Future sendEmail(email) async {
    try{
      final respo = await http.post("$url/send",headers: {
        "Accept" : "application/json"
      }, body: {
        "email" : email
      });
      var data = json.decode(respo.body);
      print(data);
      Fluttertoast.showToast(msg: "${data['message']}");
      if(respo.statusCode == 200){
        return true;
      }
      return false;
    }catch(e){
      Fluttertoast.showToast(msg: "Error $e");
      return false;
    }
  }

  Future verifyCode(code) async {
    try{
      final respo = await http.post("$url/verify",headers: {
        "Accept" : "application/json"
      }, body: {
        "code" : code,
      });
      var data = json.decode(respo.body);
      Fluttertoast.showToast(msg: "${data['message']}");
      print("CODE DATA : $data");
      if(respo.statusCode == 200){
        Fluttertoast.showToast(msg: "Code verified");
        return data;
      }else if(respo.statusCode == 419){
        Fluttertoast.showToast(msg: "Code expired");
        return data;
      }
      Fluttertoast.showToast(msg: "${data['message']}");
      return null;
    }catch(e){
      Fluttertoast.showToast(msg: "Error $e");
      return null;
    }
  }

  Future resetPassword(email, newPassword,context) async{
    try{
      final respo = await http.post("$url/pass_reset",headers: {
        "Accept" : "application/json"
      }, body: {
        "email": email,
        "password" : newPassword
      });
      var data = json.decode(respo.body);
      print(respo.statusCode);
      Fluttertoast.showToast(msg: "${data['message']}");
      if(respo.statusCode == 200){
        print("Logging in");
        await Auth().login(context, email, newPassword,true);
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
}