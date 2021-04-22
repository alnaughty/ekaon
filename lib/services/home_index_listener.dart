import 'package:rxdart/rxdart.dart';

class HomeIndexListener{
  BehaviorSubject<int> _index = BehaviorSubject.seeded(0);
  Stream get stream$=> _index.stream;
  int get current => _index.value;
  change(int newIndex) {
    _index.add(newIndex);
  }
}
HomeIndexListener homeIndexListener = HomeIndexListener();
