import 'package:rxdart/rxdart.dart';

class DiscountListener{
  BehaviorSubject<List> _discounts = BehaviorSubject.seeded([]);
  Stream get stream$ => _discounts.stream;
  List get current => _discounts.value;

  updateAll(List data){
    _discounts.add(data);
  }

  append(Map data){
    this.current.add(data);
    _discounts.add(this.current);
  }
  remove(int id){
    this.current.removeWhere((element) => element['id'] == id);
    _discounts.add(this.current);
  }
  update(int id, Map newData){

    this.current.removeWhere((element) => element['id'] == id);
    append(newData);
//    _discounts.add(this.current);
    print(this.current);
  }
}

DiscountListener discountListener = DiscountListener();