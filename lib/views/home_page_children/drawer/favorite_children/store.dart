import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/views/home_page_children/not_navbar/store_details.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class FavoriteStore extends StatefulWidget {
  @override
  _FavoriteStoreState createState() => _FavoriteStoreState();
}

class _FavoriteStoreState extends State<FavoriteStore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: favoriteStore.length > 0 ? ListView.builder(
          itemCount: favoriteStore.length,
          itemBuilder: (context,index) => Card(
            child: RaisedButton(
              onPressed: ()=>Navigator.push(context, PageTransition(child: StoreDetailsPage(data: favoriteStore[index]))),
              color: Colors.transparent,
              elevation: 0,
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
                      image: favoriteStore[index]['picture'] == null ? AssetImage("assets/images/default_store.png") : NetworkImage("https://ekaon.checkmy.dev${favoriteStore[index]['picture']}")
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300],
                        offset: Offset(3,3)
                      )
                    ]
                  ),
                ),
                title: Text("${favoriteStore[index]['name'][0].toString().toUpperCase() + favoriteStore[index]['name'].toString().substring(1)}"),
                subtitle: Text("${favoriteStore[index]['address']}"),
              ),
            )
          ),
        ) : Center(
          child: Text("You don't have a favorite store yet."),
        ),
      ),
    );
  }
}
