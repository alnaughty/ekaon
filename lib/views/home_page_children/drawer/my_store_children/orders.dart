import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/services/store.dart';
import 'package:ekaon/services/store_orders_listener.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/orders_children/delivery.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/orders_children/pickup.dart';
import 'package:flutter/material.dart';


class StoreOrders extends StatefulWidget {
  @override
  _StoreOrdersState createState() => _StoreOrdersState();
}

class _StoreOrdersState extends State<StoreOrders> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _tabIndex = 0;
  final List<Widget> _contents = [StoreDelivery(), StorePickup()];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    getOrders();
  }
  getOrders() async {
    var dd = await Store().orders(store_id: myStoreDetails['id']);
    if(dd != null){
      storeOrdersListener.updateData(dd);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        title: Text("Orders",style: TextStyle(
          color: Colors.black
        ),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 60),
          child: Container(
            width: double.infinity,
            height: 60,
            color: kPrimaryColor,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    onPressed: ()=> setState(()=> _tabIndex = 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 25,
                          height: 25,
                          child: Image.asset("assets/images/delivery_icon.png",color: _tabIndex == 0 ? Colors.white : Colors.white.withOpacity(0.7),),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text("Delivery",style: TextStyle(
                          color: _tabIndex == 0 ? Colors.white : Colors.white.withOpacity(0.7),
                          fontSize: _tabIndex == 0 ? 16 : 14.5,
                          fontWeight: FontWeight.w600
                        ),)
                      ],
                    )
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    onPressed: ()=> setState(()=> _tabIndex = 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 25,
                          height: 25,
                          child: Image.asset("assets/images/pickup.png",color: _tabIndex == 1 ? Colors.white : Colors.white.withOpacity(0.7),),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text("Pickup",style: TextStyle(
                            color: _tabIndex == 1 ? Colors.white : Colors.white.withOpacity(0.7),
                            fontSize: _tabIndex == 1 ? 16 : 14.5,
                            fontWeight: FontWeight.w600
                        ),)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        width: double.infinity,
        child: AnimatedSwitcher(duration: Duration(milliseconds: 700),child: _contents[_tabIndex],)
      )
    );
  }
}
