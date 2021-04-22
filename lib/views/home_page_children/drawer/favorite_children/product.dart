import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/views/home_page_children/not_navbar/store_details_children/view_product_page.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class FavoriteProduct extends StatefulWidget {
  @override
  _FavoriteProductState createState() => _FavoriteProductState();
}

class _FavoriteProductState extends State<FavoriteProduct> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    print("FAVORITE #1 : ${favoriteProduct[1]}");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: favoriteProduct.length > 0 ? ListView.builder(
          itemCount: favoriteProduct.length,
          itemBuilder: (context, index) => Card(
            child: RaisedButton(
              onPressed: ()=>Navigator.push(context, PageTransition(child: ProductPage(details: favoriteProduct[index], storeDetails: favoriteProduct[index]['store']),type: PageTransitionType.rightToLeft)),
              elevation: 0,
              color: Colors.transparent,
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(1000),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: favoriteProduct[index]['images'].length > 0 ? NetworkImage("https://ekaon.checkmy.dev${favoriteProduct[index]['images'][0]['url']}") : AssetImage("assets/images/no-image-available.png")
                    ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[300],
                            offset: Offset(3,3)
                        )
                      ]
                  ),
                ),
                title: Text("${favoriteProduct[index]['name'][0].toString().toUpperCase() + favoriteProduct[index]['name'].toString().substring(1)}"),
                subtitle: Text("${favoriteProduct[index]['description']}"),
              ),
            ),
          ),
        ) : Center(
          child: Text("You don't have a favorite product yet."),
        ),
      ),
    );
  }
}
