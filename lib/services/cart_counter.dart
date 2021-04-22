import 'package:rxdart/rxdart.dart';

class CartCounter {
  BehaviorSubject<int> _count = new BehaviorSubject.seeded(0);
  Stream get stream$ => _count.stream;
  int get current => _count.value;

  updateCount(int count){
    _count.add(count);
  }
}
CartCounter cartCounter = CartCounter();