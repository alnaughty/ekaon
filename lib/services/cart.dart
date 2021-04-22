
import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/services/cart_counter.dart';
import 'package:ekaon/services/products.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
class CartAuth{
  BehaviorSubject<List> _cart = BehaviorSubject.seeded([]);
  Stream get stream$ => _cart.stream;
  List get current => _cart.value;

  updateState(){
    _cart.add(this.current);
    cartCounter.updateCount(this.itemLength);
  }
  //Stream of data
  updateAll({List data})
  {
    _cart.add(data);
    cartCounter.updateCount(this.itemLength);
  }
  bool checkIfProductExists({int productIds, String variation_ids, Map data}){
    for(var product in data['details']){
      if(product['product_id'] == productIds && variation_ids == product['selected_variation_ids']){
        return true;
      }
    }
    return false;
  }
  getIndexOf({int productId, String variation_ids, Map data}){
    for(var product in data['details']){
      if(product['product_id'] == productId && variation_ids == product['selected_variation_ids']){
        return data['details'].indexOf(product);
      }
    }
    return -1;
  }
  Future exist({int indexToDelete, int quantity, int cart_id, int indexToUpdate}) async {
    print("DELETE: $indexToDelete");
    print("UPDATE: $indexToUpdate");
    int id = int.parse(this.current.where((element) => element['id'] == cart_id).toList()[0]['details'][indexToDelete]['id'].toString());
    this.current.where((element) => element['id'] == cart_id).toList()[0]['details'][indexToUpdate]['quantity'] += quantity;
    this.current.where((element) => element['id'] == cart_id).toList()[0]['details'].removeAt(indexToDelete);
    return await this.removeItem(id: id,update: true);
  }
  Future addToCart({Map product, String variationIds}) async {
     Map body = {
       "store_id" : product['store_id'].toString(),
       "user_id" : user_details.id.toString(),
       "product_id" : product['id'].toString(),
       "quantity" : product['quantity'].toString(),
       "total" : product['sub_total'].toString()
     };
     if(variationIds != null){
       body['variation_ids'] = variationIds;
     }else{

       if(product['variations'] != null && product['variations'].length > 0){
         List temp = [];
         for(var te in product['variations']){
           temp.add(te['default_variation_id']);
         }
         String ff =temp.join(',');
         body['variation_ids'] = ff;
       }
     }
     print(body);

     return await this.add(body: body);
  }

  appendCart({Map data})
  {
    //check if store exists
    if(checkStore(storeId: data['store_id'])){
      //check if product exists see variation ids && product_id
      if(this.checkIfProductExists(
          productIds: data['details']['product_id'],
          variation_ids: data['details']['selected_variation_ids'],
          data: this.current.where((element) => element['store_id'] == data['store_id']).toList()[0])
      ) {
        print("EXISTS");
        this.current.where((element) => element['store_id'] == data['store_id']).toList()[0]['details'].where((e) => e['product_id'] == data['details']['product_id'] && e['selected_variation_ids'] == data['details']['selected_variation_ids']).toList()[0]['quantity'] = data['details']['quantity'];
        this.current.where((element) => element['store_id'] == data['store_id']).toList()[0]['details'].where((e) => e['product_id'] == data['details']['product_id'] && e['selected_variation_ids'] == data['details']['selected_variation_ids']).toList()[0]['total'] = data['details']['total'];
      }else{
        print("NOT EXISTS");
        this.current.where((element) => element['store_id'] == data['store_id']).toList()[0]['details'].add(data['details']);
      }
      _cart.add(this.current);

    }else{
      //new store in cart
      Map tempDetail = data['details'];
      data['details'] = [];
      data['details'].add(tempDetail);
      this.current.add(data);
      this._cart.add(this.current);


    }
    cartCounter.updateCount(this.itemLength);

//    List cart = this.current;
//    Map tempDetail = data['details'];
//    data['details'] = [];
//    data['details'].add(tempDetail);
//    cart.add(data);
//    this._cart.add(cart);
//    cartCounter.updateCount(this.itemLength);
//    print("CART DATA : ${this.current}");
  }
  int get itemLength {
    int count = 0;
    for(var cart in this.current){
      count += cart['details'].length;
    }
    return count;
//    for(var)
  }
  removeCart({int cartId, bool removeLocal = false})
  {
    List cart = this.current;
    cart.removeWhere((element) => element['id'] == cartId);
    this._cart.add(cart);
    cartCounter.updateCount(this.itemLength);
    if(!removeLocal){
      cartAuth.remove(cartId: cartId);
    }
  }
  removeProduct({int id, int storeId})
  {

    List _list = this.current;
    Map store = _list.where((element) => element['store_id'] == storeId).first;
    print("STORE : $store");
    int storeIndex = _list.indexOf(store);
    _list[storeIndex]['details'].removeWhere((e) => e['id'] == id);
    this._cart.add(_list);
    cartCounter.updateCount(this.itemLength);
    this.removeItem(id: id);
//    control(productId: productId, quantity: 0, total: 0.0,cartId: cartId, toDelete: 1);
  }
  removeItem({int id, bool update = false}) async {
    try{
      await http.delete("$url/v1/cart/remove-item/$id").then((respo) {
        if(respo.statusCode == 200){
          Fluttertoast.showToast(msg: "Item removed successfully");
          if(update){
            _cart.add(this.current);
          }
          return true;
        }
        Fluttertoast.showToast(msg: "Error ${respo.statusCode}, ${respo.reasonPhrase}");
        return false;
      });
    }catch(e){
      print("REMOVE ERROR");
      return false;
    }
  }
  appendProduct({Map data, int quantity, double total, int storeId})
  {
    List _list = this.current;
    Map store = _list.where((element) => element['store_id'] == storeId).toList()[0];
    int storeIndex = _list.indexOf(store);
    Map _newObj = {
      "id" : _list[storeIndex]['id'],
      "cart_id" : _list[storeIndex]['id'],
      "product_id" : data['id'],
      "quantity" : quantity,
      "total" : total,
      "product" : data
    };
    _list[storeIndex]['details'].add(_newObj);
    this._cart.add(_list);
    cartCounter.updateCount(this.itemLength);
    control(productId: data['id'],quantity: quantity,total: total,cartId: store['id'], toDelete: 0);
  }
  updateProduct({int store_id, Map data})
  {
    List _list = this.current;
    Map store = _list.where((element) => element['store_id'] == store_id).toList()[0];
    int storeIndex = _list.indexOf(store);
    Map product = store['details'].where((e)=> e['product_id'] == data['id']).toList()[0];
    int productIndex = store['details'].indexOf(product);
    _list[storeIndex]['details'][productIndex]['quantity'] += data['quantity'];
    _list[storeIndex]['details'][productIndex]['total'] += data['sub_total'];
    this._cart.add(_list);
    cartCounter.updateCount(this.itemLength);
    control(productId: data['id'],quantity: _list[storeIndex]['details'][productIndex]['quantity'], total: _list[storeIndex]['details'][productIndex]['total'],cartId: store['id'], toDelete: 0);
  }

