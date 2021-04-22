import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/views/home_page_children/not_navbar/store_details_children/view_product_page.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class GridViewProduct extends StatefulWidget {
  final List data;
  final Map storeDetails;
  GridViewProduct({Key key, @required this.data, @required this.storeDetails}) : super(key : key);
  @override
  _GridViewProductState createState() => _GridViewProductState();
}

class _GridViewProductState extends State<GridViewProduct> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
      shrinkWrap: true,
      childAspectRatio: 0.9,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: <Widget>[
        for(var product in widget.data)...{
          Stack(
            children: <Widget>[
              GestureDetector(
                onTap: (){
                  Navigator.push(context, PageTransition(child: ProductPage(details: product,storeDetails: widget.storeDetails,)));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: product['images'].length == 0 ? AssetImage("assets/images/no-image-available.png") : NetworkImage("https://ekaon.checkmy.dev/${product['images'][0]['url']}")
                              )
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: double.infinity,
                        child: Text("${product['name']}",style: TextStyle(
                            fontSize: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: 3),
                            fontWeight: FontWeight.w600
                        ),maxLines: 1, overflow: TextOverflow.ellipsis,),
                      ),
                      Container(
                        width: double.infinity,
                        child: Text("Php${double.parse(product['price'].toString()).toStringAsFixed(2)}",style: TextStyle(
                            color: Colors.grey,
                            fontSize: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: 2.8),
                            fontWeight: FontWeight.w600
                        ),maxLines: 2, overflow: TextOverflow.ellipsis,),
                      )
                    ],
                  ),
                ),
              ),
              product['isAvailable'] == 0 ? Container(

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[200].withOpacity(0.4),
                ),
                width: double.infinity,
                height: double.infinity,

              ) : Container()
            ],
          )
        }
      ],
    );
  }
}
