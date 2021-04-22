import 'dart:async';
import 'dart:io';
import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/authentication.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _email = new TextEditingController();
  TextEditingController _firstName = new TextEditingController();
  TextEditingController _lastName = new TextEditingController();
  TextEditingController _password = new TextEditingController();
  TextEditingController _confirmPassword = new TextEditingController();
  StreamSubscription _subscription;
  bool _isKeyboardActive = false;
  bool _isLoading = false;
  bool _isObscured = true;
  MyWidgets wd = new MyWidgets();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(this.mounted){
      _subscription = KeyboardVisibility.onChange.listen((v) {
        setState(() {
          _isKeyboardActive = v;
        });
      });
    }
//    AppAuth().getFCMToken();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _subscription.cancel();
  }
  @override
  Widget build(BuildContext context) {
    var bottom = MediaQuery.of(context).viewInsets.bottom;
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        resizeToAvoidBottomPadding: Platform.isIOS,
        body: OrientationBuilder(
            builder: (context, orientation) {
              return Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: Preferences().getAppAvailableHeight(_isKeyboardActive, MediaQuery.of(context).size.height),
//                    height: orientation == Orientation.portrait ? _isKeyboardActive ? Percentage().calculate(num: MediaQuery.of(context).size.height, percent: 55) : MediaQuery.of(context).size.height : Percentage().calculate(num: scrw, percent: 55),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
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
                          child: Text("Welcome new user!",style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: scrw > 700 ? scrw/20 : scrw/15,
                              fontWeight: FontWeight.w900
                          ),textAlign: TextAlign.center,),
                        ),
                        wd.textFormField(label: "Email",controller: _email, type: TextInputType.emailAddress),
                        const SizedBox(
                          height: 20,
                        ),
                        wd.textFormField(label: "Firstname",controller: _firstName),
                        const SizedBox(
                          height: 20,
                        ),
                        wd.textFormField(label: "Lastname",controller: _lastName),
                        const SizedBox(
                          height: 20,
                        ),
                        wd.passwordText(onView: (){
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        }, obscurity: _isObscured,controller: _password, label: "Password"),
                        const SizedBox(
                          height: 20,
                        ),
                        wd.passwordText(onView: (){
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        }, obscurity: _isObscured,controller: _confirmPassword, label: "Confirm password"),
                    Container(
                      width: double.infinity,
                      height: 60,
                      margin: EdgeInsets.only(top: scrh > 700 ? scrh/12 : scrh/12),
                      child: wd.button(pressed: (){
                        FocusScope.of(context).unfocus();
                        if(_email.text.isNotEmpty && _password.text.isNotEmpty && _confirmPassword.text.isNotEmpty){
                          if(_email.text.contains("@")){
                            if(_password.text != _confirmPassword.text){
                              Fluttertoast.showToast(msg: "Password mismatch, please check your password");
                            }else{
                              setState(() {
                                _isLoading = true;
                              });
                              Auth().register(context, _firstName.text, _lastName.text, _email.text, _password.text).whenComplete(() => setState((){
                                _isLoading = false;
                              }));
                            }
                          }else{
                            Fluttertoast.showToast(msg: "Invalid email provided");
                          }

                        }else{
                          Fluttertoast.showToast(msg: "Please fill all empty fields");
                        }
                      }, child: Text("Register",style: TextStyle(
                          color: Colors.white,
                          fontSize: scrw > 700 ? scrw/35 : scrw/25,
                          fontWeight: FontWeight.w600
                      ),),),)
                      ],
                    ),
                  ),
                  _isLoading ? wd.loader() : Container()
                ],
              );
            }
        ),
      ),
    );
  }
}