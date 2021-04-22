import 'package:rxdart/rxdart.dart';

class ChosenCat{
  BehaviorSubject<List> _cat = BehaviorSubject.seeded([]);
  Stream get stream$ => _cat.stream;
  List get current => _cat.value;

  updateAll(List data){
    print(data);
    _cat.add(data);
  }
}
ChosenCat chosenCat = ChosenCat();