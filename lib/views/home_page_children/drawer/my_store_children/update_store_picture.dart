import 'dart:convert';
import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/store.dart';
import 'package:ekaon/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

class StorePictureUpdate extends StatefulWidget {
  @override
  _StorePictureUpdateState createState() => _StorePictureUpdateState();
}

class _StorePictureUpdateState extends State<StorePictureUpdate> {
  String base64Image;
  File _file;
  bool _isLoading = false;
  getFromGallery() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((value){
      if(value != null){
        setState(() {
          _file = value;
          base64Image = base64.encode(_file.readAsBytesSync());
        });
      }
    });
  }
  getFromCamera() async {
    await ImagePicker.pickImage(source: ImageSource.camera).then((value) {
      if(value != null){
        setState(() {
          _file = value;
          base64Image = base64.encode(_file.readAsBytesSync());
        });
      }
    });
  }
  crop() async {
    await ImageCropper.cropImage(
      sourcePath: _file.path,
      cropStyle: CropStyle.rectangle,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: "Recadrer l'image",
            activeControlsWidgetColor: kPrimaryColor,
            backgroundColor: Colors.black,
            dimmedLayerColor: Colors.black,
            toolbarColor: Colors.black,
            toolbarWidgetColor: kPrimaryColor,
            cropFrameColor: kPrimaryColor,
            cropGridColor: kPrimaryColor.withOpacity(0.4)
        )
    ).then((value) {
      if(value != null){
        setState(() {
          _file = value;
          base64Image = base64.encode(value.readAsBytesSync());
        });
      }
    });
  }
  hasImage() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            child: Image.file(_file),
          ),
        ),
        Container(
          width: double.infinity,
          height: Percentage().calculate(num: scrh, percent: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: MyWidgets().button(
                  pressed: (){
                    setState(() {
                      _file = null;
                      base64Image= null;
                    });
                  },
                    color: Colors.transparent,
                  child: Icon(Icons.refresh)
                ),
              ),
              Expanded(
                child: MyWidgets().button(
                    pressed: (){
                      setState(() {
                        _isLoading = true;
                      });
                      Store().changePicture(base64Image, "${_file.path.toString().split('/')[_file.path.toString().split('/').length-1].split('.')[1]}", "${_file.path.toString().split('/')[_file.path.toString().split('/').length-1]}").then((value) {
                        if(value){
                          Navigator.push(context, PageTransition(child: HomePage(reFetch: true,)));
                        }
                      }).whenComplete(() => setState(() => _isLoading = false));
                    },
                    color: Colors.transparent,
                    child: Icon(Icons.check_circle,size: 40,color: Colors.green,)
                ),
              ),
              Expanded(
                child: MyWidgets().button(
                    pressed: ()=>crop(),
                    color: Colors.transparent,
                    child: Icon(Icons.crop)
                ),
              )
            ],
          ),
        )
      ],
    );
  }
  showChoice({Orientation orientation}) {
    return Column(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: ()=> getFromCamera(),
            child: Container(
              padding: EdgeInsets.all(orientation == Orientation.portrait ? 70 : 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kPrimaryColor, width: 5)
              ),
              child: Center(
                child: Image.asset("assets/images/camera.png",color: kPrimaryColor,),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: GestureDetector(
            onTap: ()=>getFromGallery(),
            child: Container(
              padding: EdgeInsets.all(orientation == Orientation.portrait ? 70 : 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kPrimaryColor, width: 5)
              ),
              child: Center(
                child: Image.asset("assets/images/gallery.png",color: kPrimaryColor,),
              ),
            ),
          ),
        )
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Image.asset("assets/images/logo.png",width: 60,),
            centerTitle: true,
          ),
          body: OrientationBuilder(
              builder: (context, orientation) {
                return Container(
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: _file != null ? hasImage() : Padding(
                    padding: const EdgeInsets.all(20),
                    child: showChoice(orientation: orientation),
                  ),
                );
              }
          ),
        ),
        _isLoading ? MyWidgets().loader() : Container()
      ],
    );
  }
}
