import 'dart:convert';
import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/user_profile.dart';
import 'package:ekaon/views/home_page.dart';
import 'package:ekaon/views/home_page_children/drawer/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

class UpdateProfilePicture extends StatefulWidget {
  @override
  _UpdateProfilePictureState createState() => _UpdateProfilePictureState();
}

class _UpdateProfilePictureState extends State<UpdateProfilePicture> {
  Future<File> _file;
  File toSend;
  String base64Image;
  String name;
  String extension;
  bool _isLoading = false;
  Future<void> chooseImageFromGal() async{
    setState(() {
      _file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
    if(_file != null){
      var dd = await _file;
      setState(() {
        toSend = dd;
        name = toSend.path.toString().split('/')[toSend.path.toString().split('/').length-1];
        extension = name.split('.')[1];
        name = name.split('.')[0];
        base64Image = base64.encode(toSend.readAsBytesSync());
      });
    }
    print(name);
    print(extension);
  }
  Future<void> chooseImageFromCam() async{

    setState(() {
      _file = ImagePicker.pickImage(source: ImageSource.camera);
    });
    if(_file != null){
      var dd = await _file;
      setState(() {
        toSend = dd;
        name = toSend.path.toString().split('/')[toSend.path.toString().split('/').length-1];
        extension = name.split('.')[1];
        name = name.split('.')[0];
        base64Image = base64.encode(toSend.readAsBytesSync());
      });
    }
    print(name);
    print(extension);
  }
  Future crop() async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: toSend.path,
        cropStyle: CropStyle.circle,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: "Crop image",
            activeControlsWidgetColor: kPrimaryColor,
            backgroundColor: Colors.black,
            dimmedLayerColor: Colors.black,
            toolbarColor: Colors.black,
            toolbarWidgetColor: kPrimaryColor,
            cropFrameColor: kPrimaryColor,
            cropGridColor: kPrimaryColor.withOpacity(0.4)
        )
    );
    if(cropped != null){
      setState(() {
        toSend = cropped;
        name = toSend.path.toString().split('/')[toSend.path.toString().split('/').length-1];
        extension = name.split('.')[1];
        name = name.split('.')[0];
        base64Image = base64.encode(toSend.readAsBytesSync());
      });
    }
    print(name);
    print(extension);
  }
  Widget _showImage(){
    return Column(
      children: [
        Expanded(
          child: Container(
            width: scrw,
            height: scrh,
            child: Image.file(toSend),
          ),
        ),
        Container(
          width: double.infinity,
          height: scrh > 700 ? scrh/13 : scrh/10,
          child: Row(
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  elevation: 0,
                  color: Colors.transparent,
                  onPressed: ()=> setState(() => toSend = null),
                  child: Center(
                    child: Icon(Icons.refresh),
                  ),
                ),
              ),
              Expanded(
                child: RaisedButton(
                  splashColor: Colors.grey[200],
                  color: Colors.transparent,
                  elevation: 0,
                  onPressed: () async {
                    print("ASDSAD");
                    setState(() => _isLoading = true);
                    User().uploadPicture(base64Image, name, extension).then((value) async {
                      if(value) {
                        Navigator.of(context).pop();
                        print("Hash");
                        Navigator.of(context).pop();
                        print("Hash");
                        Navigator.push(context, PageTransition(child: ProfilePage(), type: PageTransitionType.downToUp));
                      }else{
                        Fluttertoast.showToast(msg: "An Error has occurred");
                      }
                    }).whenComplete(() => setState(() => _isLoading = false));
                  },
                  child: Center(
                    child: Icon(Icons.check_circle, size: 40,color: kPrimaryColor,),
                  ),
                ),
              ),
              Expanded(
                child: RaisedButton(
                  color: Colors.transparent,
                  elevation: 0,
                  onPressed: () => crop(),
                  child: Center(
                    child: Icon(Icons.crop),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
  _showChoice() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: kPrimaryColor, width: 2),
                  borderRadius: BorderRadius.circular(10)
              ),
              child: InkWell(
                hoverColor: kPrimaryColor,
                splashColor: kPrimaryColor.withOpacity(0.7),
                onTap: (){
                  chooseImageFromCam();
                },
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(7))
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Text("Camera :",style: TextStyle(
                        color: Colors.white,
                          fontWeight: FontWeight.bold ,
                          fontSize: scrw > 700 ? scrw/35 : scrw/25
                      ),),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Center(
                          child: Icon(Icons.camera, color: kPrimaryColor,size: scrw > 700 ? scrw/10 : scrw/5,),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      child: Text("Choosing this will redirect you directly to your camera and after capturing an image, the image you just captured will be displayed on your screen",style: TextStyle(
                          color: Colors.black54,
                          fontSize: scrw > 700 ? scrw/40 : scrw/30
                      ),textAlign: TextAlign.justify,),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: scrh/20,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: kPrimaryColor, width: 2),
                  borderRadius: BorderRadius.circular(10)
              ),
              child: InkWell(
                hoverColor: kPrimaryColor,
                splashColor: kPrimaryColor.withOpacity(0.7),
                onTap: (){
                  chooseImageFromGal();
                },
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(7))
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      child: Text("Gallery :",style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold ,
                          fontSize: scrw > 700 ? scrw/35 : scrw/25
                      ),),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Center(
                          child: Icon(Icons.photo_album, color: kPrimaryColor,size: scrw > 700 ? scrw/10 : scrw/5,),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      child: Text("Choosing this will redirect you to your gallery and whatever photo you choose will be displayed on your screen",style: TextStyle(
                          color: Colors.black54,
                          fontSize: scrw > 700 ? scrw/40 : scrw/30
                      ),textAlign: TextAlign.justify,),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
        backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text("Update picture",style: TextStyle(
                color: kPrimaryColor
            ),),
          ),
          body: Container(
            width: double.infinity,
            child: toSend == null ? _showChoice() : _showImage(),
          ),
        ),
        _isLoading ? MyWidgets().loader() : Container()
      ],
    );
  }
}
