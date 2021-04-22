import 'dart:async';
import 'package:flutter/material.dart';
import 'package:keyboard_utils/keyboard_listener.dart';
import 'package:keyboard_utils/keyboard_utils.dart';
import 'package:rxdart/rxdart.dart';

class KeyboardBloc {
  KeyboardUtils _keyboardUtils = KeyboardUtils();
  StreamController<double> _streamController = StreamController<double>();
  Stream<double> get stream => _streamController.stream;

  KeyboardUtils get keyboardUtils => _keyboardUtils;

  int _idKeyboardListener;

  void start() {
    _idKeyboardListener = _keyboardUtils.add(
        listener: KeyboardListener(willHideKeyboard: () {
          _streamController.sink.add(_keyboardUtils.keyboardHeight);
        }, willShowKeyboard: (double keyboardHeight) {
          _streamController.sink.add(keyboardHeight);
        }));
  }

  void dispose() {
    _keyboardUtils.unsubscribeListener(subscribingId: _idKeyboardListener);
    if (_keyboardUtils.canCallDispose()) {
      _keyboardUtils.dispose();
    }
    _streamController.close();
  }
}

class CustomKeyboardListener{
  BehaviorSubject<double> _keyboardHeight = BehaviorSubject.seeded(0);
  Stream get stream$ => _keyboardHeight.stream;
  double get current => _keyboardHeight.value;

  updateAll({double newHeight}){
    _keyboardHeight.add(newHeight);
  }
}

//class CustomKeyboardListener {
//  BehaviorSubject<double> _height = BehaviorSubject.seeded(0.0);
//  Stream get stream$ => _height.stream;
//  double get current => _height.value;
//  final viewInsets = EdgeInsets.fromWindowPadding(WidgetsBinding.instance.window.viewInsets,WidgetsBinding.instance.window.devicePixelRatio);
//  void start()async {
//    _height.add(await _height.listen((value) => value));
//    print("NEW HIEGHT!  : $_height");
//  }
//}