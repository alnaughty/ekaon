import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/home_page_children/compose_message.dart';
import 'package:ekaon/views/home_page_children/not_navbar/store_details_children/view_product_page.dart';
import 'package:ekaon/views/home_page_children/search_child/qr_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'not_navbar/store_details.dart';

class SearchPage extends StatefulWidget {
  final List data;
  final int type;
  final Map store_details;
  SearchPage({Key key, @required this.data, @required this.type, @required this.store_details}) : super(key : key);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List _displayData;
  TextEditingController _controller = new TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _displayData = widget.data;
    });
    print(_displayData);
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 60,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: ()=>Navigator.of(context).pop(null),
                      icon: Icon(Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,color: Colors.black54,),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          controller: _controller,
                          onTap: (){},
                          cursorColor: kPrimaryColor,
                          onChanged: (text){
                            if(widget.type == 1){
                              setState(() {
                                _displayData = getMessageList(text);
                              });
                            }else{
                              setState(() {
                                _displayData = widget.data.where((element) => element['name'].toString().toLowerCase().contains(text.toLowerCase())).toList();
                              });
                            }
                          },
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              labelText: "Search",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                              prefixIcon: Icon(Icons.search),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  _controller.clear();
                                  setState(() {
                                    _displayData = widget.data;
                                  });
                                },
                                icon: Icon(Icons.clear),
                              )
                          ),
                        ),
                      ),
                    ),
                    widget.type == 0 ? IconButton(
                      tooltip: "Search store via QR Scanner",
                      onPressed: (){
                        Navigator.push(context, PageTransition(child: QrScannerPage(),type: PageTransitionType.leftToRightWithFade));
                      },
                      icon: Container(
                        width: 25,
                        height: 25,
                        child: Image.asset("assets/images/qr_scanner.png",color: kPrimaryColor,),
                      ),
                    ) : Container()
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  child: _displayData.length == 0 ? Center(
                    child: Text("No data found"),
                  ) : ListView.builder(
                    padding: const EdgeInsets.only(top: 20),
                    itemCount: _displayData.length,
                    itemBuilder: (context, index) => FlatButton(
                      onPressed: (){
                        Navigator.of(context).pop(null);
                        if(widget.type == 0){
                          //show store
                          Navigator.push(context, PageTransition(child: StoreDetailsPage(data: _displayData[index]), type: PageTransitionType.leftToRightWithFade));
                        }else if(widget.type == 1){
                          //show convo
                          Navigator.push(context, PageTransition(child: ChatBox(storeDetails: _displayData[index]['store_details'],recipient: _displayData[index]['customer_details'], isStore: _displayData[index]['store_owner_id'] != user_details.id, storeId: _displayData[index]['store_id'], storeOwnerId: _displayData[index]['store_owner_id'])));
                        }else{
                          //show product
                          Navigator.push(context, PageTransition(child: ProductPage(details: _displayData[index], storeDetails: widget.store_details)));
                        }
                      },
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(1000),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[400],
                                blurRadius: 5,
                                offset: Offset(3,3),
                                spreadRadius: 0.5
                              )
                            ],
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: dataImage(_displayData[index]),
                            )
                          ),
                        ),
                        title: Text("${widget.type == 1 ? "${messageText(_displayData[index])}" : "${StringFormatter(string: _displayData[index]['name']).titlize()}"}",style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600
                        ),),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  String messageText(Map data){
    if(data['store_owner_id'] == user_details.id){
      //get sa customer
      return "${StringFormatter(string: data['customer_details']['first_name']).titlize()} ${StringFormatter(string: data['customer_details']['last_name']).titlize()}";
    }else{
      //get store name
      return "${StringFormatter(string: data['store_details']['name']).titlize()}";
    }
  }
  List getMessageList(text) {
    List customerMessages = [];
    List storeMessages = [];
    List tempCust = widget.data.where((element) => element['store_owner_id'] == user_details.id).toList().where((element) {
      var fullName = "${element['customer_details']['first_name']} ${element['customer_details']['larst_name']}".toLowerCase();
      return fullName.contains(text);
    }).toList();
    List tempStore = widget.data.where((element) => element['store_owner_id'] != user_details.id).toList().where((element) => element['store_details'].toString().toLowerCase().contains(text)).toList();
    var newList = new List.from(tempCust)..addAll(tempStore);
    return newList;
  }
  ImageProvider dataImage(Map data) {
    String imUrl = "https://ekaon.checkmy.dev";
    if(widget.type == 0)
    {
      if(data['picture'] == null){
        return AssetImage("assets/images/default_store.png");
      }else{
        return NetworkImage("$imUrl${data['picture']}");
      }
    }else if(widget.type == 1)
    {
      if(data['store_owner_id'] == user_details.id)
      {
        //ako an owner san store so kuhaon ko an sa customer
        if(data['customer_details']['profile_picture'] == null){
          return AssetImage("assets/images/no-image-available.png");
        }else{
          return NetworkImage("$imUrl${data['customer_details']['profile_picture']}");
        }
      }else{
        //kuhaon ko an sa kanan store
        if(data['store_details']['picture'] == null){
          return AssetImage("assets/images/default_store.png");
        }else{
          return NetworkImage("$imUrl${data['store_details']['picture']}");
        }
      }

    }else{
      if(data['images'].length > 0){
        return NetworkImage("$imUrl${data['images'][0]['url']}");
      }else{
        return AssetImage("assets/images/no-image-available.png");
      }
    }
  }
}
