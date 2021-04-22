import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/model/contact_number.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
class ContactListner{
  BehaviorSubject<List<ContactNumber>> _contacts = BehaviorSubject.seeded([]);
  Stream get stream => _contacts.stream;
  List<ContactNumber> get current => _contacts.value;
  updateAll(List<ContactNumber> data){
    _contacts.add(data);
  }
  clear_all(){
    this.current.clear();
    _contacts.add(this.current);
  }
  append({Map obj}){
    List data = this.current;
    data.add(new ContactNumber(
      number: obj['number'],
      id: null
    ));
    _contacts.add(data);
    serverAdd(obj['number']);
  }
  updateId(id, number){
//    List<> data = this.current;
//    data.where((element) => element.number == number).toList()[0].id = id;
    this.current.where((element) => element.number == number).toList()[0].id = id;
    _contacts.add(this.current);
  }
  remove(id){
    this.current.removeWhere((element) => element.id == id);
    _contacts.add(this.current);
    this.serverRemove(id);
  }
  Future serverAdd(number) async {
    try{
      final respo = await http.get("$url/v1/addPhone/${user_details.id}/$number",headers: {
        "accept" : "application"
      });
      var data = json.decode(respo.body);
      Fluttertoast.showToast(msg: "${data['message']}");
      if(respo.statusCode == 200){
        this.updateId(data['data']['id'], number);
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }
  Future serverRemove(id) async {
    try{
      final respo = await http.delete("$url/v1/removePhone/$id",headers: {
        "accept" : "application/json"
      });
      var data = json.decode(respo.body);
      Fluttertoast.showToast(msg: "${data['message']}");
      if(respo.statusCode == 200){
        return true;
      }
      return false;
    }catch(e){
      print(e);
      return false;
    }
  }
}
ContactListner contactListner = ContactListner();