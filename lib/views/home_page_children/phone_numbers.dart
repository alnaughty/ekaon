import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/model/contact_number.dart';
import 'package:ekaon/services/contact_number_listener.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/views/home_page_children/drawer/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class ContactNumPage extends StatefulWidget {
  @override
  _ContactNumPageState createState() => _ContactNumPageState();
}

class _ContactNumPageState extends State<ContactNumPage> {
  TextEditingController _num = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Image.asset("assets/images/logo.png", width: 60,),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,color: kPrimaryColor,),
            onPressed: (){
              Navigator.of(context).pop(null); //profile page
              Navigator.of(context).pop(null); //home page
              Navigator.push(context, PageTransition(child: ProfilePage(), type: PageTransitionType.leftToRightWithFade));

            },
          ),
        ),
        body: Container(
          width: double.infinity,
          color: Colors.grey[100],
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: StreamBuilder<List<ContactNumber>>(
            stream: contactListner.stream,
            builder: (context, result) => result.hasData ? ListView(
              children: <Widget>[
                Container(
                    width: double.infinity,
                    height: 60,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _num,
                            cursorColor: kPrimaryColor,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                                hintText: "Your number",
                                prefixIconConstraints: BoxConstraints(
                                    minWidth: 0
                                ),
                                prefixIcon: Container(
                                  width: 25,
                                  margin: const EdgeInsets.only(right: 10),
                                  child: Image.asset("assets/images/flag.jpeg"),
                                )
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add,color: Colors.green,size: 30,),
                          onPressed: (){
                            FocusScope.of(context).unfocus();
                            RegExp regExp = new RegExp(r'(^(09|\+639)\d{9}$)');
                            if(_num.text.isNotEmpty && regExp.hasMatch(_num.text)){
                              if(this.exists(_num.text)){
                                Fluttertoast.showToast(msg: "You can't add the same number");
                              }else{
                                contactListner.append(obj: {
                                  "id" : null,
                                  "number" : _num.text
                                });
                                if(verType < 2){
                                  setState(() {
                                    verType = 1;
                                  });
                                }
                                _num.clear();
                              }
                            }else{
                              Fluttertoast.showToast(msg: "Please add a valid phone number");
                            }
                          },
                        )
                      ],
                    )
                ),
                if(result.data.length > 0)...{
                  for(var x = 0;x<result.data.length;x++)...{
                    ListTile(
                      leading: Icon(Icons.phone, color: Colors.blue,),
                      title: Text("${result.data[x].number}"),
                      trailing: result.data[x].id != null ? result.data.length > 1 ? IconButton(
                        icon: Icon(Icons.remove,color: kPrimaryColor,),
                        onPressed: (){
                          if(result.data.length > 1){
                            contactListner.remove(result.data[x].id);
                          }else{
                            Fluttertoast.showToast(msg: "You can't delete all your contact numbers");
                          }
                        },
                      ) : IconButton(
                        icon: Icon(Icons.delete_forever,color: Colors.grey,),
                        onPressed: null,
                      )  : SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                          strokeWidth: 1.5,
                        ),
                      )
                    ),
                  }
                }else...{
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    child: Center(
                      child: Text("You have no recorded contact numbers, please add atleast one",style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.5
                      ),textAlign: TextAlign.center,),
                    ),
                  )
                },

//                Container(
//                  width: double.infinity,
//                  child: Text("e.g. 09XXXXXXXXX",style: TextStyle(
//                    color: Colors.black54
//                  ),),
//                )
              ],
            ) : Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),),
            ),
          ),
        ),
      ),
    );
  }
  bool exists(number){
    for(var x in contactListner.current){
      if(x.number == number){
        return true;
      }
    }
    return false;
  }
}
