import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/interrupts.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/model/User.dart';
import 'package:ekaon/services/convo_listener.dart';
import 'package:ekaon/services/keyboard_listener.dart';
import 'package:ekaon/services/message_listener.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/preferences.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ChatBox extends StatefulWidget {
  final Map recipient;
  final bool isStore;
  final int storeId;
  final int storeOwnerId;
  final Map storeDetails;
  ChatBox({Key key, @required this.recipient, @required this.isStore,@required this.storeId,@required this.storeOwnerId, @required this.storeDetails}) : super(key : key);
  @override
  _ChatBoxState createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  TextEditingController _toSend = new TextEditingController();
  bool _isKeyboardActive = false;
  String composing = '';
  List b64Images = [];
  bool _showImageOptions = true;
  KeyboardBloc _bloc = KeyboardBloc();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(this.mounted){
      KeyboardVisibility.onChange.listen((k) {
        setState(() {
          _isKeyboardActive = k;
        });
      });
      _bloc.start();
    }
    convoListener.getConvo(storeId: widget.storeId,storeOwnerId: widget.storeOwnerId,customerId: widget.recipient['id']);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    messageListener.updateChatroomId(null);
  }

  pickFromCam() async {
    await ImagePicker().getImage(source: ImageSource.camera).then((file) {
      if(file != null){
        print(file.path);
        var ext = file.path.split('/')[file.path.split('/').length -1].split('.')[1];
        var name = file.path.split('/')[file.path.split('/').length -1].split('.')[0];
        var b64 = base64Encode(new File(file.path).readAsBytesSync());

        setState(() {
          b64Images.add({
            "\"base64\"" : "\"data:image/$ext;base64,$b64\"",
            "\"name\"" : "\"$name\"",
            "\"path\"" : "\"${file.path}\""
          });
        });
      }
    });
  }
  crop(int index) async {
    ImageCropper.cropImage(
        sourcePath: b64Images[index]["\"path\""].toString().replaceAll('\"', ''),
    ).then((File file) {
      if(file != null){
        var ext = file.path.split('/')[file.path.split('/').length -1].split('.')[1];
        var b64 = base64Encode(file.readAsBytesSync());
        setState(() {
          b64Images[index]["\"base64\""] = "\"data:image/$ext;base64,$b64\"";
        });
      }
    });
  }
  pickFromGal() async {
    await ImagePicker().getImage(source: ImageSource.gallery).then((file) {
      print(file.path);
      var ext = file.path.split('/')[file.path.split('/').length -1].split('.')[1];
      var name = file.path.split('/')[file.path.split('/').length -1].split('.')[0];
      var b64 = base64Encode(new File(file.path).readAsBytesSync());

      setState(() {
        b64Images.add({
          "\"base64\"" : "\"data:image/$ext;base64,$b64\"",
          "\"name\"" : "\"$name\"",
          "\"path\"" : "\"${file.path}\""
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Scaffold(
          resizeToAvoidBottomPadding: Platform.isIOS,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(widget.isStore ? "${StringFormatter(string: widget.storeDetails['name']).titlize()}" : "${StringFormatter(string: widget.recipient['first_name']).titlize()} ${StringFormatter(string: widget.recipient['last_name']).titlize()}",style: TextStyle(
            color: kPrimaryColor
          ),),
          centerTitle: true,
        ),
        body: StreamBuilder(
          stream: _bloc.stream,
          builder: (context, snapshot) {
            return Container(
              width: double.infinity,
//                height: MediaQuery.of(context).size.height,
              height: MediaQuery.of(context).size.height - (Platform.isAndroid ? Percentage().calculate(num: _bloc.keyboardUtils.keyboardHeight, percent: scrh > 700 ? 140 : 135) : 0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: StreamBuilder(
                        stream: convoListener.stream,
                        builder: (context, snapshot) => snapshot.hasData ? snapshot.data['conversation'].length > 0 ? ListView.builder(
                            physics: BouncingScrollPhysics(),
                            controller: convoListener.scrollController,
                            shrinkWrap: true,
                            itemCount: snapshot.data['conversation'].length,
                            itemBuilder: (context, index) => box(snapshot.data['conversation'][index])
                        ) : Center(
                          child: Text("You have no conversation with this user"),
                        ) : Center(
                          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),),
                        ),
                      ),
                    ),
                  ),

                  if(b64Images.length > 0)...{
                    Container(
                      width: double.infinity,
                      height: Percentage().calculate(num: scrh, percent: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: b64Images.length,
                        itemBuilder: (_, index) => GestureDetector(
                          onLongPress: (){
                            showModalBottomSheet(
                                context: context,
                                builder: (_) => Container(
                                  height: 130,
                                  width: double.infinity,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.remove_circle_outline),
                                        title: Text("Remove"),
                                        onTap: (){
                                          Navigator.of(context).pop(null);
                                          setState(() {
                                            b64Images.removeAt(index);
                                          });
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.crop),
                                        title: Text("Crop"),
                                        onTap: (){
                                          Navigator.of(context).pop(null);
                                          this.crop(index);
                                        },
                                      )
                                    ],
                                  ),
                                )
                            );
                          },
                          child: Container(
                            height: Percentage().calculate(num: scrh, percent: 10) - 20.0,
                            margin: const EdgeInsets.only(right: 20),
                            child: Image.memory(base64.decode(b64Images[index]["\"base64\""].toString().replaceAll('\"', '').split(',')[1])),
                          ),
                        ),
                      )
                    ),
                  },
                  Container(
                      width: double.infinity,
//                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: <Widget>[
                          AnimatedContainer(
                            width: _showImageOptions ? 100 : 50,
                              duration: Duration(milliseconds: 500),
                            child: Row(
                              children: [
                                if(_showImageOptions)...{
                                  Expanded(
                                    child: IconButton(icon: Icon(Icons.camera_alt), onPressed: (){
                                      pickFromCam();
                                    }),
                                  ),
                                  Expanded(
                                    child: IconButton(icon: Icon(Icons.photo), onPressed: (){
                                      pickFromGal();
                                    }),
                                  )
                                }else...{
                                  IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: (){
                                    setState(() {
                                      _showImageOptions = true;
                                    });
                                  }),
                                }
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                              child: Theme(
                                data: ThemeData(
                                    primaryColor: kPrimaryColor
                                ),
                                child: TextField(
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
//                                  inputFormatters: [
//                                    UpperCaseTextFormatter()
//                                  ],
                                  onTap: () async {
                                    await Future.delayed(Duration(milliseconds: 600));
                                    convoListener.scrollController.animateTo(convoListener.scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 700), curve: Curves.fastLinearToSlowEaseIn);
                                  },
                                  controller: _toSend,
                                  maxLines: 3,
                                  onChanged: (text) => setState(() {

                                    _showImageOptions = !(text.length > 0);
                                    composing = text;
                                  }),
                                  minLines: 1,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    hintText: "Message",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          b64Images.length == 0 && composing.length == 0 ? Container() : IconButton(
                            onPressed: () async {
                              convoListener.append("${widget.storeOwnerId == user_details.id ? "${widget.storeDetails['name']}" : "${StringFormatter(string: user_details.first_name).titlize()} ${StringFormatter(string: user_details.last_name).titlize()}"}","${
                                  widget.storeOwnerId == user_details.id ? "${widget.storeDetails['picture']}" :"${user_details.profile_picture}"
                              }",toSend: {
                                "id" : -1,
                                "message" : "${_toSend.text}",
                                "store_id" : widget.storeId,
                                "store_owner_id" : widget.storeOwnerId,
                                "customer_id" : widget.recipient['id'],
                                "sender_type" : widget.storeOwnerId != user_details.id ? 1 : 0,
                                "sender_id" : user_details.id.toString(),
                              }, images: b64Images);
                              setState(() {
                                b64Images.clear();
                                _toSend.clear();
                              });
                              await Future.delayed(Duration(milliseconds: 600));
                              convoListener.scrollController.animateTo(convoListener.scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 700), curve: Curves.fastLinearToSlowEaseIn);
                              },
                            icon: Icon(Icons.send,color: kPrimaryColor,size: 30,),
                          )
                        ],
                      )
                  )
                ],
              ),
            );
          }
        )
      ),
    );
  }

  int selectedMessageId;

  Widget box(Map data) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 5),
    child: Container(
//          width: Percentage().calculate(num: double.parse(data['message'].toString().trim().replaceAll(" ", "").length.toString()) * 2,percent: double.parse(data['message'].toString().trim().replaceAll(" ", "").length.toString()) * 150),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 5),
        alignment: int.parse(data['sender_id'].toString()) == user_details.id ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        child: Row(
          mainAxisAlignment: int.parse(data['sender_id'].toString()) == user_details.id ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //image of the one you are chatting
            int.parse(data['sender_id'].toString()) != user_details.id ? Container(
              margin: const EdgeInsets.only(right: 10),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(1000),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[400],
                    offset: Offset(3,3),
                    blurRadius: 2
                  )
                ],
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: widget.isStore ? widget.storeDetails['picture'] == null ? AssetImage("assets/images/default_store.png") : NetworkImage("https://ekaon.checkmy.dev${widget.storeDetails['picture']}") : widget.recipient['profile_picture'] == null ? AssetImage("assets/images/no-image-available.png") : NetworkImage("https://ekaon.checkmy.dev${widget.recipient['profile_picture']}")
                )
              ),
            ) : Container(),

            //message
            Expanded(
              child: Container(
                width: double.infinity,
                alignment: int.parse(data['sender_id'].toString()) == user_details.id ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,

                child: Column(
                  crossAxisAlignment: int.parse(data['sender_id'].toString()) == user_details.id ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    //with color
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          if(selectedMessageId == int.parse(data['id'].toString())){
                            selectedMessageId = null;
                          }else{
                            selectedMessageId = int.parse(data['id'].toString());
                          }
                        });
                      },
                      child: Container(
                        padding: data['message'] == null ? EdgeInsets.all(0) : EdgeInsets.symmetric(horizontal: Percentage().calculate(num: MediaQuery.of(context).size.width, percent: 1.5),vertical: Percentage().calculate(num: MediaQuery.of(context).size.width, percent: 0.5)),
                        decoration: BoxDecoration(
                            color: data['message'] == null ? Colors.transparent : int.parse(data['sender_id'].toString()) == user_details.id ? Colors.green : Colors.grey[200],
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(7),topLeft: data['sender_id'] == user_details.id ? Radius.circular(7) : Radius.circular(0),bottomRight: Radius.circular(7),topRight: data['sender_id'] == user_details.id ? Radius.circular(0) : Radius.circular(7))
                        ),
                        child: Column(
                          crossAxisAlignment: int.parse(data['sender_id'].toString()) == user_details.id ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if(data['message'] != null)...{
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                child: Text("${data['message']}",style: TextStyle(
                                    color: data['sender_id'] == user_details.id ? Colors.white : Colors.black,
                                    fontSize: Theme.of(context).textTheme.subtitle1.fontSize
                                ),),
                              ),
                            },
                            if(data['images'] != null)...{
                              for(var image in data['images'])...{
                                GestureDetector(
                                  onTap: (){
                                    Interrupts().showImageFull(image['url'], context);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      constraints: BoxConstraints(
                                          maxHeight: Percentage().calculate(num: scrh, percent: 20)
                                      ),

                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Image.network("https://ekaon.checkmy.dev${image['url']}"),
                                    ),
                                  )
                                )
                              }
                            }
                          ],
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      height: selectedMessageId == int.parse(data['id'].toString()) ? Theme.of(context).textTheme.subtitle1.fontSize - 2 : 0,
                      duration: Duration(milliseconds: 500),
                      child: Text(data['id'] > 0 ? "${convoListener.format(data['created_at'])}" : "${convoListener.format(DateTime.now().toString())}",style: TextStyle(
                          fontSize: Theme.of(context).textTheme.subtitle1.fontSize - 2,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic
                      ),),
                    )
                  ],
                ),
              )
            ),

            //image of you
            int.parse(data['sender_id'].toString()) == user_details.id ? Container(
              margin: const EdgeInsets.only(left: 10),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.grey[400],
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[400],
                        offset: Offset(-3,3),
                        blurRadius: 2,
                    )
                  ],
                  borderRadius: BorderRadius.circular(1000),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: user_details.profile_picture == null ? AssetImage("assets/images/no-image-available.png") : NetworkImage("https://ekaon.checkmy.dev${user_details.profile_picture}")
                )
              ),
            ) : Container(),

            //indicator
            int.parse(data['sender_id'].toString()) == user_details.id  ? Container(
              width: 15,
              height: 15,
              child: int.parse(data['sender_id'].toString()) == -1 && int.parse(data['sender_id'].toString()) == user_details.id ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.green),strokeWidth: 1.5,) : Icon(data['id'] == null ? Icons.check_circle_outline : Icons.check_circle,color: Colors.green,size: 15,),
            ) : Container(),
          ],
        )
//          child: Column(
//            crossAxisAlignment: data['sender_id'] == userDetails['id'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//            children: <Widget>[
//              Container(
//                decoration: BoxDecoration(
//                  color:  data['sender_id'] == userDetails['id'] ? Colors.green : Colors.grey[200],
//                  borderRadius: BorderRadius.only(topLeft: Radius.circular(7),bottomLeft: data['sender_id'] == userDetails['id'] ? Radius.circular(7) : Radius.circular(0),topRight: Radius.circular(7),bottomRight: data['sender_id'] == userDetails['id'] ? Radius.circular(0) : Radius.circular(7))
//                ),
//                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
//                child: Text("${data['message']}",style: TextStyle(
//                    color: data['sender_id'] == userDetails['id'] ? Colors.white : Colors.black
//                ),),
//              ),
//              AnimatedContainer(
//                height: _selectedChatId == data['id'] ? 15 : 0,
//                duration: Duration(milliseconds: 600),
//                child: Text(data['id'] == -1 && data['sender_id'] == userDetails['id'] ? "Sending..." : "${convoListener.format(data['created_at'])}",style: TextStyle(
//                  color: Colors.grey[400],
//                  fontSize: 12.5
//                ),),
//              )
//            ],
//          )
    ),
  );
}


