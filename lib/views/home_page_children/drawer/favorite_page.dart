import 'package:ekaon/global/constant.dart';
import 'package:ekaon/views/home_page_children/drawer/favorite_children/product.dart';
import 'package:ekaon/views/home_page_children/drawer/favorite_children/store.dart';
import 'package:flutter/material.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> with SingleTickerProviderStateMixin{
  TabController _tabController;
  List<Widget> _contents = [FavoriteStore(), FavoriteProduct()];
  int _currentTabIndex = 0;
  Text text({String label, int index}) {
    return Text(label, style: TextStyle(
      color: _currentTabIndex == index ? kPrimaryColor : Colors.grey[400],
    ),);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Image.asset("assets/images/logo.png", width: 60,),
        bottom: TabBar(
          onTap: (i){
            setState(() {
              _currentTabIndex = i;
            });
          },
          controller: _tabController,
          indicatorColor: kPrimaryColor,
          tabs: <Widget>[
            Tab(
              child: text(label: "Store", index: 0),
              icon: Container(
                width: 25,
                height: 25,
                child: Center(
                  child: Image.asset("assets/images/mobile_store.png", color: _currentTabIndex == 0 ? kPrimaryColor : Colors.grey[400],),
                ),
              ),
            ),
            Tab(
              child: text(label: "Food", index: 1),
              icon: Icon(Icons.fastfood,color: _currentTabIndex == 1 ? kPrimaryColor : Colors.grey[400],)
            )
          ],
        ),
      ),
      body: Container(
        color: Colors.red,
        child: TabBarView(children: _contents, controller: _tabController,),
      ),
    );
  }
}
