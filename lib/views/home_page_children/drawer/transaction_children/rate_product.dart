import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/interrupts.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/my_rated_stores_listener.dart';
import 'package:ekaon/services/products.dart';
import 'package:ekaon/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';

class RateProduct extends StatefulWidget {
  final Map data;
  final bool isProduct;
  RateProduct({Key key, @required this.data, @required this.isProduct}) : super(key : key);
  @override
  _RateProductState createState() => _RateProductState();
}

class _RateProductState extends State<RateProduct> {
  TextEditingController _comment = new TextEditingController();
  int chosenStarRate = 5;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Image.asset("assets/images/logo.png",width: 60,),
              centerTitle: true,
            ),
            body: OrientationBuilder(
              builder: (context, orientation) {
                return Container(
                  width: double.infinity,
                  height: Platform.isAndroid ? orientation == Orientation.portrait ? scrh - MediaQuery.of(context).viewInsets.bottom - 5 : scrw - MediaQuery.of(context).viewInsets.bottom - 5 : orientation == Orientation.portrait ? scrh : scrw,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: Text("Rating :",style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700
                        ),),
                      ),
                      Container(
                        width: double.infinity,
                        child: Row(
                          children: <Widget>[
                            for(var x =0;x<5;x++)...{
                              IconButton(
                                icon: Icon(Icons.star,color: x < chosenStarRate ? Colors.amber : Colors.grey,),
                                onPressed: (){
                                  if(chosenStarRate == x+1){
                                    setState(() {
                                      chosenStarRate = 0;
                                    });
                                  }else{
                                    setState(() {
                                      chosenStarRate = x+1;
                                    });
                                  }
                                  print(chosenStarRate);
                                },
                              )
                            }
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: Text("Comment :",style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700
                        ),),
                      ),
                      Container(
                        width: double.infinity,
                        child: MyWidgets().customTextField(controller: _comment,label: "",type: TextInputType.multiline,color: kPrimaryColor)
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(5)
                        ),
                        child: FlatButton(
                          onPressed: (){
                            setState(() {
                              _isLoading = true;
                            });
                            if(widget.isProduct){
                              ProductAuth().addRating(widget.data['id'], _comment.text, chosenStarRate).whenComplete(() {
                                setState(() => _isLoading = false);
                                Navigator.push(context, PageTransition(child: HomePage()));
                              });
                            }else{
                              myRatedStores.addRatingServer(widget.data['id'], chosenStarRate, _comment.text).whenComplete(() => setState(() => _isLoading = false));
                            }
                            Navigator.of(context).pop(null);
                            print("SULOD SA TRANSACTIONS PAGE");
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
