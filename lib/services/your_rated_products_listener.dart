import 'package:rxdart/rxdart.dart';

class YourRatedProductsListener{
  BehaviorSubject<List> _yourRatedProducts = BehaviorSubject.seeded([]);
  Stream get stream$ => _yourRatedProducts.stream;
  List get current => _yourRatedProducts.value;

  updateAll(List data) {
    _yourRatedProducts.add(data);
  }
  append(Map obj){
    this.current.add(obj);
    _yourRatedProducts.add(this.current);
  }
  bool productIsRated(int productId) {
    for(var rated in this.current){
      print("$rated");
      if(rated['product_id'].toString() == productId.toString()){
        return true;
      }
    }
    return false;
  }
}
YourRatedProductsListener yourRatedProductsListener = YourRatedProductsListener();