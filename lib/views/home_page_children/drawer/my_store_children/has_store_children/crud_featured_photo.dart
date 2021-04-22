import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/store.dart';
import 'package:ekaon/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

class CudFeaturedPhoto extends StatefulWidget {

  @override
  _CudFeaturedPhotoState createState() => _CudFeaturedPhotoState();
}

class _CudFeaturedPhotoState extends State<CudFeaturedPhoto> {
  List _featuredPhotos;
  List serverDelete = [];
  bool _hasError = false;
  int _chosenPhotoId;
  bool _isLoading = false;
  int getLastPosition() {
    int pos = 1;
    if(_featuredPhotos.length > 0)
    {
      pos = _featuredPhotos[_featuredPhotos.length -1]["position"] + 1;
    }
    return pos;
  }
  int getId() {
    int temp = 0;
    if(_featuredPhotos.length > 0){
      List dd = _featuredPhotos;
      dd.sort((a,b){
        int aId = int.parse(a['id'].toString());
        int bId = int.parse(b['id'].toString());
        return aId.compareTo(bId);
      });
      print("sorted : $dd");
      if(dd[0]['id'] > 0){
        setState(() {
          temp = -1;
        });
      }else{
        setState(() {
          temp = dd[0]['id'] - 1;
        });
      }

    }else{
      setState(() {
        temp = -1;
      });
    }
    print("TEMP ID : $temp");

    return temp;
  }
  cropImage() async {
    int toCropIndex = _featuredPhotos.indexOf(_featuredPhotos.where((element) => element['id'] == _chosenPhotoId).toList()[0]);
    print(toCropIndex);

    await ImageCropper.cropImage(sourcePath: _featuredPhotos[toCropIndex]['image_url'].path).then((value) {
      if(value != null){
        setState(() {
          _featuredPhotos[toCropIndex]['image_url'] = value;
        });
      }
    });
  }
  _chooseFromGallery() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((value) {
      if(value != null){
        setState(() {
          _featuredPhotos.add({
            "id" : getId(),
            "store_id" : myStoreDetails['id'],
            "image_url" : value,
            "position" : getLastPosition(),
            "created_at" : null
          });
          _chosenPhotoId = getId();
        });
      }
    });
  }
  get() async {
    setState(() {
      _hasError = false;
    });
    await Store().getFeaturedPhotos(myStoreDetails['id']).then((value) {
      if(value != null){
        setState(() {
          _featuredPhotos = value;
        });
      }else{
        setState(() {
          _hasError = true;
        });
      }
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get();
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
          ),
          body: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                              fontSize: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: 4)
                          ),
                          text: "Add your store's featured photo.",
                          children: [
                            TextSpan(
                              text: "\nThis will be displayed randomly",
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w400,
                                  fontSize: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: 3.5)
                              ),
                            )
                          ]
                        ),
                      )
                    ),
                    IconButton(
                      tooltip: "Featured photo's are photos displayed in your store when customers view it",
                      onPressed: (){},
                      icon: Container(
                        width: 25,
                        height: 25,
                        child: Image.asset("assets/images/question_mark.png",color: Colors.grey,),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _featuredPhotos == null ? Center(
                    child: _hasError ? Text("An error has occured") : CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    ),
                  ) : GridView.count(
//                shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: <Widget>[
                      for(var photo in _featuredPhotos)...{
                        GestureDetector(
                          onTap: (){
                            print(photo['id']);
                            if(_chosenPhotoId == photo['id']){
                              setState(() {
                                _chosenPhotoId = null;
                              });
                            }else{
                              setState(() {
                                _chosenPhotoId = photo['id'];
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                              border: Border.all(color: _chosenPhotoId == photo['id'] ? kPrimaryColor : Colors.transparent),
                              image: DecorationImage(
                                image: photo['id'] <= 0 ? FileImage(photo['image_url']) : NetworkImage("https://ekaon.checkmy.dev${photo['image_url']}")
                              )
                            ),
                            padding: const EdgeInsets.all(10),
                            alignment: AlignmentDirectional.bottomCenter,
                            child: _chosenPhotoId == photo['id'] ? Container(
                              width: double.infinity,
                              height: 40,
                              child: Row(
                                children: <Widget>[
                                  _chosenPhotoId <= 0 ? Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[900],
                                          borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: FlatButton(
                                        onPressed: (){
                                          this.cropImage();
                                        },
                                        padding: const EdgeInsets.all(0),
                                        child: Center(
                                          child: Icon(Icons.crop,color: Colors.white,),
                                        )
                                      ),
                                    ),
                                  ) : Container(),
                                  photo['id'] <= 0 ? const SizedBox(
                                    width: 10,
                                  ) : Container(),
                                  _featuredPhotos.length > 1 ? Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: kPrimaryColor,
                                        borderRadius: BorderRadius.circular(5)
                                      ),
                                      child: FlatButton(
                                        onPressed: (){
                                          setState(() {
                                            if(photo['id'] > 0){
                                              setState(() {
                                                serverDelete.add(photo['id']);
                                              });
                                            }
                                            _featuredPhotos.removeAt(_featuredPhotos.indexOf(photo));
                                          });
                                        },
                                        padding: const EdgeInsets.all(0),
                                        child: Center(
                                          child: Icon(Icons.delete_outline,color: Colors.white,),
                                        ),
                                      ),
                                    ),
                                  ) : Container()
                                ],
                              ),
                            ) : Container()
                          ),
                        )
                      },
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: FlatButton(
                          onPressed: (){
                            _chooseFromGallery();
                          },
                          padding: const EdgeInsets.all(0),
                          child: Container(
                            width: double.infinity,

                            child: Center(
                              child: Icon(Icons.add,size: Percentage().calculate(num: MediaQuery.of(context).size.width, percent: 20),color: Colors.white,),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: FlatButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await this.initiateSubmit().whenComplete(() => setState(()=>_isLoading = false));
                    Navigator.of(context).pop(null);
                  },
                  child: Center(
                    child: Text("Submit",style: TextStyle(
                      color: Colors.white
                    ),),
                  ),
                ),
              )
            ],
          ),
        ),
        _isLoading ? MyWidgets().loader() : Container()
      ],
    );
  }
  List getNewlyAdded() {
    List nData = _featuredPhotos.where((element) => element['id'] <= 0).toList();
    return nData;
  }
  Future sendNewlyAdded() async {
    for(var x in getNewlyAdded()){
      var name = x['image_url'].path.toString().split('/')[x['image_url'].path.toString().split('/').length - 1].split('.')[0];
      var ext = x['image_url'].path.toString().split('/')[x['image_url'].path.toString().split('/').length - 1].split('.')[1];
      String b64 = base64.encode(x['image_url'].readAsBytesSync());
      await Store().addFeaturedPhoto(b64, name, ext, myStoreDetails['id'], x['position']);
    }
  }
  Future removeFromServer() async {
    for(var x in serverDelete){
      await Store().removeFeaturedPhoto(x['id']);
    }
  }
  Future initiateSubmit() async {
    if(getNewlyAdded().length > 0)
    {
      await sendNewlyAdded();
    }
    if(serverDelete.length > 0)
    {
      print("delete from server");
      await removeFromServer();
    }
  }
}
