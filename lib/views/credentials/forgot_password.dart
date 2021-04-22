import 'dart:async';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/forgot_password.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/views/credentials/forgot_password_children/send_code.dart';
import 'package:ekaon/views/credentials/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController _email = new TextEditingController();
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
                              child: Text("Forgot password?",style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: scrw > 700 ? scrw/20 : scrw/15,
                                  fontWeight: FontWeight.w900
                              ),textAlign: TextAlign.center,),
                            ),
                            wd.textFormField(label: "Email",controller: _email,type: TextInputType.emailAddress),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.push(context, PageTransition(child: SendCode(),type: PageTransitionType.downToUp));
                                },
                                child: Text("Already got a code ?",style: TextStyle(
                                    fontSize: scrw > 700 ? scrw/ 45 : scrw/30,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    color: kPrimaryColor
                                ),textAlign: TextAlign.end,),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: orientation == Orientation.portrait ? 8 : 13),
                              margin: EdgeInsets.only(top: scrh > 700 ? scrh/12 : scrh/12),
                              child: wd.button(pressed: (){
                                FocusScope.of(context).unfocus();
                                if(_email.text.isNotEmpty && _email.text.contains("@")){
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  ForgotPasswordAuth().sendEmail(_email.text).then((value) {
                                    if(value){
                                      Navigator.push(context, PageTransition(child: SendCode()));
                                    }
                                  }).whenComplete(() => setState(() => _isLoading = false));
                                }else{
                                  Fluttertoast.showToast(msg: "Please enter a valid email");
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
