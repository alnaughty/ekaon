import 'dart:convert';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/services/location_picker.dart';
import 'package:ekaon/views/home_page_children/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

class MyAddress{
  BehaviorSubject<List> _address = BehaviorSubject.seeded([]);
  Stream get stream$ => _address.stream;
  List get current => _address.value;

  update({List list}){
    _address.add(list);
  }
  append({Map obj}){
    List data = current;
    data.add(obj);
    _address.add(data);
    this.addToServer(data: obj);
  }
  Future addToServer({Map data}) async {
    try{
      final respo = await http.post("$url/v1/addressAdd",headers: {
        "accept" : "application/json"
      }, body: {
        "user_id" : user_details.id.toString(),
        "address": data['address'],
        "longitude" : data['longitude'].toString(),
        "latitude" : data['latitude'].toString()
      });
      var _data = json.decode(respo.body);
      if(respo.statusCode == 200){
        Fluttertoast.showToast(msg: "${_data['message']}");
        return true;
      }
      Fluttertoast.showToast(msg: "Error ${respo.statusCode}, ${respo.reasonPhrase}");
      return false;
    }catch(e){
      Fluttertoast.showToast(msg: "An unexpected error has occurred, please try again");
      print(e);
    }
  }
  Widget show({Function useCurrentLocation, Function onClose, BuildContext context, State<StatefulWidget> myState}) => StreamBuilder(
    stream: this.stream$,
    builder: (context, snapshot) {
      if(snapshot.hasData){
        return Container(
//    margin: const EdgeInsets.only(top: 5),
          child: Column(
            children: <Widget>[
              Container(
                  width: double.infinity,
//        alignment: AlignmentDirectional.centerEnd,
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey[300]))
                  ),
                  child: Row(
                    children: <Widget>[
                      const SizedBox(width: 20,),
                      Expanded(
                        child: Text("My addresses :",style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600
                        ),),
                      ),
                      const SizedBox(width: 10,),
                      IconButton(
                        icon: Icon(Icons.close,color: Colors.grey[400],),
                        onPressed: onClose,
                      ),
                    ],
                  )
              ),
              Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if(snapshot.data.length > 0)...{
                        Expanded(
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  for(var x in snapshot.data)...{
                                    GestureDetector(
                                      onTap: (){
                                        CheckoutPage().useDelivery(context, data: x);
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(bottom: 5,left: 20,right: 20),
                                        child: ListTile(
                                          leading: Icon(Icons.my_location,color: kPrimaryColor,),
                                          title: Text("${x['address']}"),
                                          subtitle: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: RichText(
                                                  text: TextSpan(
                                                      text: "Latitude : ",
                                                      style: TextStyle(
                                                          fontSize: scrw > 700 ? 15.5 : 13.5,
                                                          color: Colors.black54
                                                      ),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: "${x['latitude']}",
                                                            style: TextStyle(
                                                                fontSize: scrw > 700 ? 14 : 10
                                                            )
                                                        )
                                                      ]
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: RichText(
                                                  text: TextSpan(
                                                      text: "Longitude : ",
                                                      style: TextStyle(
                                                          fontSize: scrw > 700 ? 15.5 : 13.5,
                                                          color: Colors.black54
                                                      ),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: "${x['longitude']}",
                                                            style: TextStyle(
                                                                fontSize: scrw > 700 ? 14 : 10
                                                            )
                                                        )
                                                      ]
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  },
                                  IconButton(
                                    icon: Icon(Icons.add_circle,color: kPrimaryColor,size: 40,),
                                    onPressed: (){
                                      locationPicker.show(context).then((LocationResult value) {
                                        if(value != null){
                                          this.append(obj: {
                                            "address" : value.address,
                                            "longitude" : value.latLng.longitude,
                                            "latitude" : value.latLng.latitude
                                          });
                                        }
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      }else...{
                        Center(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      text: "You don't have an ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w600
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: "address ",
                                            style: TextStyle(
                                                color: kPrimaryColor
                                            )
                                        ),
                                        TextSpan(
                                          text: "yet \nplease add one ",
                                        )
                                      ]
                                  ))
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle,color: kPrimaryColor,size: 40,),
                          onPressed: (){
                            locationPicker.show(context).then((LocationResult value) {
                              if(value != null){
                                this.append(obj: {
                                  "address" : value.address,
                                  "longitude" : value.latLng.longitude,
                                  "latitude" : value.latLng.latitude
                                });
                              }
                            });
                          },
                        )
                      },

                    ],
                  )
              ),
              Expanded(
                flex: 2,
                child: Container(
//                  margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                  margin: const EdgeInsets.only(left: 20,right: 20,bottom: 20),
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 171, 225, 1),
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: FlatButton(
                    onPressed: useCurrentLocation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.my_location, color: Colors.white,),
                        Text(" Use current location",style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.5
                        ),)
                      ],
                    ),
                  )
                ),
              )
            ],
          ),
        );
      }else{
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
          ),
        );
      }
    }
  );
}

MyAddress myAddress = MyAddress();