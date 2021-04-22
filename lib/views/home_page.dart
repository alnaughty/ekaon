import 'dart:ui';
import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/custom_app_bar.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/interrupts.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/ad.dart';
import 'package:ekaon/services/cart.dart';
import 'package:ekaon/services/cart_counter.dart';
import 'package:ekaon/services/firebase.dart';
import 'package:ekaon/services/home_index_listener.dart';
import 'package:ekaon/services/message_listener.dart';
import 'package:ekaon/services/new_message_listener.dart';
import 'package:ekaon/services/order_notifier.dart';
import 'package:ekaon/views/credentials/login_page.dart';
import 'package:ekaon/views/home_page_children/drawer/profile_page.dart';
import 'package:ekaon/views/home_page_children/explore_page.dart';
import 'package:ekaon/views/home_page_children/messages_page.dart';
import 'package:ekaon/views/home_page_children/new_cart_page.dart';
import 'package:ekaon/views/home_page_children/search.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatefulWidget {
  final bool reFetch;
  final bool showAd;
  loader(BuildContext context ,bool state){
    context.findAncestorStateOfType<_HomePageState>().loadState(state);
  }
  HomePage({Key key, this.reFetch = false, this.showAd = true}) : super(key : key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextStyle buttonStyle(){
    return TextStyle(
      color: Colors.white,
      fontSize: 12.5
    );
  }
  loadState(bool state){
    setState(() {
      _isLoading = state;
    });
  }
//  AdViewer _adViewer;
  GlobalKey<ScaffoldState> _key;
  int _currentIndex= 0;
//  List<Widget> _contents = [ExplorePage(context: context,), MessagesPage()];
  bool _isLoading = false;
  @override
  void dispose() {
    // TODO: implement dispose
//    _adViewer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
     _key = new GlobalKey<ScaffoldState>();
    });
    if(user_details != null )
    {
      setState(() {
        verType = user_details.verified.strength != null ? user_details.verified.strength : 0;
      });
      Firebase().pushNotificationListen(context);
    }
    if(widget.reFetch){
      setState(() {
        storeDetails = null;
        displayData = null;
      });
    }
    if(widget.showAd){
      try{
        AdmobService _ads = new AdmobService();
        InterstitialAd _interstitialAd = _ads.createInterstitialAd()..load()..show();

      }catch(e){


      }
    }
    super.initState();
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
//  List contents = [ExplorePage(context: ,), MessagesPage()];
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
      onWillPop: () => Interrupts().showAppExit(context),
      child: Scaffold(
        key: _key,
//      endDrawer: filter(),
        body: Stack(
          children: <Widget>[
            _currentIndex == 0 ? ExplorePage(context: _key.currentContext,) : MessagesPage(),
            _isLoading ? MyWidgets().loader() : Container()
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (x){
            homeIndexListener.change(x);
            setState(() {
              _currentIndex = x;
            });
          },
          currentIndex: _currentIndex,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Container(
                  width: 25,
                  height: 25,
                  child: Icon(Icons.explore),
                ),
                label: "Explore"
            ),
            BottomNavigationBarItem(
                icon: Container(
                  width: 25,
                  height: 25,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: 25,
                        height: 25,
                        child: Image.asset("assets/images/chat.png",color: _currentIndex == 1 ? kPrimaryColor : Colors.grey,),
                      ),
                      Container(
                          width: 25,
                          height: 25,
                          alignment: AlignmentDirectional.topEnd,
                          child: StreamBuilder(
                            stream: newMessageCounter.stream$,
                            builder: (context,result) => result.hasData && newMessageCounter.current > 0 ? Container(
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10000),
                                  color: Colors.green
                              ),
                              child: Center(
                                child: FittedBox(
                                  child: Text("${newMessageCounter.current}",style: TextStyle(
                                      color: Colors.white
                                  ),),
                                ),
                              ),
                            ) : Container(),
                          )
                      )
                    ],
                  ),
                ),
                label: "Messages"
            ),
          ],
        )
      ),
    );
  }

//  Widget filter() {
//    return Drawer(
//      child: Container(
//        height: double.infinity,
//        color: Colors.red,
//      ),
//    );
//  }
}
