import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/forgot_password.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangePasswordPage extends StatefulWidget {
  final String email;
  ChangePasswordPage({Key key, @required this.email}) : super(key : key);
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _isKeyboardActive = false;
  bool _isObscured = true;
  bool _isLoading = false;
  TextEditingController _newPass = new TextEditingController();
  TextEditingController _newConfPass = new TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(this.mounted){
      KeyboardVisibility.onChange.listen((event) {
        setState(() {
          _isKeyboardActive = event;
        });
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
//          title: Text("Change Password",style: TextStyle(
//            color: kPrimaryColor
//          ),),
//          centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            body: Container(
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  AnimatedContainer(
//                            padding: EdgeInsets.only(top: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: 5)),
                    width: double.infinity,
                    height: _isKeyboardActive ? 0 : Percentage().calculate(num: MediaQuery.of(context).size.height, percent: 10),
                    duration: Duration(milliseconds: 500),
                    child: Center(
                      child: Image.asset("assets/images/logo.png"),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: Percentage().calculate(num: MediaQuery.of(context).size.height, percent: 5),bottom: Percentage().calculate(num: MediaQuery.of(context).size.height, percent: 5)),
                    width: double.infinity,
                    child: Text("Change Password",style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: MediaQuery.of(context).size.width > 700 ? MediaQuery.of(context).size.width/20 : MediaQuery.of(context).size.width/15,
                        fontWeight: FontWeight.w900
                    ),textAlign: TextAlign.center,),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    width: double.infinity,
                    child: MyWidgets().passwordText(controller: _newPass,obscurity: _isObscured,onView: (){
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    }, label: "New password"),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    width: double.infinity,
                    child: MyWidgets().passwordText(controller: _newConfPass,obscurity: _isObscured,onView: (){
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    }, label: "Confirmation password"),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: double.infinity,
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: FlatButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        if(_newConfPass.text.isNotEmpty && _newPass.text.isNotEmpty){
                          if(_newPass.text == _newConfPass.text){
                            setState(() {
                              _isLoading = true;
                            });
                            await ForgotPasswordAuth().resetPassword(widget.email, _newPass.text, context).whenComplete(() => setState(()=> _isLoading = false));
                          }else{
                            Fluttertoast.showToast(msg: "Password mismatch");
                          }
                        }else{
                          Fluttertoast.showToast(msg: "Please do not leave empty field");
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(7)
                        ),
                        child: Center(
                          child: Text("Submit",style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16
                          ),),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          _isLoading ? MyWidgets().loader() : Container()
        ],
      ),
    );
  }
}
