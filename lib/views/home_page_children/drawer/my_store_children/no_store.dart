import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/interrupts.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/distancer.dart';
import 'package:ekaon/services/keyboard_listener.dart';
import 'package:ekaon/services/location_picker.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/store.dart';
import 'package:ekaon/views/home_page.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_utils/keyboard_listener.dart';
import 'package:page_transition/page_transition.dart';

class IDontHaveAStore extends StatefulWidget {
  @override
  _IDontHaveAStoreState createState() => _IDontHaveAStoreState();
}

class _IDontHaveAStoreState extends State<IDontHaveAStore> with WidgetsBindingObserver{
  bool _isLoading = false;
  bool _isKeyboardActive = false;
  TextEditingController storeName = new TextEditingController();
  TextEditingController storeAddress = new TextEditingController();
  TextEditingController deliveryCharge = new TextEditingController();
  TextEditingController sdt = new TextEditingController();
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  String openTime;
  String closeTime;
  Store store = new Store();
  int _radioValue = 0;
  int _freeRadio = 0;
  int _openStore = 0;
  double _overlap = 0;
  String _base64Image;
  String filename;
  String ext;

  GlobalKey _tooltipKey = new GlobalKey();
  freeDeliverChange(int val) {
    setState(()=> _freeRadio = val);
    if(val == 1){
      setState(() {
        deliveryCharge.clear();
      });
    }else{
      setState(() {
        deliveryCharge.text = "1.00";
      });
    }
  }
  deliverOfferChange(int val) {
    setState(()=> _radioValue = val);
    if(val == 0){
      setState(() {
        _freeRadio = 0;
        deliveryCharge.clear();
      });
    }else{
      setState(() {
        deliveryCharge.text = "1.00";
      });
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  void didChangeMetrics() {
    final renderObject = _key.currentContext.findRenderObject();
    final renderBox = renderObject as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final widgetRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      renderBox.size.width,
      renderBox.size.height,
    );
    final keyboardTopPixels = window.physicalSize.height - window.viewInsets.bottom;
    final keyboardTopPoints = keyboardTopPixels / window.devicePixelRatio/(_isKeyboardActive && Platform.isAndroid ? 2 : 1);
    final overlap = widgetRect.bottom - keyboardTopPoints;
    if (overlap >= 0) {
      setState(() {
        _overlap = overlap;
      });
    }
    print(window.viewInsets.bottom.toString());
    print("Overlap : " + _overlap.toString());
  }
  scrollListener(){
    _createScroller.addListener(() {
      print(_createScroller.offset);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollListener();
    KeyboardVisibility.onChange.listen((event) {
      if(this.mounted){
        setState(() {
          _isKeyboardActive = event;
        });
        if(Platform.isAndroid && event){
          didChangeMetrics();
        }else{
          print("RELEASE");
          setState(() {
            _overlap = 0;
          });
        }
      }
    });
  }

  void get fromCamera async {
    await ImagePicker.platform.pickImage(source: ImageSource.camera).then((value) {
      if(value != null) {
        setState(() {
          _base64Image = base64.encode(new File(value.path).readAsBytesSync());
          filename = value.path.toString().split('/')[value.path.toString().split('/').length-1];
          ext = filename.split('.')[1];
          filename = filename.split('.')[0];
        });
      }
    });
  }
  void get fromGallery async {
    await ImagePicker.platform.pickImage(source: ImageSource.gallery).then((value) {
      if(value != null) {
        setState(() {
          _base64Image = base64.encode(new File(value.path).readAsBytesSync());
          filename = value.path.toString().split('/')[value.path.toString().split('/').length-1];
          ext = filename.split('.')[1];
          filename = filename.split('.')[0];
        });
        print("EXT : $ext");
        print("FNAME : $filename");
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            key: _key,
              backgroundColor: Colors.grey[100],
              appBar: AppBar(
                centerTitle: true,
                title: Image.asset("assets/images/logo.png",width: 60,),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: Container(
                width: double.infinity,
                height: scrh - (Platform.isAndroid ? _overlap : 0),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: Text("Create your store ",style: TextStyle(
                          fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 5 : 6.5),
                          color: Colors.black54
                      ),textAlign: TextAlign.center,),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    RichText(
                      text: TextSpan(
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3.5 : 4.5),
                              color: Colors.black
                          ),
                          text: "Store name ",
                          children: <TextSpan>[
                            TextSpan(
                                text: " *",
                                style: TextStyle(
                                    color: Colors.red
                                )
                            )
                          ]
                      ),
                    ),
                    Container(
                      child: TextField(
                        controller: storeName,
                        cursorColor: kPrimaryColor,
                        maxLines: 1,
                        decoration: InputDecoration(
                            hintText: "Example store",
                            suffixIcon: IconButton(
                              onPressed: ()=> setState(()=> storeName.text = ""),
                              icon: Icon(Icons.clear_all,color: storeName.text.isNotEmpty ? kPrimaryColor : Colors.grey,),
                            )
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      child: RichText(
                        text: TextSpan(
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3.5 : 4.5),
                                color: Colors.black
                            ),
                            text: "Address ",
                            children: <TextSpan>[
                              TextSpan(
                                  text: " *",
                                  style: TextStyle(
                                      color: Colors.red
                                  )
                              )
                            ]
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Icon(Icons.location_on),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(storeAddress.text.isNotEmpty ? storeAddress.text : "Unspecified"),
                          ),
                          GestureDetector(
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              try
                              {
                                LocationResult dd = await locationPicker.show(context);
                                if(dd != null){
                                  setState(() {
                                    chosenLocation = dd;
                                  });
                                  if(dd.address == null){
                                    var newAdress = await distancer.geoTranslate(isFull: true, longitude: dd.latLng.longitude, latitude: dd.latLng.latitude);
                                    setState(() {
                                      storeAddress.text = newAdress;
                                    });
                                  }else{
                                    setState(() {
                                      storeAddress.text = dd.address;
                                    });
                                  }
                                }
                              }catch(e)
                              {
                                print(e);
                                Fluttertoast.showToast(msg: "Unable to use location picker, enable location permission");
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(storeAddress.text.isNotEmpty ? "Edit" : "Add",style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontStyle: FontStyle.italic
                              ),),
                            ),
                          )
                        ],
                      ),
                    ),
                    if(storeAddress.text.isNotEmpty)...{
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: double.infinity,
                        child: Text("Note : address above is generated by google map",style: TextStyle(
                            color: Colors.black54,
                            fontStyle: FontStyle.italic
                        ),),
                      )
                    },
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Text("Offers delivery ?",style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3.5 : 4.5),
                          color: Colors.black
                      ),),
                    ),
                    Row(
                      children: [
                        new Radio(
                          value: 0,
                          activeColor: kPrimaryColor,
                          groupValue: _radioValue,
                          onChanged: deliverOfferChange,
                        ),
                        new Text(
                          'No',
                          style: new TextStyle(fontSize: 16.0),
                        ),
                        new Radio(
                          value: 1,
                          activeColor: kPrimaryColor,
                          groupValue: _radioValue,
                          onChanged: deliverOfferChange,
                        ),
                        new Text(
                          'Yes',
                          style: new TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[200],
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[300],
                                offset: Offset(3,3),
                                blurRadius: 2
                            )
                          ]
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      height: _radioValue == 1 ? Percentage().calculate(num: scrh, percent: _freeRadio == 0 ? 26 : 13) : 0,
                      child: Column(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Container(
                                  width: double.infinity,
                                  child: Text("Free delivery ?",style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                      fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3 : 4)
                                  ),)
                              )
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                                child: _radioValue == 1 ? Row(
                                  children: [
                                    new Radio(
                                      value: 0,
                                      activeColor: kPrimaryColor,
                                      groupValue: _freeRadio,
                                      onChanged: freeDeliverChange,
                                    ),
                                    new Text(
                                      'No',
                                      style: new TextStyle(fontSize: 16.0),
                                    ),
                                    new Radio(
                                      value: 1,
                                      activeColor: kPrimaryColor,
                                      groupValue: _freeRadio,
                                      onChanged: freeDeliverChange,
                                    ),
                                    new Text(
                                      'Yes',
                                      style: new TextStyle(fontSize: 16.0),
                                    ),
                                  ],
                                ) : Container()
                            ),
                          ),
                          _freeRadio == 0 && _radioValue == 1 ? Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: FittedBox(
                                child: Text("Delivery charge per kilometer",style: TextStyle(
                                    color: Colors.black54
                                ),),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ) : Container(),
                          _freeRadio == 0 && _radioValue == 1 ? Expanded(
                              flex: 5,
                              child: TextField(
                                cursorColor: kPrimaryColor,
                                controller: deliveryCharge,
                                maxLines: 1,
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                    hintText: "0.00",
                                    prefixIcon: RichText(
                                      text: TextSpan(
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 2.5 : 3.5),
                                              color: Colors.black
                                          ),
                                          text: "Php ",
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: " * ",
                                                style: TextStyle(
                                                    color: Colors.red
                                                )
                                            )
                                          ]
                                      ),
                                    ),
                                    prefixIconConstraints: BoxConstraints(
                                        minWidth: 0,
                                        minHeight: 0
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: (){
                                        setState(() {
                                          deliveryCharge.text = '';
                                        });
                                      },
                                      icon: Icon(Icons.clear_all,color: deliveryCharge.text.isNotEmpty ? kPrimaryColor : Colors.grey,),
                                    )
                                ),
                              )
                          ) : Container()
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: Text("Display Photo",style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3.5 : 4.5),
                                  color: Colors.black
                              ),),
                            ),
                          ),
                          PopupMenuButton(
                            icon: Icon(Icons.upload_outlined,color: Colors.blue,),
                            tooltip: "Upload photo",
                            itemBuilder: (context) => <PopupMenuItem>[
                              new PopupMenuItem(
                                value: 0,
                                child: Text("Gallery"),
                              ),
                              new PopupMenuItem(
                                value: 1,
                                child: Text("Camera"),
                              )
                            ],
                            onSelected: (val) {
                              print(val);
                              if(val == 0){
                                this.fromGallery;
                              }else{
                                this.fromCamera;
                              }
                            },
                            offset: Offset(0,100),
                          )
                        ],
                      )
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      height: Percentage().calculate(num: scrh, percent: 30),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(7),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: _base64Image == null ? AssetImage('assets/images/default_store.png') : MemoryImage(base64Decode(_base64Image))
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[300],
                            blurRadius: 3,
                            offset: Offset(1,3)
                          )
                        ]
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: storeName.text.isEmpty || storeAddress.text.isEmpty || (_radioValue == 1 && _freeRadio == 0 && deliveryCharge.text.isEmpty) ? Colors.grey :kPrimaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[400],
                            offset: Offset(3,3),
                            blurRadius: 2
                          )
                        ],
                        borderRadius: BorderRadius.circular(7)
                      ),
                      child: FlatButton(
                        onPressed: storeName.text.isEmpty || storeAddress.text.isEmpty || (_radioValue == 1 && _freeRadio == 0 && deliveryCharge.text.isEmpty) ? null : (){
                          Map body = {
                            "name" : storeName.text,
                            "address" : storeAddress.text,
                            "latitude" : chosenLocation.latLng.latitude.toString(),
                            "longitude" : chosenLocation.latLng.longitude.toString(),
                            "delivery_charge_per_km" : deliveryCharge.text.isEmpty ? "0" : deliveryCharge.text,
                          };
                          if(_base64Image != null)
                          {
                            setState(() {
                              body['picture'] = "data:image/$ext;base64,$_base64Image";
                              body['filename'] = filename;
                            });
                          }
                          print(body);
                          setState(() {
                            _isLoading = true;
                          });
                          store.create(body).then((value) {
                            if(value != null){
                              try{
                                setState(() {
                                  storeDetails['data'].add(value['data']);
                                  user_details.has_store = 1;
                                });
                                Navigator.push(_key.currentContext, PageTransition(child: HomePage(showAd: false,)));
                                print("GOING TO STORE PAGE");
                                Navigator.push(_key.currentContext, PageTransition(child: MyStorePage(),type: PageTransitionType.downToUp));
                              }catch(e){
                                print(e);
                              }
                            }
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7)
                        ),
                        child: Center(
                          child: Text("Submit",style: TextStyle(
                            color: Colors.white,
                            fontSize: 16
                          ),),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
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
  LocationResult chosenLocation;
  ScrollController _createScroller = new ScrollController();

  popUpTextField({Orientation orientation}) {
    return showGeneralDialog(
//        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) -   1.0;
          return Transform(
            alignment: AlignmentDirectional.topCenter,
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: GestureDetector(
              onTap: (){
                FocusScope.of(context).unfocus();
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                alignment: AlignmentDirectional.topCenter,
                child: Container(
                  width: double.infinity,
                  height: Percentage().calculate(num: orientation == Orientation.portrait ? scrh : scrw, percent: 50),
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: SafeArea(
                      child: ListView(
                        controller: _createScroller,
                        padding: EdgeInsets.only(top: 10),
                        children: <Widget>[
                          MyWidgets().customTextField(label: "Store name *",color: Colors.black54, controller: storeName),
                          const SizedBox(
                            height: 20,
                          ),
                          MyWidgets().customTextField(label: "Address *",color: Colors.black54,type: TextInputType.multiline, controller: storeAddress, onTap: () async {
                            FocusScope.of(context).unfocus();
                            try
                            {
                              if(storeAddress.text.isEmpty)
                              {
                                LocationResult dd = await locationPicker.show(context);
                                if(dd != null){
                                  setState(() {
                                    chosenLocation = dd;
                                  });
                                  if(dd.address == null){
                                    var newAdress = await distancer.geoTranslate(isFull: true, longitude: dd.latLng.longitude, latitude: dd.latLng.latitude);
                                    setState(() {
                                      storeAddress.text = newAdress;
                                    });
                                  }else{
                                    setState(() {
                                      storeAddress.text = dd.address;
                                    });
                                  }
                                }
                              }
                            }catch(e)
                            {
                              print(e);
                              Fluttertoast.showToast(msg: "Unable to use location picker, enable location permission");
                            }
                          }),
                          const SizedBox(
                            height: 20,
                          ),
                          MyWidgets().customTextField(label: "Delivery charge", controller: deliveryCharge, color: Colors.black54, type: TextInputType.number),
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            width: scrw,
                            child: Text(
                              "If you leave this blank it means you deliver freely everywhere",
                              style: TextStyle(color: Colors.black45),
                            ),
                          ),
                          SizedBox(
                            height: scrh/30,
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: scrh/40),
                            width: scrw,
                            height: scrh > 700 ? scrh/15 : scrh/12,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child: RaisedButton(
                                      color: kPrimaryColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5)
                                      ),
                                      onPressed: (){
                                        Navigator.of(context).pop(null);
                                        storeName.clear();
                                        storeAddress.clear();
                                        deliveryCharge.clear();
                                      },
                                      child: Center(
                                        child: Text("Cancel",style: TextStyle(
                                            color: Colors.white,
                                            fontSize: scrw > 700 ? scrw/35 : scrw/25
                                        ),),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: scrw/50,
                                ),
                                //unchecked popup textfield
//                                Expanded(
//                                  child: Container(
//                                    child: RaisedButton(
//                                      color: Colors.grey[900],
//                                      shape: RoundedRectangleBorder(
//                                          borderRadius: BorderRadius.circular(5)
//                                      ),
//                                      onPressed: (){
//                                        FocusScope.of(context).unfocus();
//
//                                        if (storeName.text.isNotEmpty &&
//                                            storeAddress.text.isNotEmpty) {
//                                          setState(() {
//                                            _isLoading = true;
//                                          });
//                                          Navigator.of(context).pop(null);
//                                          if (deliveryCharge.text.isEmpty) {
//                                            print("FREE");
//                                            store.create(storeName.text, storeAddress.text,chosenLocation).then((value) {
//                                              if(value != null){
//                                                try{
//                                                  setState(() {
//                                                    storeDetails['data'].add(value['data']);
//                                                    userDetails['has_store'] = 1;
//                                                  });
//                                                  Navigator.push(_key.currentContext, PageTransition(child: HomePage()));
//                                                  print("GOING TO STORE PAGE");
//                                                  Navigator.push(_key.currentContext, PageTransition(child: MyStorePage(),type: PageTransitionType.downToUp));
//                                                }catch(e){
//                                                  print(e);
//                                                }
////                                                print(_storeDetails);
//                                              }
//                                            }).whenComplete(() {
//                                              setState(() => _isLoading = false);
//                                            });
//                                          } else {
//                                            store.create(storeName.text, storeAddress.text, chosenLocation, deliveryCharge.text).then((value) {
//                                              if(value != null){
//                                                try{
//                                                  setState(() {
//                                                    storeDetails['data'].add(value['data']);
//                                                    userDetails['has_store'] = 1;
//                                                  });
//                                                  Navigator.push(_key.currentContext, PageTransition(child: HomePage()));
//                                                  print("GOING TO STORE PAGE");
//                                                  Navigator.push(_key.currentContext, PageTransition(child: MyStorePage(),type: PageTransitionType.downToUp));
//                                                }catch(e){
//                                                  print(e);
//                                                }
//                                              }
//                                            }).whenComplete(() {
//                                              setState(() => _isLoading = false);
//                                            });
//                                          }
//                                        } else {
//                                          Fluttertoast.showToast(
//                                              msg:
//                                              "Do not leave important field blank");
//                                        }
//                                      },
//                                      child: Center(
//                                        child: Text("Submit",style: TextStyle(
//                                            color: Colors.white,
//                                            fontSize: scrw > 700 ? scrw/35 : scrw/25
//                                        ),),
//                                      ),
//                                    ),
//                                  ),
//                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
  }
}

