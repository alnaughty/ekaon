import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/discount.dart';
import 'package:ekaon/services/discount_listener.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/discount_children/add.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/ticket_clipper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class DiscountPage extends StatefulWidget {
  @override
  _DiscountPageState createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(discountListener.current.length == 0){
      Discount().get(store_id: myStoreDetails['id']).then((value) {
        if(value != null){
          discountListener.updateAll(value['data']);
        }
      });
    }
  }
  static Widget _getActionPane(int index) {
    switch (index % 4) {
      case 0:
        return SlidableBehindActionPane();
      case 1:
        return SlidableStrechActionPane();
      case 2:
        return SlidableScrollActionPane();
      case 3:
        return SlidableDrawerActionPane();
      default:
        return null;
    }
  }
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.black
            ),
            title: Text("Discounts",style: TextStyle(
              color: Colors.black
            ),),
          ),
          body: Container(
            color: Colors.grey[200],
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: StreamBuilder<List>(
              stream: discountListener.stream$,
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    children: <Widget>[
                      for(var discounts in snapshot.data)...{
                        Slidable(child: TicketWidget(
                            color: StringFormatter(string: discounts['color']).stringToColor(),
                            height: Percentage().calculate(num: scrh,percent: 15),
                            onPressed: ()  {
                              print( StringFormatter(string: discounts['color']).stringToColor());
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15), percent: 15),vertical: 10),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    width: double.infinity,
                                    height: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60),
                                    child: Column(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            alignment: AlignmentDirectional.centerStart,
                                            child: Row(
                                              children: <Widget>[
                                                int.parse(discounts['type'].toString()) == 1 ? Container() : Container(
                                                  padding: EdgeInsets.only(top: Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60), percent: 15)),
                                                  alignment: AlignmentDirectional.topStart,
                                                  child: Text("₱",style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize:Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60),percent: scrw > 700 ? 18 : 20)
                                                  )),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    child: RichText(
                                                      textAlign: TextAlign.left,
                                                      text: TextSpan(
                                                          text: "${discounts['value']}",
                                                          style: TextStyle(
                                                              color: Colors.black,
                                                              fontWeight: FontWeight.w600,
                                                              fontSize: Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60),percent: scrw > 700 ? 68 : 70)
                                                          ),
                                                          children: [
                                                            TextSpan(
                                                                text: "${int.parse(discounts['type'].toString()) == 1 ? "%" : ""} OFF",
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.w500,
                                                                    fontSize:Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60),percent: scrw > 700 ? 18 : 20)
                                                                )
                                                            )
                                                          ]
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  child: Text("${discounts['code']}",style: TextStyle(
                                                    color: Colors.white54,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 4 : 4.2)
                                                  ),),
                                                )
                                              ],
                                            )
                                          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          child: Text("Valid until ${DateFormat('MMM. dd').format(DateTime.parse(discounts['valid_until'].toString()))}",style: TextStyle(
                                              fontSize: Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60),percent: scrw > 700 ? 13 : 15)
                                          ),),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        )
                                      ],
                                    ),
                                  ),
                                  brokenLines(count: 15,height: 3.5,color: Colors.grey[200]),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      child: Container(
                                        width: double.infinity,
                                        child: Text("Min spend ₱${double.parse(discounts['on_reach'].toString()).toStringAsFixed(2)}",style: TextStyle(
                                            fontSize: Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15),percent: 60),percent: scrw > 700 ? 13 : 15)
                                        ),),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                        ),
                          actionPane: _getActionPane(discounts['id']),
                          actions: <Widget>[
                            IconSlideAction(
                              onTap: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                await Discount().remove(id: int.parse(discounts['id'].toString())).whenComplete(() => setState(()=> _isLoading = false));
                              },
                              color: kPrimaryColor,
                              iconWidget: Icon(Icons.delete,color: Colors.white,),
                            )
                          ],
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              onTap: () async {
                                Navigator.push(context, PageTransition(child: AddDiscountPage(toEdit: discounts,), type: PageTransitionType.downToUp));
                              },
                              color: Colors.grey[900],
                              iconWidget: Icon(Icons.edit,color: Colors.white,),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      },
                      TicketWidget(
                          height: Percentage().calculate(num: scrh,percent: 15),
                          onPressed: ()=>Navigator.push(context, PageTransition(child: AddDiscountPage(), type: PageTransitionType.downToUp)),
                          child: Center(
                            child: Icon(Icons.add_circle_outline,color: Colors.grey[700],size: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 15), percent: 60),),
                          )
                      )
                    ],
                  );
                }
                return Container();
              }
            )
          ),
        ),

        _isLoading ? MyWidgets().loader() : Container()
      ],
    );
  }
}

