import 'dart:convert';
import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/services/my_product_listener.dart';
import 'package:ekaon/services/position_listener.dart';
import 'package:ekaon/services/your_rated_products_listener.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ProductAuth{
  Future add({Map body}) async {

    try{
      String _isMeal = "0";
//      if(isMeal == "Yes"){
//        _isMeal = "1";
//      }
//      Map body = {
//        "store_id" : storeId.toString(),
//        "name" : name,
//        "description" : description,
//        "price" : price.toString(),
//        "category_ids" : categoryIds,
//        "is_meal" : _isMeal.toString(),
//        "variation_ids" : variation_ids,
//      };
//      if(insert.length != 0){
//        body['data'] = "$insert";
//      }
//      print(_isMeal);
      final respo = await http.post("$url/v1/addProduct",headers: {
        "Accept":"application/json"
      }, body: body);
      var data = json.decode(respo.body);
      print("$data");
      if(respo.statusCode == 200){
        myProductListener.append(newObj: data['data']);
        return data['data'];
      }
      return null;
    }catch(e){
      print(e);
      return null;
    }
  }
  Future getRelatedProducts(String categories, int pId, int storeId) async {
    try{
      final respo = await http.post("$url/v1/relatedProducts",headers: {
        "accept" : "application/json"
      }, body: {
        "categories" : categories,
        "product_id" : "$pId",
        "store_id" : "$storeId"
      });
      var data = json.decode(respo.body);
      if(respo.statusCode == 200){
        return data;
      }
      return null;
    }catch(e){
      print(e.toString());
      return null;
    }
  }
  Future getOtherStoreProducts(int pId, int storeId) async {
    try{
      final respo = await http.post("$url/v1/otherProducts",headers: {
        "accept" : "application/json"
      }, body: {
        "product_id" : "$pId",
        "store_id" : "$storeId"
      });
      var data = json.decode(respo.body);
      if(respo.statusCode == 200)
      {
        return data['products'];
      }
      return null;
    }catch(e){
      return null;
    }
  }
  String ratingCalculator({List ratings}) {
    int star1Length = ratings.where((element) => element['rate'] == 1).toList().length;
    int star2Length = ratings.where((element) => element['rate'] == 2).toList().length;
    int star3Length = ratings.where((element) => element['rate'] == 3).toList().length;
    int star4Length = ratings.where((element) => element['rate'] == 4).toList().length;
    int star5Length = ratings.where((element) => element['rate'] == 5).toList().length;
    double val = ((5 * star5Length) + (4 * star4Length) + (3 * star3Length) + (2 * star2Length) + (1 * star1Length)) / (star5Length + star4Length +star3Length+ star2Length+ star1Length);
//    String totalAverageRating = double.parse("${((5 * star5Length) + (4 * star4Length) + (3 * star3Length) + (2 * star2Length) + (1 * star1Length)) / (star5Length + star4Length +star3Length+ star2Length+ star1Length)}").toStringAsFixed(2);
    if(val.isNaN || val.isInfinite || val.isNegative){
      return "0";
    }else{
      return val.toStringAsFixed(2);
    }
  }
  Future getFeatured() async {
    try{
      final respo = await http.post("$url/v1/featuredProduct",headers: {
        "accept" : "application/json"
      },body: {
        "userLat" : myPosition.current != null ? myPosition.current.latitude.toString() : "",
        "userLong" : myPosition.current != null ? myPosition.current.longitude.toString() : "",
      });
      var data = json.decode(respo.body);
      if(respo.statusCode == 200){
        return data['products'];
      }
      return null;
    }catch(e){
      print("Featured error $e");
      return null;
    }
  }
  Future uploadImages({image, productId, ext, name}) async
  {
    try{
      final respo = await http.post("$url/v1/upload/product/image",headers: {
        "Accept" : "application/json",
      }, body: {
        "product_id" : productId.toString(),
        "image" : "data:image/$ext;base64,$image",
        "index" : name
      });
      var data = json.decode(respo.body);
      print("UPLOAD DATA : $data");
      if(respo.statusCode == 200){
        Fluttertoast.showToast(msg: "$name upload successful");
        return data['details'];
      }
      Fluttertoast.showToast(msg: "File too large");
      return null;
    }catch(e){
      return null;
    }
  }
  Future removeImage(imageId) async {
    try{
      final respo = await http.delete("$url/removeImage/$imageId",headers: {
        "accept" : "application/json",
        HttpHeaders.authorizationHeader : "Bearer $token"
      });
      var data = json.decode(respo.body);
      if(respo.statusCode == 200){
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
  Future update(int productId, String newName,String newDesc, String newPrice, int available) async {
    try{
      print("NAME : $newName");
      print("Description : $newDesc");
      print("Price : $newPrice");
      final respo = await http.put("$url/v1/updateProduct",headers: {
        "accept" : "application/json"
      },body: {
        "product_id" : "$productId",
        "name" : "$newName",
        "description" : "$newDesc",
        "price" : "$newPrice",
        "isAvailable" : "$available"
      });
      var data = json.decode(respo.body);
      print("DATA : $data");
      if(respo.statusCode == 200){
        myProductListener.updateData(data['data']);
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
  Future addRating(productId,String comment, int rate) async {
    try{
      Map<String,dynamic> body;
      if(comment.isNotEmpty){
         body = {
          "product_id" : "$productId",
          "rate" : "$rate",
          "user_id" : "${user_details.id}",
          "comment" : "$comment"
        };
      }else{
        body = {
          "product_id" : "$productId",
          "rate" : "$rate",
          "user_id" : "${user_details.id}",
        };
      }
      final respo = await http.post("$url/v1/addRating",headers: {
        "accept" : "application/json"
      },body: body);
      var data = json.decode(respo.body);
      print("DATA : $data");
      if(respo.statusCode == 200) {
        yourRatedProductsListener.append(data['data']);
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
  Future addCategory({int productId, int categoryId}) async {
    try{
      await http.put("$url/v1/product/add-category/$productId/$categoryId",headers: {
        "accept" : "application/json"
      }).then((response) {
        var data = json.decode(response.body);
        if(response.statusCode == 200){
          Fluttertoast.showToast(msg: "Category added");
          return data['data'];
        }
        print(data);
        Fluttertoast.showToast(msg: "Error ${response.statusCode}, ${response.reasonPhrase}");
        return null;
      });
    }catch(e){
      this.printWrapped(e);
      Fluttertoast.showToast(msg: "Error adding category, try again later");
      return null;
    }
  }
  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
  Future removeCategory({int productId, int categoryId}) async {
    try{
      return await http.delete("$url/v1/product/remove-category/${productId}/${categoryId}").then((value) {
        var data = json.decode(value.body);
        if(value.statusCode == 200) {
          Fluttertoast.showToast(msg: "Category removed");
          return true;
        }
        print(data);
        Fluttertoast.showToast(msg: "Error ${value.statusCode}, ${value.reasonPhrase}");
        return false;
      });
    }catch(e){
      this.printWrapped(e);
      Fluttertoast.showToast(msg: "Error removing category, try again later $e");
      return false;
    }
  }
  Future deleteProduct({int productId}) async {
    try{
      await http.delete("$url/v1/product/delete/$productId",headers: {
        "accept" : "application/json"
      }).then((response) {
        myProductListener.delete(id: productId);
      });
    }catch(e){
      return null;
    }
  }
}