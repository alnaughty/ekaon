import 'package:ekaon/model/FCM_Token.dart';
import 'package:ekaon/model/UserVerified.dart';
import 'package:ekaon/model/contact_number.dart';

class UserModel {
  final int id;
  final String first_name;
  final String last_name;
  final String email;
  String profile_picture;
  int has_store;
  int notif_length;
  final int user_type;
  int my_store_orders;
  Verified verified;
  List<ContactNumber> contactNumber;
  UserModel({
    this.id,
    this.first_name,
    this.last_name,
    this.email,
    this.my_store_orders,
    this.has_store,
    this.profile_picture,
    this.notif_length,
    this.user_type,
    this.verified,
  });
  UserModel.fromData(Map<String, dynamic> data) :
        email = data['email'],
        first_name = data['first_name'],
        last_name = data['last_name'],
        id = data['id'],
        profile_picture = data['profile_picture'],
        has_store = data['has_store'],
        my_store_orders = data['my_store_orders'],
        user_type = data['userType'],
        notif_length = data['notif_length'],
        verified = Verified.fromData(data['verified']);
  Map<String, dynamic> toJson() => {
    'id' : id,
    'first_name' : first_name,
    "last_name" : last_name,
    "email" : email,
    "profile_picture" : profile_picture,
    'has_store' : has_store,
    "my_store_orders" : my_store_orders,
    "userType" : user_type,
    "notif_length" : notif_length,
    "verified" : verified,
  };
}