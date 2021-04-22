import 'dart:async';
import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/authentication.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/views/credentials/forgot_password.dart';
import 'package:ekaon/views/credentials/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _email = new TextEditingController();
  TextEditingController _pass = new TextEditingController();
  bool _isKeyboardActive = false;
  bool _isLoading = false;
  bool _isObscured = true;
  MyWidgets wd = new MyWidgets();
  StreamSubscription<bool> _keyboard;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(this.mounted){
      _keyboard = KeyboardVisibility.onChange.listen((event) {
        setState(() {
          _isKeyboardActive = event;
        });
      });
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _keyboard.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            resizeToAvoidBottomPadding: Platform.isIOS,
            body: OrientationBuilder(
              builder: (context, orientation) {
                return ListView(
                  padding: const EdgeInsets.all(0),
                  children: <Widget>[
                    Container(
                    width: double.infinity,
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: <Widget>[
                          AnimatedContainer(
//                            padding: EdgeInsets.only(top: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: 5)),
                            width: double.infinity,
                            height: _isKeyboardActive ? 0 : Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: 10),
                            duration: Duration(milliseconds: 500),
                            child: Center(
                              child: Image.asset("assets/images/logo.png"),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: 5),bottom: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: 5)),
                            width: scrw,
                            child: Text("Welcome Back!",style: TextStyle(
                                color: kPrimaryColor,
                                fontSize: scrw > 700 ? scrw/20 : scrw/15,
                                fontWeight: FontWeight.w900
                            ),textAlign: TextAlign.center,),
                          ),
                          wd.textFormField(label: "Email",controller: _email,type: TextInputType.emailAddress),
                          const SizedBox(
                            height: 20,
                          ),
                          wd.passwordText(onView: (){
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          }, obscurity: _isObscured,controller: _pass, label: "Password"),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: (){
                                Navigator.push(context, PageTransition(child: ForgotPassword(), type: PageTransitionType.rightToLeft));
                              },
                              child: Text("Forgot password ?",style: TextStyle(
                                  fontSize: scrw > 700 ? scrw/ 45 : scrw/30,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  color: kPrimaryColor
                              ),textAlign: TextAlign.end,),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 60,
                            margin: EdgeInsets.only(top: scrh > 700 ? scrh/12 : scrh/12),
                            child: wd.button(pressed: (){
                              FocusScope.of(context).unfocus();
                              if(_email.text.isNotEmpty && _pass.text.isNotEmpty){
                                setState(() {
                                  _isLoading = true;
                                });
                                Auth().login(context, _email.text, _pass.text, true).whenComplete(() {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                });
                              }else{
                                Fluttertoast.showToast(msg: "Please fill all empty fields");
                              }
                            }, child: Text("Login",style: TextStyle(
                                color: Colors.white,
                                fontSize: scrw > 700 ? scrw/35 : scrw/25,
                                fontWeight: FontWeight.w600
                            ),),),
                          ),
                          _isKeyboardActive ? Container() : Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            width: scrw,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("No Account yet? ",style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                    fontSize: scrw > 700 ? scrw/40 : scrw/30
                                ),),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, PageTransition(child: RegisterPage(), type: PageTransitionType.downToUp));
                                  },
                                  child: Text("Register",style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: scrw > 700 ? scrw/40 : scrw/30
                                  ),),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                );
              }
            ),
          ),
          _isLoading ? wd.loader() : Container()
        ],
      ),
    );
  }
}
