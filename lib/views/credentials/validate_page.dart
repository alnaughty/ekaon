import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/model/UserVerified.dart';
import 'package:ekaon/services/authentication.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:math';

import 'package:url_launcher/url_launcher.dart';
class ValidationPage extends StatefulWidget {
  final bool isEmail;
  ValidationPage({Key key, @required this.isEmail}) : super(key : key);
  @override
  _ValidationPageState createState() => _ValidationPageState();
}

class _ValidationPageState extends State<ValidationPage> {
  TextEditingController _validate = new TextEditingController();
  MyWidgets wd = new MyWidgets();
  bool _isLoading = false;
  bool _hasSent = false;
  bool isKeyboardActive = false;
  sendCodeToEmail() async {
    print("SENDING");
    setState(() {
      _isLoading = true;
      _hasSent = true;
    });
    await Auth().sendCode().whenComplete(() => setState(()=> _isLoading = false));
  }
  sendCodeToPhone() async {
    setState(() {
      _isLoading = true;
    });
    await Auth().sendCode().whenComplete(() => setState(()=> _isLoading = false));
    try{

    }catch(e){

    }
  }
  String generateAlpha(int length){
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(this.mounted){
      KeyboardVisibility.onChange.listen((event) {
        setState(() {
          isKeyboardActive = event;
        });
      });
    }
    if(widget.isEmail){
//      sendCodeToEmail();
    }else{
      sendCodeToPhone();
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: true,
            ),
            backgroundColor: Colors.grey[100],
            body: OrientationBuilder(
                builder: (context, orientation) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          AnimatedContainer(
                            width: double.infinity,
                            height: isKeyboardActive ? 0 : Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: 10),
                            duration: Duration(milliseconds: 500),
                            child: Center(
                              child: Image.asset("assets/images/logo.png"),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: 5),bottom: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: 5)),
                            width: scrw,
                            child: Text("Validate ${widget.isEmail ? "Email" : "Number"}",style: TextStyle(
                                color: kPrimaryColor,
                                fontSize: scrw > 700 ? scrw/20 : scrw/15,
                                fontWeight: FontWeight.w900
                            ),textAlign: TextAlign.center,),
                          ),
                          wd.textFormField(label: "Verification code",controller: _validate,type: TextInputType.emailAddress),
                          if(_hasSent)...{
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              width: double.infinity,
                              child: Text("We sent a verification code to your ${widget.isEmail ? "email" : "phone number"}",style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w600
                              ),),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                                width: double.infinity,
                                child: Row(
                                  children: <Widget>[
                                    Text("Did not receive a code? "),
                                    InkWell(
                                      onTap: (){
                                        sendCodeToEmail();
                                      },
                                      child: Text("Resend",style: TextStyle(
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),),
                                    )
                                  ],
                                )
                            ),
                          }else...{
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              width: double.infinity,
                              child: Text("You haven't sent a code yet, please send one by clicking the button below"),
                            )
                          },
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            height: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: orientation == Orientation.portrait ? 8 : 13),
                            margin: EdgeInsets.only(top: scrh > 700 ? scrh/12 : scrh/12),
                            child: wd.button(pressed: (){
                              FocusScope.of(context).unfocus();
                              if(_hasSent){
                                if(_validate.text.isNotEmpty){
                                  setState(() => _isLoading = true);
                                  Auth().verifyAccount(_validate.text).then((value) {
                                    if(value != null){
                                      setState(() {
                                        user_details.verified = Verified.fromData(value);
                                      });
                                      Navigator.push(context, PageTransition(child: HomePage(reFetch: false,showAd: false,)));
                                    }
                                  }).whenComplete(() {
                                    setState(()=> _isLoading = false);
                                  });
                                }
                              }else{
                                sendCodeToEmail();
                              }
                            }, child: Text(_hasSent ? "Submit" : "Send code",style: TextStyle(
                                color: Colors.white,
                                fontSize: scrw > 700 ? scrw/35 : scrw/25,
                                fontWeight: FontWeight.w600
                            ),),),
                          ),

                        ],
                      ),
                    ),
                  );
                }
            ),
          ),
          _isLoading ? wd.loader() : Container()
        ],
      )
    );
  }
}
