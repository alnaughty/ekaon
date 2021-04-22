import 'dart:async';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/forgot_password.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/views/credentials/forgot_password_children/change_password.dart';
import 'package:ekaon/views/credentials/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class SendCode extends StatefulWidget {
  @override
  _SendCodeState createState() => _SendCodeState();
}

class _SendCodeState extends State<SendCode> {
  TextEditingController _code = new TextEditingController();
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
                              child: Text("Code authentication",style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: scrw > 700 ? scrw/20 : scrw/15,
                                  fontWeight: FontWeight.w900
                              ),textAlign: TextAlign.center,),
                            ),
                            wd.textFormField(label: "Code",controller: _code),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: double.infinity,
//                              padding: EdgeInsets.symmetric(horizontal: scrw > 700 ? scrw/10 : 20),
                              child: Text("We've sent you a 6 digit code valid for 5 minutes",style: TextStyle(
                                  fontSize: scrw > 700 ? scrw/40 : scrw/30,
                                  color: Colors.black54
                              ),),
                            ),
                            Container(
                              width: double.infinity,
                              height: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: orientation == Orientation.portrait ? 8 : 13),
                              margin: EdgeInsets.only(top: scrh > 700 ? scrh/12 : scrh/12),
                              child: wd.button(pressed: (){
                                FocusScope.of(context).unfocus();
                                if(_code.text.isNotEmpty){
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  ForgotPasswordAuth().verifyCode(_code.text).then((value) {
                                    if(value != null){
                                      Navigator.push(context, PageTransition(child: ChangePasswordPage(email: value['email'],)));
                                    }
                                  }).whenComplete(() => setState(() => _isLoading = false));
                                }
                              }, child: Text("Submit",style: TextStyle(
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
