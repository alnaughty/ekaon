import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

const kPrimaryColor = Color.fromRGBO(219, 25, 26, 1);
const kCardColor = Color(0xffFEE3AC);
const url = "https://ekaon.checkmy.dev/api";
const locationOptions = LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 10);
const apiKey = 'AIzaSyAaiwAmQaWYzlR3Ph8-7C9Aelp8QktpOzI';
const serverToken = "AAAA7q1YAK4:APA91bGlyscNkBxSn1KcTPRPQPZuchtDvnKmZ_6M5bhVRB1zM_-d0xIpXsxaoTLMTs7S0TUBawFYwBO_-Pax6c1bUmv9PsKcJwC9yuJVXIgrivCfwSZ7wdJ4Mjva-OLpVWEEGgCDXcxT";