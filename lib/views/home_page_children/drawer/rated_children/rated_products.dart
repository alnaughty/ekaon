import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/your_rated_products_listener.dart';
import 'package:ekaon/views/home_page_children/not_navbar/store_details_children/view_product_page.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class RatedProducts extends StatefulWidget {
  @override
  _RatedProductsState createState() => _RatedProductsState();
}

class _RatedProductsState extends State<RatedProducts> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List>(
      stream: yourRatedProductsListener.stream$,
      builder: (context,result){
        if(result.hasData){
          if(result.data.length > 0){
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              itemCount: result.data.length,
              itemBuilder: (context, index) => FlatButton(
                padding: const EdgeInsets.all(0),
                onPressed: (){
                  print(result.data[index]);
                  Navigator.push(context, PageTransition(child: ProductPage(details: result.data[index]['details'], storeDetails: result.data[index]['details']['store_details']), type: PageTransitionType.leftToRightWithFade));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: Percentage().calculate(num: scrw, percent: 15),
                        height: Percentage().calculate(num: scrw, percent: 15),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(1000),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: result.data[index]['details']['images'].length == 0 ? AssetImage("assets/images/default_store.png") : NetworkImage("https://ekaon.checkmy.dev${result.data[index]['details']['images'][0]['url']}")
                            )
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
                              child: Text(result.data[index]['details']['name'].toString(),style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold
                              ),overflow: TextOverflow.ellipsis,maxLines: 2,),
                            ),
                            Container(
                                width: double.infinity,
                                child: Row(
                                  children: <Widget>[
                                    for(var x =0;x<5;x++)...{
                                      Icon(Icons.star,color: int.parse(result.data[index]['rate'].toString()) > x ? Colors.orange : Colors.grey,size: 15,)
                                    }
                                  ],
                                )
                            ),
                            Container(
                              width: double.infinity,
                              child: Text(result.data[index]['comment'].toString(),style: TextStyle(
                                color: Colors.grey,
                              ),overflow: TextOverflow.ellipsis,maxLines: 1,),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
          return Center(
            child: Text("You did not rate any products yet"),
          );
        }
        else{
          return Center(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),),
          );
        }
      },
    );
  }
}
