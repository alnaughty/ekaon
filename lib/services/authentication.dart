import 'dart:convert';
import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/model/User.dart';
import 'package:ekaon/model/contact_number.dart';
import 'package:ekaon/services/address_listener.dart';
import 'package:ekaon/services/cart.dart';
import 'package:ekaon/services/contact_number_listener.dart';
import 'package:ekaon/services/message_listener.dart';
import 'package:ekaon/services/my_product_listener.dart';
import 'package:ekaon/services/my_rated_stores_listener.dart';
import 'package:ekaon/services/new_message_listener.dart';
import 'package:ekaon/services/order_listener.dart';
import 'package:ekaon/services/order_notifier.dart';
import 'package:ekaon/services/preferences.dart';
import 'package:ekaon/services/store_orders_listener.dart';
import 'package:ekaon/services/user_profile.dart';
import 'package:ekaon/services/your_rated_products_listener.dart';
import 'package:ekaon/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';

class Auth {
  Future login(context, email, password, bool isLogin) async {
    try{
      final respo = await http.post("$url/login", body: {
        "email" : email,
        "password" : password,
        "fcm_token" : fcmToken
      }, headers: {
//        "Accept" : "application/json"
      });
      var data = json.decode(respo.body);
      print("DATA LOGIN : $data");
      if(respo.statusCode == 200) {
        token = data['data']['token'];
        user_details = UserModel.fromData(data['data']['details']);
//        userDetails = data['data']['details'];
//        print("DETAILS $userDetails");
        List liked = data['data']['details']['votes'].where((e)=> e['like_or_dislike'] == 2).toList();
        List disliked = data['data']['details']['votes'].where((e)=> e['like_or_dislike'] == 0).toList();
        favoriteStore = data['data']['details']['favorite_stores'];
        favoriteProduct = data['data']['details']['favorite_products'];
        List _favoriteStore = [];
        List _favoriteProduct = [];
        yourRatedProductsListener.updateAll(data['data']['details']['rated_products']);
        myRatedStores.updateAll(data: data['data']['details']['rated_stores']);
        newMessageCounter.updateCount(data['data']['details']['unread_messages']);
        myAddress.update(list: data['data']['details']['addresses']);
        cartAuth.updateAll(data: data['data']['details']['cart']);
        orderListener.updateAll(nData: data['data']['details']['orders']);
        storeOrderNotifierListener.update(data['data']['details']['my_store_orders']);
        List<ContactNumber> _contacts = [];
        for(var nums in data['data']['details']['contact_numbers']){
          _contacts.add(ContactNumber.fromData(nums));
        }
        contactListner.updateAll(_contacts);
        for(var x in liked){
          likedStore.add(x['store_id']);
        }
        for(var x in disliked){
          dislikedStore.add(x['store_id']);
        }
        for(var x in favoriteStore)
          {
            favoriteStoreIds.add(x['store_id']);
           _favoriteStore.add(x['details']);
          }
        for(var x in favoriteProduct)
          {
            favoriteProductIds.add(x['product_id']);
            _favoriteProduct.add(x['details']);
          }
        favoriteStore = _favoriteStore;
        favoriteProduct = _favoriteProduct;
        Preferences().saveData(password, email);
        print("$token");
        Navigator.pushReplacement(
            context,
            PageTransition(
                child: HomePage(), type: PageTransitionType.fade));
        return true;
      }
      else if(respo.statusCode == 401)
      {
        Fluttertoast.showToast(msg: "Invalid login credentials");
        Preferences().removeData();
        if(!isLogin) {
          Navigator.pushReplacement(context, PageTransition(child: HomePage()));
        }
        return false;
      }else{
        Navigator.pushReplacement(context, PageTransition(child: HomePage()));
        return false;
      }
    }catch(e){
      Navigator.pushReplacement(context, PageTransition(child: HomePage()));
      print(e);
      return false;
    }
  }
  Future register(context, fn, ln, email, pass) async {
    try {
      print("REGISTERING... $fcmToken");
      final respo = await http.post('$url/register', body: {
        "first_name": fn,
        "last_name": ln,
        "email": email,
        "password": pass,
        "confirmation_password": pass,
        "fcm_token": fcmToken
      }, headers: {
        "Accept": "application/json",
      });
      var data = json.decode(respo.body);
      print(data);
      if (respo.statusCode == 200) {
        print(data);
        token = data['data']['token'];
//        userDetails = data['data']['details'];
        user_details = UserModel.fromData(data['data']['details']);
        newMessageCounter.updateCount(0);
        yourRatedProductsListener.updateAll([]);
        Preferences().saveData(pass, email);
        Navigator.pushReplacement(context, PageTransition(child: HomePage()));
        return 200;
      } else if (respo.statusCode == 401) {
        Fluttertoast.showToast(msg: data['error']['email'][0].toString());
        return 401;
      } else {
        Fluttertoast.showToast(msg: "Error ${respo.statusCode}, ${respo.reasonPhrase}, please contact administrator");
        print(respo.statusCode);
        return data['exception'];
      }

    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "An error has occurred while we are processing your request, please try again");
      return e.toString();
    }
  }
  Future sendCode({String code = "0"}) async {
    try{
      final respo = await http.get("$url/v1/sendCode/${user_details.id}",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      print(data);
      Fluttertoast.showToast(msg: "${data['message']}");
      if(respo.statusCode == 200){
        return true;
      }
      return false;
    }catch(e){
      print(e);
      return false;
    }
  }
  Future verifyAccount(code) async {
    try{
      final respo = await http.get("$url/v1/verifyAccount/${user_details.id}/$code",headers: {
        "accept" :"application/json"
      });
      var data = json.decode(respo.body);
      print(data);
      Fluttertoast.showToast(msg: "${data['message']}");
      if(respo.statusCode == 200){
        return data['data'];
      }
      return null;
    }catch(e){
      return null;
    }
  }
  Future logout(context) async {
    try {
      final respo = await http.post('$url/logout', headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
        "Accept": "application/json"
      },body: {
        "fcm_token" : fcmToken
      });
      var data = json.decode(respo.body);
      print("LOGOUT DATA : $data");
      if (respo.statusCode == 200) {
        token = null;
        user_details = null;
        hasNewNotification = false;
        myStoreDetails = null;
        myProductListener.update(newData: []);
        contactListner.clear_all();
        messageListener.updateAll(data: null);
        storeOrdersListener.updateData([]);
        storeOrderNotifierListener.update(0);
        yourRatedProductsListener.updateAll([]);
        orderListener.updateAll(nData: []);
        favoriteProduct.clear();
        favoriteProductIds.clear();
        favoriteStoreIds.clear();
        favoriteStore.clear();
        likedStore.clear();
        dislikedStore.clear();
        myCart.clear();
        cartIds.clear();
        cartStatus.clear();
        cartAuth.updateAll(data: []);
        newMessageCounter.updateCount(0);
        myAddress.update(list: []);
        Navigator.pushReplacement(context, PageTransition(child: HomePage(showAd: false,), type: PageTransitionType.fade));
        Preferences().removeData();
        return true;
      } else {
        print(data);
        return false;
      }

    } catch (e) {

      print(e.toString());
      return false;
    }
  }

  Future<List> getFCMTokens(userId) async {
    try{
      final respo = await http.get('$url/fetchTokens/$userId',headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      if(respo.statusCode == 200){
        return data['tokens'];
      }
      return null;
    }catch(e){
      return null;
    }
  }
  Future<void> attemptCall(number) async {
    try{
      if(await canLaunch("$number")){
        await launch("$number");
      }else{
        Fluttertoast.showToast(msg: 'Could not launch $number');
        throw 'Could not launch $number';
      }
    }catch(e){
      print(e);
    }
  }
}