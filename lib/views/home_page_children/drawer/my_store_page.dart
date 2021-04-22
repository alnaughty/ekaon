import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/views/credentials/validate_page.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/no_store.dart';
import 'package:ekaon/views/home_page_children/phone_numbers.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class MyStorePage extends StatefulWidget {
  @override
  _MyStorePageState createState() => _MyStorePageState();
}

class _MyStorePageState extends State<MyStorePage> {
  ScrollController _scrollController = new ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
      resizeToAvoidBottomPadding: Platform.isIOS,
      body: Container(
        width: double.infinity,
        child: verType == 2 ? user_details.has_store == 1 ? MyStoreViewPage() : IDontHaveAStore() : Container(
          width: double.infinity,
          child: OrientationBuilder(
            builder: (context, orientation) {
              return Center(
                child: Container(
                  width: Percentage().calculate(num: orientation == Orientation.portrait ? scrw : scrh,percent: 80),
                  height: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: 60),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(1,2),
                        blurRadius: 2
                      )
                    ]
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(

                          child: Center(
                            child: Image.asset("assets/images/notice.png")
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: RichText(
                          text: TextSpan(
                            text: verType == 0 ? "Add phone number" : "Email verification",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 17.5
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: verType == 0 ? "\nWe detected that you did not add a phone number yet, add a phone number and verify email to proceed" : "\nWe detected that you haven't verified your email yet, verify email to proceed.",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14
                                )
                              )
                            ]
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if(orientation == Orientation.portrait)...{
                        Container(
                          width: double.infinity,
                          height: Percentage().calculate(num: scrh, percent: 8),
                          child: RaisedButton(
                            elevation: 0,
                            color: Colors.green,
                            onPressed: (){
                              Navigator.of(context).pop(null);
                              if(verType == 0){
                                Navigator.push(context, PageTransition(child: ContactNumPage()));
                              }else{
                                Navigator.push(context, PageTransition(child: ValidationPage(isEmail: true,)));
                              }
                            },
                            child: Center(
                                child:Text(verType == 0 ? "Add phone number" : "Verify",style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                ),)
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: double.infinity,
                          height: Percentage().calculate(num: scrh, percent: 8),
                          child: Center(
                            child: RaisedButton(
                              padding: const EdgeInsets.all(0),
                              elevation: 0,
                              onPressed: ()=>Navigator.of(context).pop(null),
                              child: Center(
                                child:Text("Back",style: TextStyle(
                                    color: Colors.black54,
                                  fontWeight: FontWeight.w600
                                ),)
                              ),
                            ),
                          ),
                        )
                      }else...{
                        Container(
                          width: double.infinity,
                          height: Percentage().calculate(num: scrh, percent: 8),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  child: RaisedButton(
                                    elevation: 0,
                                    onPressed: ()=>Navigator.of(context).pop(null),
                                    child: Center(
                                        child:Text("Back",style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600
                                        ),)
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Container(
                                  child: RaisedButton(
                                    elevation: 0,
                                    color: Colors.green,
                                    onPressed: (){
                                      Navigator.of(context).pop(null);
                                      Navigator.push(context, PageTransition(child: ValidationPage(isEmail: true,)));
                                    },
                                    child: Center(
                                        child:Text("Verify",style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600
                                        ),)
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      }
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}
