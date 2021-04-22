import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/convo_listener.dart';
import 'package:ekaon/services/message_listener.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/credentials/login_page.dart';
import 'package:ekaon/views/home_page_children/compose_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:page_transition/page_transition.dart';

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  TextEditingController _search = new TextEditingController();
  bool _isKeyboardActive = false;
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
    if(user_details != null){
      messageListener.getMessagesServer();
    }
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: ()=> FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              height: Platform.isAndroid ? MediaQuery.of(context).size.height-(_isKeyboardActive ? Percentage().calculate(num: MediaQuery.of(context).size.height,percent: MediaQuery.of(context).size.height > 700 ? 53 : 50) : 0) : MediaQuery.of(context).size.height,
              child: user_details == null ? Center(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: MediaQuery.of(context).size.height > 700 ? 30 : 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[400],
                        offset: Offset(3,3),
                        blurRadius: 2
                      )
                    ]
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: Center(
                          child: Image.asset("assets/images/icon-info.png",width: 55,),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: Text("Guest access !",style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),textAlign: TextAlign.center,),
                      ),
                      Container(
                        width: double.infinity,
                        child: Text("You are currently logged in as a guest user. To gain full access please login.",style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w400,
                            fontSize: 14
                        ),textAlign: TextAlign.center,),
                      ),
                      Spacer(),
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: kPrimaryColor
                        ),
                        child: FlatButton(
                          onPressed: (){
                            Navigator.push(context, PageTransition(child: LoginPage(),type: PageTransitionType.rightToLeft));
                          },
                          child: Center(
                            child: Text("Login",style: TextStyle(
                              color: Colors.white
                            ),),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ) : Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
//                    margin: const EdgeInsets.only(top: 60),
                      child: StreamBuilder(
                        stream: messageListener.stream$,
                        builder: (context, result) => result.hasData ? result.data.length > 0 ? ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemCount: result.data.length,
                          itemBuilder: (context, index) => FlatButton(
                            onPressed: () async {
                              if(messageListener.getCurrentChatroomId() != result.data[index]['id']){
                                convoListener.updateAll(obj: null);
                                messageListener.updateChatroomId(result.data[index]['id']);
                              }
                              Navigator.push(context, PageTransition(child: ChatBox(storeDetails: result.data[index]['store_details'],recipient: result.data[index]['customer_details'], isStore: result.data[index]['store_owner_id'] != user_details.id, storeId: result.data[index]['store_id'], storeOwnerId: result.data[index]['store_owner_id'])));
                              if(messageListener.getChatroomCount(result.data[index]['id']) > 0){
                                messageListener.updateCount(newCount: 0,chatroomId: result.data[index]['id']);
                                await messageListener.seen(result.data[index]['id']);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey[300]))
                              ),
                              margin: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10000),
                                      image: DecorationImage(
                                        alignment: Alignment.center,
                                        fit: BoxFit.cover,
                                        image: result.data[index]['customer_id'] == user_details.id ? result.data[index]['store_details']['picture'] == null ? AssetImage("assets/images/default_store.png") : NetworkImage("https://ekaon.checkmy.dev${result.data[index]['store_details']['picture']}")
                                            : result.data[index]['customer_details']['profile_picture'] == null ? AssetImage("assets/images/no-image-available.png") : NetworkImage("https://ekaon.checkmy.dev${result.data[index]['customer_details']['profile_picture']}")
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(2,2),
                                          blurRadius: 2
                                        )
                                      ]
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      child: Column(
                                        children: <Widget>[
                                          Container(
                                            width: double.infinity,
                                            child: Text("${result.data[index]['customer_id'] == user_details.id ? StringFormatter(string: result.data[index]['store_details']['name']).titlize() : StringFormatter(string: result.data[index]['customer_details']['first_name']).titlize() + " ${StringFormatter(string: result.data[index]['customer_details']['last_name']).titlize()}"}",style: TextStyle(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w700
                                            ),),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            child: Text("${result.data[index]['last_convo']['sender_id'] == user_details.id ? "You : " : ""}${result.data[index]['last_convo']['images'].length > 0 ? "Sent a photo" : "${result.data[index]['last_convo']['message']}"}",style: TextStyle(
                                              color: Colors.grey
                                            ),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  result.data[index]['new_messages'] == null || result.data[index]['new_messages'] == 0 ? Container() :  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      borderRadius: BorderRadius.circular(1000)
                                    ),
                                    child: Text("${result.data[index]['new_messages']}",style: TextStyle(
                                      color: Colors.white
                                    ),),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ) : Center(
                          child: Image.asset("assets/images/no_messages.png"),
                        ) : Container(
                          child: Center(
                            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),),
                          ),
                        ) ,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
