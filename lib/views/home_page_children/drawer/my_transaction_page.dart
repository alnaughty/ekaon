import 'package:ekaon/global/constant.dart';
import 'package:ekaon/services/cart.dart';
import 'package:ekaon/services/distancer.dart';
import 'package:ekaon/services/order_listener.dart';
import 'package:ekaon/views/home_page_children/drawer/transaction_children/delivery.dart';
import 'package:ekaon/views/home_page_children/drawer/transaction_children/pickup.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';


class MyTransactionPage extends StatefulWidget {
  @override
  _MyTransactionPageState createState() => _MyTransactionPageState();
}

class _MyTransactionPageState extends State<MyTransactionPage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _tabIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Image.asset("assets/images/logo.png", width: 60,),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          onTap: (i){
            setState(() {
              _tabIndex = i;
              _tabController.index = i;
            });
          },
          indicatorColor: kPrimaryColor,
          tabs: <Widget>[
            Tab(
              icon: Container(
                width: 25,
                height: 25,
                child: Image.asset( "assets/images/delivery_icon.png", color: 0 == _tabIndex ? kPrimaryColor : Colors.grey[400],),
              ),
            ),
            Tab(
              icon: Container(
                width: 25,
                height: 25,
                child: Image.asset("assets/images/pickup.png", color: 1 == _tabIndex ? kPrimaryColor : Colors.grey[400],),
              ),
            )
          ],
        ),
      ),
      body: Container(
        child: TabBarView(
            controller: _tabController,
            children: [
              DeliveryTransaction(),
              PickupTransaction()
            ])
      ),
    );
  }
}
