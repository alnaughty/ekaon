class FCM_token{
  final fcm_token;
  FCM_token({this.fcm_token});
  FCM_token.fromData(Map<String,dynamic> data) :
        fcm_token  = data['fcm_token'];
  Map<String,dynamic> toJson() => {
    'fcm_token' : fcm_token
  };
}