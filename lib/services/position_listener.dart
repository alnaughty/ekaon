import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

class MyPosition{
  BehaviorSubject<Position> _position = BehaviorSubject.seeded(null);
  Stream get $stream => _position.stream;
  Position get current => _position.value;
  StreamSubscription<Position> geoPos;
  manualUpdate(Position position){
    try{
      _position.add(position);
    }catch(e){
      print("ERROR : $e");
    }
  }

}
MyPosition myPosition = MyPosition();