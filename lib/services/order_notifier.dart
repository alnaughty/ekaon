import 'package:ekaon/global/variables.dart';
import 'package:rxdart/rxdart.dart';

class StoreOrderNotifierListener{
  BehaviorSubject<int> _storeOrderNotifier = BehaviorSubject.seeded(0);
  Stream get stream$ => _storeOrderNotifier.stream;
  int get current => _storeOrderNotifier.value;
  update(int data){
    if(this.current > data){
      if(data >= 0){
        _storeOrderNotifier.add(data);
      }else{
        _storeOrderNotifier.add(0);
      }
    }else{
      _storeOrderNotifier.add(data);
    }
  }
}
StoreOrderNotifierListener storeOrderNotifierListener = StoreOrderNotifierListener();