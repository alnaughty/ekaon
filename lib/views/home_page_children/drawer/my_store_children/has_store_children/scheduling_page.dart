import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/schedule_listener.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/scheduling_add.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool _hasError = false;
  bool _isLoading = false;
  Color blueColor = Color.fromRGBO(0, 171, 225, 1);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scheduleListener.getFromServer().then((value) async {
      setState(() {
        _hasError = value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.black
            ),
            title: Text('Scheduler',style: TextStyle(
              color: Colors.black
            ),),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: Container(
//            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
            child: _hasError ? Center(
              child: Text("An error occurred, please try again"),
            ) : StreamBuilder<List>(
              stream: scheduleListener.stream$,
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  return ListView(
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
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("Store Hours",style: TextStyle(
                              fontSize: Percentage().calculate(num: scrw,percent: scrw > 700 ? 3 : 3.5),
                              fontWeight: FontWeight.w700
                            ),),
                            Container(
                              child: FlatButton(
                                onPressed: ()=> Navigator.push(context, PageTransition(child: SchedulingAddPage(), type: PageTransitionType.leftToRightWithFade)),
                                child: Row(
                                  children: <Widget>[
                                    Icon(Icons.add,color: kPrimaryColor,),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text("Add",style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: Percentage().calculate(num: scrw,percent: scrw > 700 ? 3 : 3.5)
                                    ),)
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      if(snapshot.data.length > 0)...{
                        for(var sched in snapshot.data)...{
                          Container(
                            width: double.infinity,
                            color: Colors.grey[100],
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.only(left: 10,top: 10,bottom: 10,right: 20),
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: (){
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    scheduleListener.removeServer(sched['id']).whenComplete(() => setState(()=> _isLoading = false));
                                  },
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                        text: "${sched['time']}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                            fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3 : 3.4 )
                                        ),
                                        children: [
                                          TextSpan(
                                              text: "\n${sched['days']}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500
                                              )
                                          )
                                        ]
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: (){
                                    if(sched['activate'].toString() == "1"){
                                      setState(() {
                                        sched['activate'] = 0;
                                        _isLoading = true;
                                      });
                                      scheduleListener.manageStatusServer(myStoreDetails['id'], 0).whenComplete(() => setState(()=> _isLoading = false));
//                                      scheduleListener.deactivate(sched['id']);
                                    }else{
                                      setState(() {
                                        sched['activate'] = 1;
                                        _isLoading = true;
                                      });
                                      scheduleListener.manageStatusServer(sched['id'], 1).whenComplete(() => setState(()=> _isLoading = false));
//                                      scheduleListener.activate(sched['id']);
                                    }
                                  },
                                  icon: Container(
                                    width: 35,
                                    height: 35,
                                    child: Image.asset("assets/images/${sched['activate'].toString() == "1" ? "enable" : "disable"}.png",color: sched['activate'].toString() == "1" ? kPrimaryColor : Colors.grey,),
                                  ),
                                )
                              ],
                            )
                          )
                        },
                      }else...{
                        Container(
                          width: double.infinity,
                          height: 60,
                          child: Center(
                            child: Text("No schedule recorded"),
                          ),
                        )
                      },
                    ],
                  );
                }
                return Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),),
                );
              }
            ),
          ),
        ),
        _isLoading ? MyWidgets().loader() : Container()
      ],
    );
  }
}

