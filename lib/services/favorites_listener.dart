//import 'package:rxdart/rxdart.dart';
//
//class FavoriteStore{
//  BehaviorSubject<List> _store = BehaviorSubject.seeded([]);
//  Stream get $stream => _store.stream;
//  List get current => _store.value;
//  update({List newData}){
//    _store.add(newData);
//  }
//  append({Map newObj}){
//    List data = current;
//    data.add(newObj);
//    _store.add(data);
//  }
//}
//FavoriteStore favoriteStore = FavoriteStore();
//
//
//class FavoriteProduct {
//  BehaviorSubject<List> _product = BehaviorSubject.seeded([]);
//  Stream get $stream => _product.stream;
//  List get current => _product.value;
//  update({List newData}){
//    _product.add(newData);
//  }
//  append({Map newObj}){
//    List data = current;
//    data.add(newObj);
//    _product.add(data);
//  }
//}
//FavoriteProduct favoriteProduct = FavoriteProduct();
