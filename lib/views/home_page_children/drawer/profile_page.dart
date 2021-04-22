import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/interrupts.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/authentication.dart';
import 'package:ekaon/services/order_notifier.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/views/credentials/validate_page.dart';
import 'package:ekaon/views/home_page.dart';
import 'package:ekaon/views/home_page_children/drawer/favorite_page.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_page.dart';
import 'package:ekaon/views/home_page_children/drawer/my_transaction_page.dart';
import 'package:ekaon/views/home_page_children/drawer/rated_page.dart';
import 'package:ekaon/views/home_page_children/phone_numbers.dart';
import 'package:ekaon/views/update_profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;
  TextStyle buttonStyle(){
    return TextStyle(
        color: Colors.white,
        fontSize: 12.5
    );
  }
  List verification = [
    {
      "name": "Registered",
      "type": 0,
    },
    {
      "name": "Add phone number",
      "type": 1,
    },
    {
      "name": "Verified Email",
      "type": 2,
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Image.asset(
              "assets/images/logo.png",
              width: 60,
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: (){
                Navigator.pushReplacement(context, PageTransition(child: HomePage(showAd: false,)));
              },
              icon: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,color: Colors.black54,),
            ),
            actions: <Widget>[
              PopupMenuButton(
                icon: Container(
                  width: 25,
                  height: 25,
                  child: Image.asset("assets/images/dot_menu.png",color: Colors.grey,),
                ),
                offset: Offset(0,100),
                onSelected: (x){
                  print(x);
                  if(x == 2){
                    setState(() {
                      _isLoading = true;
                    });
                    Auth().logout(context).whenComplete(() => setState(()=> _isLoading = false));
                  }else{
                    Interrupts().showChangePassSecurity(context, user_details.email);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Text("Change password"),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text("Logout"),
                  )
                ],
              )
            ],
          ),
          body: OrientationBuilder(
            builder: (context, orientation) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: user_details != null ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: ListView(
                    children: <Widget>[
                      Tooltip(
                        child: Container(
                          width: double.infinity,
                          height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 15),
//                        alignment: AlignmentDirectional.center,
                          child: Center(
                            child: Container(
                              width: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 14),
                              height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 14),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(1000),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: user_details.profile_picture == null ? AssetImage('assets/images/no-image-available.png') : NetworkImage("https://ekaon.checkmy.dev${user_details.profile_picture}")
                                  )
                              ),
                              child: FlatButton(
                                onPressed: ()=>Navigator.push(context, PageTransition(child: UpdateProfilePicture(),type: PageTransitionType.downToUp)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1000)),
                              ),
                            ),
                          ),
                        ),
                        message: "Update picture",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                          width: double.infinity,
                          child: Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  text: "${user_details.first_name[0].toUpperCase() +
                                      user_details.first_name.substring(1) +
                                      " " +
                                      user_details.last_name[0].toUpperCase() +
                                      user_details.last_name.substring(1)}",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                      fontSize: scrw > 700 ? scrw/35 : scrw/25
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "\n${user_details.email}",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w400,
                                            fontSize: scrw > 700 ? scrw/40 : scrw/30
                                        )
                                    )
                                  ]
                              ),
                            ),
                          )
                      ),
                      user_details != null ? Container(
                        width: double.infinity,
//                  height: 125,
                        child: Column(
                          children: <Widget>[
                            Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
//                        height: 60,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          for(var x = 0;x<verification.length;x++)...{
                                            x != 0 ? Expanded(
                                              child: Container(
                                                  height: 5,
                                                  width: double.infinity,
                                                  color: (verType + 1 <= verification[x]['type']) ? Colors.grey[300] : Colors.green
                                              ),
                                            ) : Container(),
                                            Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                  color: (verType + 1 <= verification[x]['type']) ? Colors.grey[300] : Colors.green,
                                                  borderRadius: BorderRadius.circular(1000),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black.withOpacity(0.3),
                                                        blurRadius: 1,
                                                        offset: Offset(3,3)
                                                    )
                                                  ]
                                              ),
                                              child: Center(
                                                child: Text("${x+1}",style: TextStyle(
                                                    color: (verType + 1 <= verification[x]['type']) ? Colors.grey[600] : Colors.white,
                                                    fontWeight: FontWeight.w600
                                                ),),
                                              ),
                                            ),

                                          }
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          for(var x = 0;x<verification.length;x++)...{
                                            Container(
                                              width: 60,
                                              child: Text(verification[x]['name'],style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.black54
                                              ),textAlign: TextAlign.center,),
                                            )
                                          }
                                        ],
                                      ),
                                    )
                                  ],
                                )
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            verType < 2 ? Center(
                              child: GestureDetector(
                                onTap: (){
                                  if(verType == 0){
                                    Navigator.push(context, PageTransition(child: ContactNumPage(),type: PageTransitionType.rightToLeft));
                                  }else{
                                    Navigator.push(context, PageTransition(child: ValidationPage(isEmail: true,),type: PageTransitionType.rightToLeft));
                                  }
                                },
                                child: Container(
                                    width: 80,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: kPrimaryColor.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(7),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              offset: Offset(2,2),
                                              blurRadius: 2
                                          )
                                        ]
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                    alignment: AlignmentDirectional.center,
                                    child: Text(verType == 0 ? "Add phone number" : "Verify email",textAlign: TextAlign.center,style: buttonStyle(),)
                                ),
                              ),
                            ) : Container(),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ) : Container(),
                      GestureDetector(
                        onTap: (){
                          if(user_details != null) {
                            Navigator.push(context, PageTransition(child: FavoritePage(),type: PageTransitionType.downToUp));
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                          decoration: BoxDecoration(
                              border: Border.symmetric(vertical: BorderSide(color: Colors.white))
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.favorite, color: Colors.red,),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Text("Favorites",style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                    fontSize: scrw > 700 ? scrw/35 : scrw/25
                                ),),
                              )
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          if(user_details != null) {
                            Navigator.push(context, PageTransition(child: RatedPage(),type: PageTransitionType.downToUp));
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                          decoration: BoxDecoration(
                              border: Border.symmetric(vertical: BorderSide(color: Colors.white))
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.rate_review, color: Colors.orange,),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Text("Rated",style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                    fontSize: scrw > 700 ? scrw/35 : scrw/25
                                ),),
                              )
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          if(user_details != null) {
                            Navigator.push(context, PageTransition(child: MyTransactionPage(),type: PageTransitionType.downToUp));
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                          decoration: BoxDecoration(
                              border: Border.symmetric(vertical: BorderSide(color: Colors.white))
                          ),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 25,
                                height: 25,
                                child: Center(
                                  child: Image.asset('assets/images/transactions.png',color: Colors.amber,),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Text("My Transactions",style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                    fontSize: scrw > 700 ? scrw/35 : scrw/25
                                ),),
                              ),

                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          if(user_details != null) {
                            Navigator.push(context, PageTransition(child: MyStorePage(),type: PageTransitionType.downToUp));
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                          decoration: BoxDecoration(
                              border: Border.symmetric(vertical: BorderSide(color: Colors.white))
                          ),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 25,
                                height: 25,
                                child: Center(
                                  child: Image.asset('assets/images/mobile_store.png',color: Colors.blueGrey,),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Text("My Store",style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                    fontSize: scrw > 700 ? scrw/35 : scrw/25
                                ),),
                              ),
                              user_details != null && user_details.has_store == 1 ? Container(
                                child: StreamBuilder(
                                  stream: storeOrderNotifierListener.stream$,
                                  builder: (context,result) => result.hasData ? result.data == 0 ? Container() : Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(10000)
                                    ),
                                    child: Text("${result.data}",style: TextStyle(
                                        color: Colors.white
                                    ),),
                                  ) : Container(),
                                ),
                              ) : Container()
                            ],
                          ),
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 10),
                          width: double.infinity,
                          height: Percentage().calculate(num: scrh,percent: 7.5),
                          child: MyWidgets().button(
                              pressed: ()=> Navigator.push(context, PageTransition(child: ContactNumPage(), type: PageTransitionType.rightToLeft)),
                              color: Colors.white,
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text("Phone numbers",style: TextStyle(
                                        color: Colors.black54
                                    ),),
                                  ),
                                  Icon(Icons.chevron_right,color: Colors.black54  ,)
                                ],
                              )
                          )
                      ),
                    ],
                  )
                ) : Container(),
              );
            }
          ),
        ),
        _isLoading ? MyWidgets().loader() : Container()
      ],
    );
  }
}
