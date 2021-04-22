import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/cart_counter.dart';
import 'package:ekaon/services/home_index_listener.dart';
import 'package:ekaon/services/order_notifier.dart';
import 'package:ekaon/views/credentials/login_page.dart';
import 'package:ekaon/views/home_page_children/drawer/profile_page.dart';
import 'package:ekaon/views/home_page_children/explore_page.dart';
import 'package:ekaon/views/home_page_children/messages_page.dart';
import 'package:ekaon/views/home_page_children/new_cart_page.dart';
import 'package:ekaon/views/home_page_children/search.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class CustomizedWidgets{
  final List toSearch;
  final GlobalKey<ScaffoldState> key;
  final bool fromStore;
  CustomizedWidgets({@required this.key, this.toSearch, @required this.fromStore});

  Widget Appbar(context) => Container(
    width: double.infinity,
    height: 60,
    child: Row(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 20),
          width: 45,
          height: 45,
          alignment: AlignmentDirectional.center,
          child: Image.asset(
            "assets/images/logo.png",
          ),
        ),
        Spacer(),
        Spacer(),
        user_details != null
            ? StreamBuilder(
          stream: cartCounter.stream$,
          builder: (_, result) => result.hasData ? IconButton(
              onPressed: () => Navigator.push(context, PageTransition(child: NewCartPage(),type: PageTransitionType.upToDown)),
              icon: MyWidgets().iconWithBadge(
                  image: Image.asset(
                    "assets/images/cart.png",
                    color: Colors.black54,
                  ), badgeColor: Colors.green, count: result.data)
          ) : Container(),
        )
            : Container(),
        IconButton(
          onPressed: (){
            Navigator.push(context, PageTransition(child: SearchPage(data: this.toSearch, type: this.fromStore ? 0 : 1), type: null));
          },
          icon: Container(
            width: 25,
            height: 25,
            child: Image.asset("assets/images/search.png",color: Colors.black54,),
          ),
        ),
        user_details != null ? Container(
          margin: const EdgeInsets.only(right: 20),
          width: 50,
          height: 50,
//                      padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(1000)
          ),
          child: Stack(
            children: <Widget>[
              GestureDetector(
                onTap: ()=>Navigator.push(context, PageTransition(child: ProfilePage())),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(1000),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          alignment: AlignmentDirectional.center,
                          image: user_details.profile_picture != null ? NetworkImage("https://ekaon.checkmy.dev${user_details.profile_picture}") : AssetImage("assets/images/no-image-available.png")
                      )
                  ),
                ),
              ),
              StreamBuilder(
                stream: storeOrderNotifierListener.stream$,
                builder: (_,result) => result.hasData ? result.data == 0 ? Container() : Container(
                  width: 50,
                  height: 50,
                  alignment: AlignmentDirectional.topEnd,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                        color: kPrimaryColor,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(1000)
                    ),
                  ),
                ) : Container(),
              ),

            ],
          ),
        ) : GestureDetector(
          onTap: ()=>Navigator.push(context, PageTransition(child: LoginPage(),type: PageTransitionType.rightToLeftWithFade)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(5)
            ),
            child: Text("Login",style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
            ),),
          ),
        )
      ],
    ),
  );
}