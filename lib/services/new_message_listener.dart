import 'package:rxdart/rxdart.dart';

class NewMessageCounter {
  BehaviorSubject<int> _count = BehaviorSubject.seeded(0);
  Stream get stream$ => _count.stream;
  int get current => _count.value;

  updateCount(int count){
    _count.add(count);
    print("ASDSAD");
  }

  countFetcher(List messages) {
    var counted = 0;
    for(var x in messages){
      print("${x['new_messages']}");
      if(x['new_messages'] != null){
        counted += x['new_messages'];
      }
    }
    _count.add(counted);
  }
}
NewMessageCounter newMessageCounter = NewMessageCounter();