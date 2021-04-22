

import 'dart:io';

import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/services/authentication.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/views/credentials/login_page.dart';
import 'package:ekaon/views/credentials/validate_page.dart';
import 'package:ekaon/views/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  Future readData(context) async
  {
    final prefs = await SharedPreferences.getInstance();
    var email = prefs.get('email');
    var pass = prefs.get('pass');
    if(email != null && pass != null)
    {
      savedEmail = email;
      savedPass = pass;
      Auth().login(context, email, pass, false);
    }
    else {
      await Future.delayed(Duration(milliseconds: 1500));
      Navigator.pushReplacement(context, PageTransition(child: HomePage(), type: PageTransitionType.fade));
    }
  }

  Future saveData(String password, String email) async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    prefs.setString('pass', password);
    savedEmail = email;
    savedPass = password;
    print("DONE");
  }

  Future removeData() async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
  double getAppAvailableHeight(bool keyboardActive,double currentHeight)
  {
      if(Platform.isAndroid){
        if(keyboardActive){
          return Percentage().calculate(num: currentHeight,percent: currentHeight > 700 ? 49 : 50);
        }
        return currentHeight;
      }else{
        return currentHeight;
      }
  }
}