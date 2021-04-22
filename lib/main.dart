import 'dart:io';
import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/localization.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/services/firebase.dart';
import 'package:firebase_core/firebase_core.dart' as core;
import 'package:ekaon/services/position_listener.dart';
import 'package:ekaon/services/preferences.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await core.Firebase.initializeApp();
  runApp(MyApp());
  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: Firebase().analytics)
      ],
      localizationsDelegates: LocalizationAuth().delegates,
      supportedLocales: LocalizationAuth().supportedLocales,
      debugShowCheckedModeBanner: false,
      title: 'Ekaon',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
            color: kPrimaryColor
          )
        ),
        primaryColor: kPrimaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
//  StreamSubscription<Position> _pos;
  Geolocator geolocator = new Geolocator();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    Firebase().getFcmToken().whenComplete(() async  => await Preferences().readData(context));
//    Geolocator().getCurrentPosition(locationPermissionLevel: GeolocationPermission.locationWhenInUse,desiredAccuracy: LocationAccuracy.best);
    myPosition.geoPos = geolocator.getPositionStream(LocationOptions(accuracy: LocationAccuracy.best,timeInterval: 1500)).listen((position) {
      myPosition.manualUpdate(position);
    });
  }
  @override
  Widget build(BuildContext context) {
    keyboardSize = MediaQuery.of(context).viewInsets.bottom;
    scrw = MediaQuery.of(context).size.width;
    scrh = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomPadding: Platform.isIOS,
      backgroundColor: Colors.grey[50],
      body: Container(
        child: Center(
          child: Image.asset("assets/images/loader.gif"),
        ),
      ),
    );
  }
}

