import 'package:rxdart/rxdart.dart';

class MyProductListener {
  BehaviorSubject<List> _myProduct = BehaviorSubject.seeded([]);
  Stream get $stream => _myProduct.stream;
  List get current => _myProduct.value;

  update({List newData})
  {
    _myProduct.add(newData);
  }
  append({Map newObj})
  {
    List data = current;
    data.add(newObj);
    _myProduct.add(data);
  }
  delete({int id}) {
    this.current.removeWhere((element) => element['id'] == id);
    _myProduct.add(this.current);
  }
  updateData(Map obj) {
    this.current.where((element) => element['id'] == obj['id']).toList()[0]['name'] = obj['name'];
    this.current.where((element) => element['id'] == obj['id']).toList()[0]['description'] = obj['description'];
    this.current.where((element) => element['id'] == obj['id']).toList()[0]['price'] = obj['price'];
    _myProduct.add(this.current);
  }
  String changeDetected(String toCheck, String type, productId)
  {
    if(this.current.where((element) => element['id'] == productId).toList()[0]['type'] == toCheck){
      return "";
    }
    return toCheck;
  }
  updateImage({int productId, List images})
  {
    List data = current;
    Map product = data.where((element) => element['id'] == productId).toList()[0];
    int productIndex = data.indexOf(product);
    data[productIndex]['images'] = images;
  }
}

MyProductListener myProductListener = MyProductListener();