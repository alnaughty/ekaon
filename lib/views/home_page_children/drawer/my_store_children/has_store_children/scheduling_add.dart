import 'dart:async';
import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/schedule_listener.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SchedulingAddPage extends StatefulWidget {
  @override
  _SchedulingAddPageState createState() => _SchedulingAddPageState();
}

class _SchedulingAddPageState extends State<SchedulingAddPage> {
  Color blueColor = Color.fromRGBO(0, 171, 225, 1);
  bool _checkAll=false;
  DateTime now = DateTime.now();
  TimeOfDay open;
  TimeOfDay closing;
  bool _isLoading = false;
  List days = [
    {
      "day" : "Sun",
      "active" : false
    },
    {
      "day" : "Mon",
      "active" : false
    },
    {
      "day" : "Tue",
      "active" : false
    },
    {
      "day" : "Wed",
      "active" : false
    },
    {
      "day" : "Thu",
      "active" : false
    },
    {
      "day" : "Fri",
      "active" : false
    },
    {
      "day" : "Sat",
      "active" : false
    }
  ];
  void initState() {
    super.initState();
  }
  checkIfAll() {
     setState(() {
       _checkAll = days.where((element) => element['active'] == true).toList().length == 7;
     });
  }
  manageActivate(){
    for(var day in days){
      if(_checkAll){
        setState(() {
          day['active'] = true;
        });
      }else{
        setState(() {
          day['active'] = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          resizeToAvoidBottomPadding: Platform.isIOS,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.black
            ),
            title: Text("New Schedule",style: TextStyle(
              color: Colors.black
            ),),
          ),
          body: Container(
            child: ListView(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 25),
                  color: blueColor.withOpacity(0.1),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.warning,color: Colors.amber,),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text("This is only to display your store's schedule, this is not a must, opening and closing time is still in your hands."),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Add time",style: TextStyle(
                      fontSize: Percentage().calculate(num: scrw,percent: scrw > 700 ? 3 : 3.5),
                      fontWeight: FontWeight.w700
                  ),),
                ),
                time(),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Repeat",style: TextStyle(
                      fontSize: Percentage().calculate(num: scrw,percent: scrw > 700 ? 3 : 3.5),
                      fontWeight: FontWeight.w700
                  ),),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(_checkAll ? Icons.check_box : Icons.check_box_outline_blank,),
                        onPressed: (){
                          setState(() {
                            _checkAll = !_checkAll;
                          });
                          manageActivate();
                        },
                      ),
                      Text("Select All",style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 2.8 : 3)
                      ),)
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
//                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      for(var da in days)...{
                        Container(
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                onPressed: ()=>setState((){
                                  da['active'] = !da['active'];
                                  checkIfAll();
                                }),
                                icon: Icon(da['active'] ? Icons.check_box : Icons.check_box_outline_blank),
                              ),
                              Text("${da['day']}",style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 2.8 : 3)
                              ),)
                            ],
                          ),
                        )
                      }
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  width: double.infinity,
                  height: 60,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            ),
                            onPressed: ()=>Navigator.of(context).pop(),
                            child: Center(
                              child: Text("Cancel",style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700
                              ),),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            ),
                            onPressed: (){

                              if(open != null && closing != null){
                                setState(() {
                                  _isLoading = true;
                                });
                                List data = [];
                                days.where((element) {
                                  if(element['active']){
                                    data.add(element['day']);
                                    return true;
                                  }
                                  return false;
                                }).toList();
                                String formattedTime = "${open.format(context)} - ${closing.format(context)}";
                                scheduleListener.addOrUpdateServer(data.join(','), formattedTime).whenComplete(() {
                                  setState(() => _isLoading = false);
                                  Navigator.of(context).pop();
                                });
                              }else{
                                Fluttertoast.showToast(msg: "Please add time");
                              }
                            },
                            child: Center(
                              child: Text("Save",style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700
                              ),),
                            ),
                          ),
                        ),
                      ),
                    ],
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
    );
  }
  time() =>Container(
    width: double.infinity,
    height: Percentage().calculate(num: scrh,percent: 11),
    margin: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 5,bottom: 5,right: 20),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey[300],width: 3))
            ),
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  child: Text("Open",style: TextStyle(
                    fontSize: Percentage().calculate(num: scrw,percent: scrw > 700 ? 2.9 : 3.4),
                    fontWeight: FontWeight.w600
                  ),),
                ),
                Expanded(
                  child: FlatButton(
                    onPressed: () async {
                      DateTime now = DateTime.now();
                      TimeOfDay picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(DateTime(now.year,now.month,now.day,9,00)),
                          builder: (context, child) => MediaQuery(
                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false,),
                            child: child,
                          )
                      );
                      if(picked != open && picked != null){
                        setState(() {
                          open = picked;
                        });
                      }
                    },
                    padding: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: open != null ? blueColor : Colors.grey),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            alignment: AlignmentDirectional.center,
                            child: Text("${open != null ? open.hourOfPeriod == 00 ? "12" : open.hourOfPeriod.toString().padLeft(2,'0') : "00"}",style: TextStyle(
                            color: open != null ? blueColor : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                            )),
                          ),
                        ),
                        Container(
                          height: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: Center(
                              child: Text(":",style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  color: open != null ? blueColor : Colors.grey
                              ),)
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: open != null ? blueColor : Colors.grey),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            alignment: AlignmentDirectional.center,
                            child: Text("${open != null ? open.minute.toString().padLeft(2,'0') : "00"}",style: TextStyle(
                                color: open != null ? blueColor : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 20
                            )),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          alignment: AlignmentDirectional.topStart,
                          child: Text(open == null ? "--" : "${open.format(context).split(' ')[1]}",style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17
                          ),),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            alignment: AlignmentDirectional.center,
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  child: Text("Close",style: TextStyle(
                      fontSize: Percentage().calculate(num: scrw,percent: scrw > 700 ? 2.9 : 3.4),
                      fontWeight: FontWeight.w600
                  ),),
                ),
                Expanded(
                  child: FlatButton(
                    padding: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    onPressed: () async {
                      DateTime now = DateTime.now();
                      TimeOfDay picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(DateTime(now.year,now.month,now.day,16,00)),
                          builder: (context, child) => MediaQuery(
                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false,),
                            child: child,
                          )
                      );
                      if(picked != closing && picked != null){
                        setState(() {
                          closing = picked;
                        });
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: closing != null ? blueColor : Colors.grey),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            alignment: AlignmentDirectional.center,
                            child: Text("${closing != null ? closing.hourOfPeriod == 00 ? "12" : closing.hourOfPeriod.toString().padLeft(2,'0') : "00"}",style: TextStyle(
                                color: closing != null ? blueColor : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 20
                            )),
                          ),
                        ),
                        Container(
                          height: 60,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: Center(
                              child: Text(":",style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  color: closing != null ? blueColor : Colors.grey
                              ),)
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: closing != null ? blueColor : Colors.grey),
                                borderRadius: BorderRadius.circular(5)
                            ),
                            alignment: AlignmentDirectional.center,
                            child: Text("${closing != null ? closing.minute.toString().padLeft(2,'0') : "00"}",style: TextStyle(
                                color: closing != null ? blueColor : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 20
                            )),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          alignment: AlignmentDirectional.topStart,
                          child: Text(closing == null ? "--" : "${closing.format(context).split(' ')[1]}",style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17
                          ),),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
