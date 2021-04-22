import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/services/cart.dart';
import 'package:ekaon/services/favorite.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/views/home_page_children/not_navbar/store_details.dart';
import 'package:ekaon/views/home_page_children/not_navbar/store_details_children/view_product_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';

class ListViewProduct extends StatefulWidget {
  final Map data;
  final int index;
  final int storeOwnerId;
  final Map storeDetails;
  final SlidableController controller;
  final BuildContext context;
  ListViewProduct(this.context,{Key key, @required this.data, @required this.controller,@required this.index, @required this.storeOwnerId, @required this.storeDetails}) : super(key : key);
  @override
  _ListViewProductState createState() => _ListViewProductState();
}

class _ListViewProductState extends State<ListViewProduct> {
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
  @override
  Widget build(BuildContext context) {
    return Slidable(
        key: Key(widget.data['name']),
        controller: widget.controller,
        direction: Axis.horizontal,
        child: GestureDetector(
          onTap: (){
            Navigator.push(context, PageTransition(child: ProductPage(details: widget.data,storeDetails: widget.storeDetails,)));
          },
          child: Container(
            width: double.infinity,
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    print("SHOW IMAGES");
                  },
                  child: Container(
                    width: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: MediaQuery.of(context).size.height > 700 ? 8 : 10),
                    height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: MediaQuery.of(context).size.height > 700 ? 8 : 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: widget.data['images'].length == 0 ? AssetImage("assets/images/no-image-available.png") : NetworkImage("https://ekaon.checkmy.dev/${widget.data['images'][0]['url']}")
                      )
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: Text("${widget.data['name']}",maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(
                          fontWeight: FontWeight.w600
                        ),),
                      ),
                      Container(
                        width: double.infinity,
                        child: Text("Php${double.parse(widget.data['price'].toString()).toStringAsFixed(2)}",maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(
                            fontWeight: FontWeight.w600,
                          color: Colors.grey
                        ),),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        secondaryActions: user_details != null && user_details.id != widget.storeOwnerId ? <Widget>[
          IconSlideAction(
            color: kPrimaryColor,
            iconWidget: Container(
              width: 25,
              height: 25,
              child: Image.asset("assets/images/cart.png",color: Colors.white,),
            ),
            onTap: () {
              StoreDetailsPage(data: widget.data).enableLoader(context, true);
              Map _data;
                setState(() {
                  _data = widget.data;
                  _data['quantity'] = 1;
                  _data['sub_total'] = double.parse((1 * widget.data['price']).toString());
                });
              cartAuth.addToCart(product: _data, variationIds: null).whenComplete(() => StoreDetailsPage(data: widget.data).enableLoader(context, false));
            },
          ),
          IconSlideAction(
            onTap: (){
              if(favoriteProductIds.contains(widget.data['id'])){
                updateFavorites(false);
              }else{
                updateFavorites(true);
              }
            },
            color: Colors.grey[900],
            iconWidget: Icon(favoriteProductIds.contains(widget.data['id']) ? Icons.favorite : Icons.favorite_border,color: Colors.white,),
//            onTap: () => _showSnackBar(context, 'Delete'),
          ),
        ] : [],
        actionPane: _getActionPane(widget.index)
    );
  }
  updateFavorites(bool isAdding)
  {
    Map data = widget.data;
    data['store'] = widget.storeDetails;
    if(isAdding)
    {
      setState(() {
        favoriteProductIds.add(widget.data['id']);
        favoriteProduct.add(widget.data);
      });
    }else{
      setState(() {
        favoriteProductIds.remove(widget.data['id']);
        favoriteProduct.removeWhere((element) => element['id'] == widget.data['id']);
      });
    }
    print("FAVORITE : $favoriteProduct");
    Favorite().manage(key: 'product_id', value: widget.data['id'].toString());
  }
}
