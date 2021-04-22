import 'dart:convert';
import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/category.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/categories.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

class AddCategory extends StatefulWidget {
  final String toAdd;
  final List oldCatNames;
  final List oldCatIds;
  AddCategory(this.toAdd, this.oldCatIds,this.oldCatNames);
  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  TextEditingController _toAdd = new TextEditingController();
  bool _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _toAdd.text = widget.toAdd;
      nIds = widget.oldCatIds;
      nNames = widget.oldCatNames;
    });
  }
  List nIds = [];
  List nNames = [];
  Future _addNewCat() async {
    var dd = await Categories().add(_toAdd.text, myStoreDetails['id'],b64);
    if(dd != null){
      setState(() {
        if(chosenCatsIds != null){
          chosenCatsIds.add(dd['id']);
        }
        if(chosenCatsNames != null){
          chosenCatsNames.add(dd['name']);
        }
//        nIds.add(dd['id']);
//        nNames.add(dd['name']);
        categories.add(dd);
//        _displayData.add(dd);
      });
      Navigator.of(context).pop(null);
      print("X");
      Navigator.of(context).pop(null);
      Navigator.push(context, PageTransition(child: CategoriesPage(parentContext: this.context), type: PageTransitionType.leftToRightWithFade));
      return true;
    }
    return false;
  }
  File _image;
  String b64;
  Future getFromGal() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((value) {
      if(value != null){
        setState(() {
          _image = value;
          b64 = base64.encode(_image.readAsBytesSync());
        });
      }
    });
  }
  Future getFromCam() async {
    await ImagePicker.pickImage(source: ImageSource.camera).then((value) {
      if(value != null){
        setState(() {
          _image = value;
          b64 = base64.encode(_image.readAsBytesSync());
        });
      }
    });
  }
  Future cropImage() async {
    await ImageCropper.cropImage(sourcePath: _image.path).then((value) {
      if(value != null){
        setState(() {
          _image = value;
          b64 = base64.encode(_image.readAsBytesSync());
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Image.asset("assets/images/logo.png", width: 60,),
              centerTitle: true,
            ),
            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _toAdd,
                    onTap: (){},
                    cursorColor: kPrimaryColor,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        labelText: "New category",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                        prefixIcon: Icon(Icons.category),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _toAdd.clear();
                          },
                          icon: Icon(Icons.clear),
                        )
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //image
                  Expanded(
                    child: _image == null ? Container(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: GestureDetector(
                              onTap: (){
                                this.getFromCam();
                              },
                              child: Container(
                                padding: EdgeInsets.all(Percentage().calculate(num: MediaQuery.of(context).size.width, percent: 15)),
                                child: FittedBox(
                                  child: Icon(Icons.camera_alt,color: Colors.grey[900],),
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 2,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: (){
                                this.getFromGal();
                              },
                              child: Container(
                                padding: EdgeInsets.all(Percentage().calculate(num: MediaQuery.of(context).size.width, percent: 15)),
                                child: FittedBox(
                                  child: Icon(Icons.photo_album,color: Colors.grey[900],),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ) : Container(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Image.file(_image),
                          ),
                          Container(
                            width: double.infinity,
                            height: 60,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: FlatButton(
                                      onPressed: (){
                                        setState(() {
                                          _image = null;
                                          b64 = null;
                                        });
                                      },
                                      child: Center(
                                        child: Icon(Icons.refresh,color: Colors.white,),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: FlatButton(
                                      onPressed: (){
                                        this.cropImage();
                                      },
                                      child: Center(
                                        child: Icon(Icons.crop,color: Colors.white,),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: FlatButton(
                      splashColor: Colors.grey[700],
                      onPressed: () async {
                        if(_toAdd.text.isEmpty || _image == null){
                          Fluttertoast.showToast(msg: "You can't leave empty data!");
                        }else{
                          setState(() {
                            _isLoading = true;
                          });
                          //upload new
                          await this._addNewCat().whenComplete(() => setState(()=> _isLoading = false));

                        }
                      },
                      child: Center(
                        child: Text("Upload",style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          _isLoading ? MyWidgets().loader() : Container()
        ],
      ),
    );
  }
}
