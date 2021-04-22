import 'dart:convert';
import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/my_product_listener.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/products.dart';
import 'package:ekaon/views/home_page.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

class UploadProductImage extends StatefulWidget {
  final Map data;
  final bool isInit;
  UploadProductImage({Key key, @required this.data, @required this.isInit}) : super(key : key);
  @override
  _UploadProductImageState createState() => _UploadProductImageState();
}

class _UploadProductImageState extends State<UploadProductImage> {
  List<File> _images = [];
  List<String> _base64Images = [];
  int _selectedImageIndex;
  bool _isLoading = false;
  List _newImageDetails = [];
  Future uploadImages(length) async {

    if(length > 0){
      var name = _images[length - 1].path.split('/')[_images[length - 1].path.split('/').length - 1].split('.')[0];
      var ext = _images[length - 1].path.split('/')[_images[length - 1].path.split('/').length - 1].split('.')[1];
      await ProductAuth().uploadImages(image: _base64Images[length - 1], productId: widget.data['id'], name: name, ext: ext).then((value) {
        if(value != null){
          uploadImages(length - 1);
          _newImageDetails.add(value);
        }else{
          uploadImages(length - 1);
          Fluttertoast.showToast(msg: "An error has occurred while uploading your image");
        }
      });
    }else{
      return true;
    }
  }

  chooseFromGallery() async
  {
    var dd = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(dd != null){
      var base64Image = base64.encode(dd.readAsBytesSync());
      setState(() {
        _images.add(dd);
        _base64Images.add(base64Image);
      });
    }
  }

  chooseFromCamera() async
  {
    var dd = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(dd != null){
      var base64Image = base64.encode(dd.readAsBytesSync());
      setState(() {
        _images.add(dd);
        _base64Images.add(base64Image);
      });
    }
  }
  void crop() async {
    var cropped = await ImageCropper.cropImage(
      sourcePath: _images[_selectedImageIndex].path
    );
    if(cropped != null){
      var base64Image = base64.encode(cropped.readAsBytesSync());
      setState(() {
        _images[_selectedImageIndex] = cropped;
        _base64Images[_selectedImageIndex] = base64Image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !widget.isInit,
      child: Stack(
        children: <Widget>[
          Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Image.asset("assets/images/logo.png", width: 60,),
              centerTitle: true,
              automaticallyImplyLeading: !widget.isInit,
            ),
            body: OrientationBuilder(
              builder: (context, orientation) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: Text("Upload images for your new product",style: TextStyle(
                          fontSize: Percentage().calculate(num: scrh, percent: scrw > 700 ? 2 : 2.5),
                          color: Colors.black54,
                          fontWeight: FontWeight.w700
                        ),textAlign: TextAlign.center,),
                      ),
                      Divider(),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: <Widget>[
                            for(var x =0 ;x<_images.length;x++)...{
                              GestureDetector(
                                onTap: (){
                                  if(_selectedImageIndex == x){
                                    setState(() {
                                      _selectedImageIndex = null;
                                    });
                                  }else{
                                    setState(() {
                                      _selectedImageIndex = x;
                                    });
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: _selectedImageIndex == x ? kPrimaryColor : Colors.transparent, width: 2),
                                    borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Stack(
                                    alignment: AlignmentDirectional.bottomCenter,
                                    children: <Widget>[
                                      Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: Image.file(_images[x]),
                                      ),
                                      _selectedImageIndex == x ? GestureDetector(
                                        onTap :() {
                                          crop();
                                        },
                                        child: Container(

                                          height: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: orientation == Orientation.portrait ? 5 : 10),
                                          constraints: BoxConstraints(
                                            minWidth: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: orientation == Orientation.portrait ? 10 : 20),
                                          ),
                                          margin: const EdgeInsets.only(bottom: 10,left: 20,right: 20),

                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: kPrimaryColor,
                                            border: Border.all(color: Colors.white)
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text("Crop ",style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600
                                              ),),
                                              Icon(Icons.crop,color: Colors.white,)
                                            ],
                                          )
                                        ),
                                      ) : Container()
                                    ],
                                  ),
                                ),
                              )
                            },
                            GestureDetector(
                              onTap: (){
                                chooseFromGallery();
                              },
                              child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Icon(Icons.add_photo_alternate,size: 55,color: Colors.grey,)
                              ),
                            )
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        width: double.infinity,
                        height: _images.length > 0 ? Percentage().calculate(num: scrh, percent: 10) : 0,
                        duration: Duration(milliseconds: 600),
                        child: MyWidgets().button(
                          pressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            await uploadImages(_images.length).whenComplete(() {
                              setState(()=> _isLoading = false);
                              myProductListener.updateImage(productId: widget.data['id'], images: _newImageDetails);
                              Navigator.pushReplacement(context, PageTransition(child: HomePage(reFetch: true,showAd: false,), type: PageTransitionType.downToUp));
                              print("GOING TO Store page");
                              Navigator.push(context, PageTransition(child: MyStorePage(),type: PageTransitionType.downToUp));
                            });
                          },
                          child: Text("Upload",style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: scrw > 700 ? scrw/35 : scrw/25
                          ),)
                        ),
                      )
                    ],
                  )
                );
              }
            ),
          ),
          _isLoading ? MyWidgets().loader() : Container()
        ],
      ),
    );
  }
}
