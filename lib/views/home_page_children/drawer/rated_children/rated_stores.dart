import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/services/my_rated_stores_listener.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/views/home_page_children/not_navbar/store_details.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class RatedStore extends StatefulWidget {
  @override
  _RatedStoreState createState() => _RatedStoreState();
}

class _RatedStoreState extends State<RatedStore> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List>(
      stream: myRatedStores.stream$,
      builder: (context,result){
        if(result.hasData){
          if(result.data.length > 0){
            return ListView.builder(
              itemCount: result.data.length,
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              itemBuilder: (context, index) => FlatButton(
                padding: const EdgeInsets.all(0),
                onPressed: (){
                  Navigator.push(context, PageTransition(child: StoreDetailsPage(data: result.data[index]['details']), type: PageTransitionType.leftToRightWithFade));
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
                            image: result.data[index]['details']['picture'] == null ? AssetImage("assets/images/default_store.png") : NetworkImage("https://ekaon.checkmy.dev${result.data[index]['details']['picture']}")
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
                                    Icon(Icons.star,color: result.data[index]['rate'] > x ? Colors.orange : Colors.grey,size: 15,)
                                  }
                                ],
                              )
                            ),
                            Container(
                              width: double.infinity,
                              child: Text(result.data[index]['message'].toString(),style: TextStyle(
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
            child: Text("You did not rate any store yet"),
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
