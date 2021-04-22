import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/interrupts.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/home_page_children/compose_message.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/orders_children/order_details.dart';
import 'package:ekaon/views/home_page_children/drawer/transaction_children/service.dart';
import 'package:ekaon/views/map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:geocoder/model.dart';
import 'package:page_transition/page_transition.dart';

class OrderBox extends StatefulWidget {

  final List<IconSlideAction> actions;
  final Map data;
  final List<Widget> buttons;
  OrderBox(this.buttons,{this.actions, this.data});

  @override
  _OrderBoxState createState() => _OrderBoxState();
}

class _OrderBoxState extends State<OrderBox> {
  SlidableController slidableController;
  Animation<double> _rotationAnimation;
  Color _fabColor = Colors.blue;
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
  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {
      _rotationAnimation = slideAnimation;
    });
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {
      _fabColor = isOpen ? Colors.green : Colors.blue;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Slidable(
        key: Key(widget.data['name']),
        controller: slidableController,
        direction: Axis.horizontal,
        child: Container(
          height: 90,
          width: double.infinity,
          color: Colors.white,
          child: FlatButton(
            onPressed: (){
              Navigator.push(context, PageTransition(child: OrderDetailPage(widget.data,buttons: widget.buttons,), type: PageTransitionType.leftToRightWithFade));
            },
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(1000),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          alignment: AlignmentDirectional.center,
                          image: widget.data['orderer']['profile_picture'] == null ? AssetImage("assets/images/no-image-available.png") : NetworkImage('https://ekaon.checkmy.dev${widget.data['orderer']['profile_picture']}')
                      )
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child:  Text("Order${widget.data['id'].toString().padLeft(5,'0')}",style: TextStyle(
                                  color: kPrimaryColor,
                                fontWeight: FontWeight.w700,
                              ),),
                            ),
                            Text("₱${double.parse(widget.data['total'].toString()).toStringAsFixed(2)}",style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w700,
                            ),)
//                            FutureBuilder(
//                              future: Trans(orderer: Coordinates(widget.data['latitude'], widget.data['longitude']), store: Coordinates(widget.data['store']['latitude'], widget.data['store']['longitude'])).getTotal(widget.data),
//                              builder: (context, result) => result.hasData ? Text("₱${double.parse(result.data.toString()).toStringAsFixed(2)}",style: TextStyle(
//                                color: Colors.grey,
//                                fontWeight: FontWeight.w700,
//                              ),) : Container(),
//                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: Text("${widget.data['address']}",maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(
                            color: Colors.black,
//                              decoration: TextDecoration.underline,
                            fontStyle: FontStyle.italic
                        ),),
                      )
                    ],
                  ),
                )
              ],
            )
          ),
        ),
        secondaryActions: widget.actions,
        actionPane: _getActionPane(widget.data['id'])
    );
  }
}
