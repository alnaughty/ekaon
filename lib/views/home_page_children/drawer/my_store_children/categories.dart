import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/category.dart';
import 'package:ekaon/services/chosen_category_to_add.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/category_children/add_category.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/add_product.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/edit_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:page_transition/page_transition.dart';

class CategoriesPage extends StatefulWidget {
//  final int storeId;
  final BuildContext parentContext;
  bool fromEdit = false;
  CategoriesPage({Key key,@required this.parentContext, this.fromEdit}) : super(key : key);
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  bool _isLoading = false;
  List _displayData;
  List<int> _catIds = [];
  List<String> _catNames =[];
  bool _isKeyboardActive = false;
  TextEditingController _search = new TextEditingController();
  _getCategories() async {
    var dd = await Categories().get();
    if(dd != null){
      setState(() {
        categories = dd;
        _displayData = categories;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(this.mounted){
      KeyboardVisibility.onChange.listen((event) {
        setState(() {
          _isKeyboardActive = event;
        });
      });
    }
    if(categories == null || categories.length == 0){
      _getCategories();
    }else{
      setState(() {
        _displayData = categories;
      });
    }
    if(chosenCatsIds != null){
      setState(() {
        _catIds = chosenCatsIds;
      });
    }
    if(chosenCatsNames != null)
      {
        setState(() {
          _catNames = chosenCatsNames;
        });
      }
  }
  List merged(){
    List d = [];
    for(var x =0;x<_catIds.length;x++){
      setState(() {
        d.add({
          "name" : "${_catNames[x]}",
          "id" : _catIds[x]
        });
      });
    }
    return d;
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Stack(
        children: <Widget>[
          Scaffold(
            backgroundColor: Colors.grey[100],
            resizeToAvoidBottomPadding: Platform.isIOS,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(
                color: Colors.black
              ),
              title: Image.asset("assets/images/logo.png", width: 60,),
              centerTitle: true,
              actions: <Widget>[
                IconButton(
                  onPressed: (){
                    setState(() {
                      chosenCatsNames = _catNames;
                      chosenCatsIds = _catIds;
                    });
                    Navigator.of(context).pop(null);
                    chosenCat.updateAll(merged());
//                    AddProduct().updateCategory(context,_catNames, _catIds);
                  },
                  icon: Icon(Icons.done),
                )
              ],
            ),
            body: Container(
              width: double.infinity,
              height: Platform.isAndroid ? MediaQuery.of(context).size.height- (_isKeyboardActive ? Percentage().calculate(num: MediaQuery.of(context).size.height,percent: MediaQuery.of(context).size.height > 700 ? 53 : 55) : 0) : MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: _displayData != null  ? Column(
                children: <Widget>[
                  _catNames.length > 0 ? Container(
                    width: double.infinity,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          child: Text("Tapping the name will remove this from your chosen category",style: TextStyle(
                            color: Colors.black54
                          ),),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.infinity,
                          height:35,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              for(var x in _catNames)...{
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      _catIds.removeAt(_catNames.indexOf(x));
                                      _catNames.remove(x);
                                    });
                                    print(_catIds);

                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                    margin : const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300],width: 2),
                                        borderRadius: BorderRadius.circular(1000),
                                      color: Colors.grey[200],
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey[400],
                                          offset: Offset(3,3),
                                          blurRadius: 2
                                        )
                                      ]
                                    ),
                                    child: Center(
                                      child: Text("$x",style: TextStyle(
                                          color: Colors.black54
                                      ),),
                                    )
                                  ),
                                )
                              }
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                  ) : Container(),
                  Container(
                    width: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: MyWidgets().searchField(label: "Search", controller: _search, onChange: (text){
                            setState(() {
                              _displayData = categories.where((element) => element['name'].toString().toLowerCase().contains(_search.text.toLowerCase())).toList();
                            });
                          }, onClear: (){
                            _search.clear();
                            setState(() {
                              _displayData = categories;
                            });
                          }),
                        ),
                        _displayData.length == 0 ? IconButton(
                          padding: EdgeInsets.all(0),
                          icon: Icon(Icons.add_circle,size: 30,color: kPrimaryColor,),
                          onPressed: (){
                            FocusScope.of(context).unfocus();
                            Navigator.push(context, PageTransition(child: AddCategory(_search.text, _catIds, _catNames), type: PageTransitionType.leftToRightWithFade));
//                            setState(() {
//                              _isLoading = true;
//                            });
//                            _addNewCat().whenComplete(() => setState(() => _isLoading = false));
                          },
                        ) : Container()
                      ],
                    )
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: _displayData.length > 0 ? ListView.separated(
                      itemCount: _displayData.length,
                      separatorBuilder: (context, _)=> Container(
                        width: double.infinity,
                        color: Colors.black54,
                        height: 1,
                      ),
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: (){
                          if(!_catIds.contains(_displayData[index]['id'])){
                            setState(() {
                              _catNames.add(_displayData[index]['name']);
                              _catIds.add(_displayData[index]['id']);
                            });
                            print(_catIds);
                            if(widget.fromEdit){
                              Navigator.of(context).pop(null);
                              EditProduct().appendCategory(widget.parentContext, _displayData[index]);
                            }
                          }
                        },
                        child: Container(
                          width: double.infinity,
//                      margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
//                            border: Border.symmetric(vertical: BorderSide(color: Colors.black54))
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey[400],
                                      blurRadius: 2,
                                      offset: Offset(3,3)
                                    )
                                  ],
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: _displayData[index]['image_url'] == null ? AssetImage("assets/images/no-image-available.png") : NetworkImage("https://ekaon.checkmy.dev${_displayData[index]['image_url']}")
                                  ),
                                  borderRadius: BorderRadius.circular(1000)
                                ),
                                margin: const EdgeInsets.only(right: 10),
                              ),
                              Expanded(
                                child: Text("${_displayData[index]['name']}"),
                              )
                            ],
                          ),
                        ),
                      ),
                    ) :  Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: "\" ${_search.text} \" not Found",
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 25
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: "\n if you press add button you will create this as a new category.",
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 17
                                  )
                                )
                              ]
                            ),
                          ),
                    ),
                  )
                ],
              )  : Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),),
              ),
            ),
          ),
          _isLoading ? MyWidgets().loader() : Container()
        ],
      ),
    );
  }
}
