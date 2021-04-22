import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {
  final List data;
  final int type;
  ReviewPage({Key key, @required this.data, @required this.type}) : super(key :key);
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  List ratings = [];
  Map _selected;
  String _selectedRating = "All";
  getRatings() async {
    ratings.add({
      "name" : "All",
      "rates" : widget.data
    });
    ratings.add({
      "name" : "1",
      "rates" : getRate(1)
    });
    ratings.add({
      "name" : "2",
      "rates" : getRate(2)
    });
    ratings.add({
      "name" : "3",
      "rates" : getRate(3)
    });
    ratings.add({
      "name" : "4",
      "rates" : getRate(4)
    });
    ratings.add({
      "name" : "5",
      "rates" : getRate(5)
    });
    setState(() {
      _selected = ratings[0];
    });
  }
  List getRate(int rate){
    return widget.data.where((element) => element['rate'] == rate).toList();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("Rates : ${widget.data}");
    if(widget.data.length > 0){
      getRatings();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: Platform.isIOS,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("${widget.type == 0 ? "Store" : widget.type == 1 ?  "Product" : "User"} reviews & rate",style: TextStyle(
          color: kPrimaryColor
        ),),
        centerTitle: true,
      ),
      body: Container(
        child: widget.data.length > 0 ? Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: scrh > 700 ? 12  : 15,),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: <Widget>[
                  for(var x in ratings)...{
                    GestureDetector(
                      onTap: () {
                        if(_selectedRating == x['name']){
                          setState(() {
                            _selectedRating = "All";
                            _selected = ratings[0];
                          });
                        }else{
                          setState(() {
                            _selectedRating = x['name'];
                            _selected = x;
                          });
                        }
                      },
                      child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                          width: Percentage().calculate(num: scrw, percent: 30),
                          height: Percentage().calculate(num: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: scrh > 700 ? 12  : 15,), percent: 40),
                          decoration: BoxDecoration(
                              color: _selectedRating == x['name'] ? kPrimaryColor : Colors.grey[300],
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Container(
                            width: double.infinity,
                            child: x['name'] == "All" ? Center(child: Text("${x['name']}",style: TextStyle(
                                color: _selectedRating == x['name'] ? Colors.white : Colors.black54
                            ),)) : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[

                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      for(var n = 0;n < int.parse(x['name']);n++)...{
                                        Icon(Icons.star,color: Colors.orange,size: 15,)
                                      }
                                    ],
                                  ),
                                ),
                                Text("(${x['rates'].length >= 1000 ? "${double.parse((x['rates'].length / 1000).toString()).toStringAsFixed(2)}k" : "${x['rates'].length}"})",style: TextStyle(
                                    color: _selectedRating == x['name'] ? Colors.white : Colors.black54
                                ),),
                              ],
                            ),
                          )
                      ),
                    )
                  }
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: _selected['rates'].length > 0 ? ListView.builder(
                  itemCount: _selected['rates'].length,
                  itemBuilder: (context, index) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: Percentage().calculate(num: scrw,percent: 15),
                          height: Percentage().calculate(num: scrw,percent: 15),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(1000),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(3,3),
                                color: Colors.grey[400],
                                blurRadius: 2
                              )
                            ],
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: getRater(_selected['rates'][index])
                            )
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: double.infinity,
                                  child: Text("${getRaterName(_selected['rates'][index])}",style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold
                                  ),),
                                ),

                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    children: <Widget>[
                                      for(var zz =0;zz<5;zz++)...{
                                        Icon(Icons.star,color: _selected['rates'][index]['rate'] > zz ? Colors.orange : Colors.grey,size: 17,)
                                      }
                                    ],
                                  )
                                ),
                                Container(
                                    width: double.infinity,
                                    child: Text("${getMessage(_selected['rates'][index])}")
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ) : Center(
                  child: Text("No rating"),
                ),
              ),
            )
          ],
        ) : Center(
          child: Text("Store has no ratings nor reviews yet"),
        ),
      ),
    );
  }
  ImageProvider getRater(Map data) {
    var theUrl = "https://ekaon.checkmy.dev";
    if(widget.type == 0){
      //Store Rating
      if(data['user_review']['profile_picture'] == null){
        return AssetImage("assets/images/no-image-available.png");
      }else{
        return NetworkImage("$theUrl${data['user_review']['profile_picture']}");
      }
    }else if(widget.type == 1){
      //Product Rating
      if(data['user']['profile_picture'] == null){
        return AssetImage("assets/images/no-image-available.png");
      }else{
        return NetworkImage("$theUrl${data['user']['profile_picture']}");
      }
    }else{
      //User rating

    }
  }
  String getRaterName(Map data){
    if(widget.type == 0){
      //Store Rating
      return "${StringFormatter(string: data['user_review']['first_name']).titlize()} ${StringFormatter(string: data['user_review']['last_name']).titlize()}";
    }else if(widget.type == 1){
      //Product Rating
      return "${StringFormatter(string: data['user']['first_name']).titlize()} ${StringFormatter(string: data['user']['last_name']).titlize()}";
    }else{
      //User rating

    }
  }
  String getMessage(Map data){
    if(widget.type == 0){
      if(data['message'] == null){
        return "";
      }else{
        return "${data['message']}";
      }
    }else if(widget.type == 1){
      if(data['comment'] == null){
        return "";
      }else{
        return "${data['comment']}";
      }
    }else{
      //User rating
    }
  }
}
