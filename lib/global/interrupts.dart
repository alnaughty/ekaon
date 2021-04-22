

import 'dart:io';
import 'dart:ui';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/authentication.dart';
import 'package:ekaon/services/home_index_listener.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/credentials/forgot_password_children/change_password.dart';
import 'package:ekaon/views/home_page.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/orders.dart';
import 'package:ekaon/views/home_page_children/drawer/my_transaction_page.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';

class Interrupts{
  showClickableFlush(context, {String title, String message, bool isTransaction = false}) {
    return Flushbar(
      onTap: (d) {
        print("NANO INI : $d");
        if(isTransaction){
          Navigator.push(context, PageTransition(child: MyTransactionPage(), type: PageTransitionType.leftToRightWithFade));
        }else{
          Navigator.push(context, PageTransition(child: StoreOrders(),type: PageTransitionType.leftToRightWithFade));
        }
      },
      backgroundColor: kPrimaryColor,
      borderRadius: 15,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      titleText: Text("$title",style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: scrw > 700 ? scrw/35 : scrw/25
      ),),
      messageText: Text("$message",style: TextStyle(
          fontSize: scrw > 700 ? scrw/40 : scrw/30,
          color: Colors.grey[200]
      ),),
      icon: Container(
        width: 30,
        height: 30,
        child: Image.asset("assets/images/logo.png"),
      ),
      duration: Duration(seconds: 3),
      flushbarStyle: FlushbarStyle.FLOATING,
      flushbarPosition: FlushbarPosition.TOP,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      borderWidth: 1,
      borderColor: Colors.white,
    )..show(context);
  }
  showMessageFlush(context, {String sender,String message,String picture}) {
    return Flushbar(
      backgroundColor: Colors.white,
      borderRadius: 15,
      duration: Duration(seconds: 4),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      borderWidth: 1,
      borderColor: Colors.black54,
      flushbarStyle: FlushbarStyle.FLOATING,
      flushbarPosition: FlushbarPosition.TOP,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      onTap: (d){
        print("MESSAGE INI! ${d.message}");
        Navigator.pushReplacement(context, PageTransition(child: HomePage(showAd: false,),type: PageTransitionType.leftToRightWithFade));
        homeIndexListener.change(1);
      },
      icon: Container(
        padding: const EdgeInsets.only(left: 3),
        width: 40,
        height: 40,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10000),
            image: DecorationImage(
              alignment: Alignment.center,
              fit: BoxFit.cover,
              image: picture != null ? NetworkImage("https://ekaon.checkmy.dev$picture") : AssetImage("assets/images/no-image-available.png")
            )
          ),
        ),
      ),
      titleText: Text("$sender",style: TextStyle(
          color: kPrimaryColor,
          fontWeight: FontWeight.w700,
          fontSize: scrw > 700 ? scrw/35 : scrw/25
      ),),
      messageText: Text("$message",style: TextStyle(
          fontSize: scrw > 700 ? scrw/40 : scrw/30,
          color: Colors.grey[400]
      ),),
      boxShadows: [
        BoxShadow(
          color: Colors.grey[100],
          offset: Offset(2,3),
          blurRadius: 2
        )
      ],
    )..show(context);
  }
  showProductDeletion(context, String productName, String productId, Function onYes) {
//    double titleSize = Theme.of(context).textTheme.headline5.fontSize;
    return showGeneralDialog(
      context: context,
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              title: Text('Product deletion',style: TextStyle(
//                  color: kPrimaryColor
              ),textAlign: TextAlign.center,),
              titleTextStyle: TextStyle(
                color: Colors.grey,
                fontSize: Theme.of(context).textTheme.headline5.fontSize
              ),
              contentPadding: EdgeInsets.all(0),
              content: Container(
                width: double.infinity,
                height: Theme.of(context).textTheme.headline5.fontSize * 6,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                      child: Text('Are you sure you want to delete this product named \"$productName\"?',style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: Theme.of(context).textTheme.bodyText1.fontSize
                      ),textAlign: TextAlign.center,),
                    ),
                    Spacer(),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              child: FlatButton(
                                onPressed: (){
                                  Navigator.of(context).pop(null);
                                },
                                padding: const EdgeInsets.all(0),
                                child: Center(
                                  child: Text("No",style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600
                                  ),),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: FlatButton(
                                onPressed: onYes,
                                padding: const EdgeInsets.all(0),
                                child: Center(
                                  child: Text("Yes",style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600
                                  ),),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
        pageBuilder: (context, animation1, animation2) {}
    );
  }
  showImageFull(String imageData, context) => showGeneralDialog(
      context: context,
      transitionDuration: Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, animation1, animation2) {},
    transitionBuilder: (context, a1,a2,widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 4,sigmaX: 4),
          child: Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(null),
                child: Image(
                  image: imageData == null ? AssetImage("assets/images/no-image-available.png") : NetworkImage("https://ekaon.checkmy.dev$imageData"),
                ),
              )
            )
          ),
        );
    }
  );

  showCartProductConfirmation(context, {Function onYes}) => showGeneralDialog(
      context: context,
      pageBuilder: (context, animation1, animation2) {},
    transitionBuilder: (context, a1,a2,widget) {
      final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
      return Transform(
        transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
        child: Opacity(
          opacity: a1.value,
          child: AlertDialog(
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              title: Text('Cart item exists',style: TextStyle(
//                  color: kPrimaryColor
              ),textAlign: TextAlign.center,),
              titleTextStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: Theme.of(context).textTheme.headline5.fontSize
              ),
              contentPadding: EdgeInsets.all(0),
              content: Container(
                width: double.infinity,
                height: Theme.of(context).textTheme.headline5.fontSize * 8,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                      child: Text('This item is existing if you change the variation, if you continue the quantity of the existing item will be added to the old one. \n \nDo you want to continue?',style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: Theme.of(context).textTheme.bodyText1.fontSize
                      ),textAlign: TextAlign.center,),
                    ),
                    Spacer(),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              child: FlatButton(
                                onPressed: (){
                                  Navigator.of(context).pop(null);
                                },
                                padding: const EdgeInsets.all(0),
                                child: Center(
                                  child: Text("No",style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600
                                  ),),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: FlatButton(
                                onPressed: onYes,
                                padding: const EdgeInsets.all(0),
                                child: Center(
                                  child: Text("Yes",style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600
                                  ),),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
          ),
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
  );
  showProductCategoryDeletion(context, String catName, String catId, Function onYes) {
//    double titleSize = Theme.of(context).textTheme.headline5.fontSize;
    return showGeneralDialog(
        context: context,
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  title: Text('Category removal',style: TextStyle(
//                  color: kPrimaryColor
                  ),textAlign: TextAlign.center,),
                  titleTextStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: Theme.of(context).textTheme.headline5.fontSize
                  ),
                  contentPadding: EdgeInsets.all(0),
                  content: Container(
                    width: double.infinity,
                    height: Theme.of(context).textTheme.headline5.fontSize * 6,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
                          child: Text('Are you sure you want to remove \"$catName\" from this product?',style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: Theme.of(context).textTheme.bodyText1.fontSize
                          ),textAlign: TextAlign.center,),
                        ),
                        Spacer(),
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  child: FlatButton(
                                    onPressed: (){
                                      Navigator.of(context).pop(null);
                                    },
                                    padding: const EdgeInsets.all(0),
                                    child: Center(
                                      child: Text("No",style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600
                                      ),),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  child: FlatButton(
                                    onPressed: onYes,
                                    padding: const EdgeInsets.all(0),
                                    child: Center(
                                      child: Text("Yes",style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600
                                      ),),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        pageBuilder: (context, animation1, animation2) {}
    );
  }
  showAppExit(context) {
    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: Text('Exit app validation',style: TextStyle(
                  color: kPrimaryColor
                ),),
                content: Text('Are you sure you want to exit?'),
                actions: <Widget>[

                  OutlineButton(
                    onPressed: ()=> Navigator.of(context).pop(null),
                    borderSide: BorderSide(color: Colors.green),
                    child: Center(
                      child: Text("No",style: TextStyle(
                          color: Colors.green
                      ),),
                    ),
                  ),
                  OutlineButton(
                    onPressed: (){
                      Navigator.of(context).pop(null);
                      exit(0);
                    },
                    borderSide: BorderSide(color: Colors.red),
                    child: Center(
                      child: Text("Yes",style: TextStyle(
                          color: Colors.red
                      ),),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
  }
  showBuyerInfo(Map data,context,List orders){
    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                titleTextStyle: TextStyle(
                  fontSize: Percentage().calculate(num: scrw,percent: 4.5),
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                ),
                title: Text('Order information',maxLines: 2,overflow: TextOverflow.ellipsis,),
                content: Container(
                  width: double.infinity,
                  height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 25),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.info,color: Colors.amber,),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text("If some info are not visible please scroll down",style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  fontSize: Percentage().calculate(num: scrw,percent: scrw > 700 ? 2.5 : 3.5)
                                ),),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: Percentage().calculate(num: scrw,percent: scrw > 700 ? 22 : 25),
                          height: Percentage().calculate(num: scrw,percent: scrw > 700 ? 22 : 25),
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10000),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey[400],
                                    offset: Offset(3,3),
                                    blurRadius: 2
                                )
                              ],
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  image: data['profile_picture'] == null ? AssetImage("assets/images/no-image-available.png") : NetworkImage('https://ekaon.checkmy.dev${data['profile_picture']}')
                              )
                          ),
                        ),
                        Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  text: "${StringFormatter(string: data['first_name']).titlize()} ${StringFormatter(string: data['last_name']).titlize()}",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "\n${data['email']}",
                                        style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w400
                                        )
                                    )
                                  ]
                              ),
                            )
                        ),
                        if(data['contact_numbers'].length > 0)...{
                          Container(
                            width: double.infinity,
                            child: Text("Contact numbers :"),
                          ),
                          for(var number in data['contact_numbers'])...{
                            GestureDetector(
                              onTap: () async {
                                Auth().attemptCall(number['number'].toString());
                              },
                              child: Container(
                                width: double.infinity,
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.phone,color: Colors.green,),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Text("${number['number']}",style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline
                                      ),),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          }
                        }else...{
                          Center(
                            child: Text("No recorded contact numbers, do not trust this buyer"),
                          )
                        },
                        Divider(color: Colors.black54,),
                        for(var order in orders)...{
                          Container(
                            width: double.infinity,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: Percentage().calculate(num: scrw,percent: scrw > 700 ? 13 : 16),
                                  height: Percentage().calculate(num: scrw,percent: scrw > 700 ? 13 : 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(1000),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey[400],
                                        offset: Offset(3,3),
                                        blurRadius: 3
                                      )
                                    ],
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      alignment: AlignmentDirectional.center,
                                      image: order['product']['images'].length == 0 ? AssetImage('assets/images/no-image-available.png') : NetworkImage("https://ekaon.checkmy.dev${order['product']['images'][0]['url']}")
                                    )
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        width: double.infinity,
                                        child: Text("${order['product']['name']}",style: TextStyle(
                                          fontWeight: FontWeight.w600
                                        ),),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: Text("Qty: ${order['quantity']}",style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                          fontSize: 13
                                        ),),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: Text("Php${double.parse(order['sub_total'].toString()).toStringAsFixed(2)}",style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey,
                                            fontSize: 13
                                        ),),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Divider(color: Colors.black54,),
                        }
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  OutlineButton(
                    onPressed: (){
                      Navigator.of(context).pop(null);
                    },
                    borderSide: BorderSide(color: Colors.green),
                    child: Center(
                      child: Text("Close",style: TextStyle(
                          color: Colors.green
                      ),),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
  }
  showChangePassSecurity(context, email) {
    TextEditingController _oldPassCheck = new TextEditingController();
    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset("assets/images/police_stop.png",width: 70,),
                    Text("Password Security",style: TextStyle(
                      color: kPrimaryColor
                    ),),
                  ],
                ),
                content: Container(
                  width: double.infinity,
                  height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 16),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: MyWidgets().textFormField(controller: _oldPassCheck,label: "Old password"),
                      ),
                      Container(
                        width: double.infinity,
                        child: Text("Enter your old password to verify this is you who want to reset the password.",style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13
                        ),),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(Percentage().calculate(num: MediaQuery.of(context).size.width,percent: MediaQuery.of(context).size.width > 720 ? 5 : 0)),
                          child: FittedBox(
                            child: Text("NOTE : Once you reset your password this cannot be undone",style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5
                            ),),
                          ),
                        )
                      )
                    ],
                  ),
                ),
                actions: <Widget>[
                  OutlineButton(
                    onPressed: (){
                      Navigator.of(context).pop(null);
                    },
                    borderSide: BorderSide(color: Colors.red),
                    child: Center(
                      child: Text("Cancel",style: TextStyle(
                          color: Colors.red
                      ),),
                    ),
                  ),
                  OutlineButton(
                    onPressed: (){
                      if(_oldPassCheck.text.isNotEmpty){
                        if(_oldPassCheck.text == savedPass){
                          Navigator.of(context).pop(null);
                          Navigator.push(context, PageTransition(
                              child: ChangePasswordPage(
                                  email: user_details.email), type: PageTransitionType.downToUp));
                        }else{
                          Fluttertoast.showToast(msg: "Password you entered is invalid");
                        }
                      }else{
                        Fluttertoast.showToast(msg: "Please enter password");
                      }
                    },
                    borderSide: BorderSide(color: Colors.green),
                    child: Center(
                      child: Text("Submit",style: TextStyle(
                          color: Colors.green
                      ),),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
  }
}