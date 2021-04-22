import 'package:ekaon/global/constant.dart';
import 'package:ekaon/views/home_page_children/drawer/rated_children/rated_products.dart';
import 'package:ekaon/views/home_page_children/drawer/rated_children/rated_stores.dart';
import 'package:flutter/material.dart';

class RatedPage extends StatefulWidget {
  @override
  _RatedPageState createState() => _RatedPageState();
}

class _RatedPageState extends State<RatedPage> with SingleTickerProviderStateMixin {
  TabController _tabControl;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabControl = new TabController(length: 2, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.black54
        ),
        elevation: 0,
        title:  Image.asset("assets/images/logo.png",width: 60,),
        bottom: TabBar(
          controller: _tabControl,

          labelColor: Colors.black,
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w400
          ),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black54
          ),
          unselectedLabelColor: Colors.grey[500],
          indicatorColor: Colors.black54,
          tabs: <Widget>[
            Tab(
              text: "Store",

            ),
            Tab(
              text: "Product",
            )
          ],
        ),
      ),
      body: Container(
        child: TabBarView(
          controller: _tabControl,
          children: <Widget>[
            RatedStore(),
            RatedProducts()
          ],
        ),
      ),
    );
  }
}