  //API Calls/func
  Future add({Map body}) async {
    try{
      final respo = await http.post("$url/v1/addToCart",headers: {
        "accept" : "application/json"
      }, body: body
      );
      var data = json.decode(respo.body);
      if(respo.statusCode == 200 || respo.statusCode == 201){
        print(data);
        Fluttertoast.showToast(msg: "Added to cart");
        appendCart(data: data);
        return true;
      }
      Fluttertoast.showToast(msg: "Error ${respo.statusCode}, ${respo.reasonPhrase}");
      return false;
    }catch(e){
      print(e);
      Fluttertoast.showToast(msg: "An unexpected error has occurred");
      return false;
    }
  }
  Future remove({int cartId}) async {
    try{
      final respo = await http.delete("$url/v1/removeCart/${cartId.toString()}",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      print(data);
      Fluttertoast.showToast(msg: "${data['message']}");
      if(respo.statusCode == 200){
        return true;
      }
      return false;
    }catch(e){
      print(e);
      Fluttertoast.showToast(msg: "An unexpected error has occurred");
      return false;
    }
  }
  Future control({int productId, int quantity, double total, int cartId, int toDelete}) async {
    try{
      final respo = await http.post("$url/v1/control",headers: {
        "accept" : "application/json"
      }, body: {
        "product_id" : productId.toString(),
        "quantity" : quantity.toString(),
        "total" : total.toString(),
        "cart_id" : cartId.toString(),
        "toDelete" : toDelete.toString(),
      });
      var data = json.decode(respo.body);

      if(respo.statusCode == 200 || respo.statusCode == 201){
        Fluttertoast.showToast(msg: "Success");
        return true;
      }
      Fluttertoast.showToast(msg: "Error ${respo.statusCode}, ${respo.reasonPhrase}");
      return false;
    }catch(e){
      print(e);
      return false;
    }
  }
  bool checkStore({int storeId}) {
    List data = this.current;
    if(data.length > 0){
      try{
//        print(data.where((element) => element['store_id'] == storeId+1).first);
        if(data.where((element) => element['store_id'] == storeId).first != null){
//          print("adi");
          return true;
        }
        return false;
      }catch(e){
//        print("HAHA GAGO");
        return false;
      }
      return true;
    }
    return false;
  }
//  bool checkProduct({Map data, int storeId,List selectedVariations})
//  {
//    print("VARIATION : $selectedVariations");
//    try{
//      List list = this.current;
//      Map store = list.where((element) => element['store_id'] == storeId).toList()[0];
//      Map product = store['details'].where((e)=> e['product_id'] == data['id']).toList()[0];
//      if(product != null){
//        print("$product");
////        print("Adi na an product ig update an data");
////        if(product['selected_variation_ids'] == data[])
//        return true;
//      }
//      return false;
//    }catch(e){
//      print(e);
//      return false;
//    }
//  }
}
CartAuth cartAuth = CartAuth();