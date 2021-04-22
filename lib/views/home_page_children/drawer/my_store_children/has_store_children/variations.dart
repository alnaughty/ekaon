import 'package:ekaon/global/constant.dart';
import 'package:ekaon/services/slidable_service.dart';
import 'package:ekaon/services/store_product_variations.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/add_product.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/variation_create.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:page_transition/page_transition.dart';

class VariationPage extends StatefulWidget {
  final List variations;
  final BuildContext context;
  VariationPage({Key key,this.variations, @required this.context}) : super(key : key);
  appendVariation(BuildContext context, Map data){
    context.findAncestorStateOfType<_VariationPageState>().appendVariation(data);
  }
  @override
  _VariationPageState createState() => _VariationPageState();
}

class _VariationPageState extends State<VariationPage> {
  SlidableController _slidableController = new SlidableController();
  appendVariation(Map data) {
    setState(() {
      _selectedVariations.add(data);
    });
  }
  bool checkifExist(int id){
    for(var dd in _selectedVariations){
      if(dd['id'] == id){
        return true;
      }
    }
    return false;
  }
  List _selectedVariations = [];
  GlobalKey<ScaffoldState> _key = new GlobalKey();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.variations != null){
      setState(() {
        _selectedVariations = widget.variations;
      });
    }
    if(productVariationListener.current == null || productVariationListener.current.length == 0){
      productVariationListener.fetchFromServer();
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Variation",style: TextStyle(
            color: Colors.black
        ),),
        iconTheme: IconThemeData(
            color: Colors.black
        ),
        actions: [
         _selectedVariations.length > 0 ? IconButton(
              icon: Icon(Icons.check),
              onPressed: (){
                Navigator.of(context).pop(null);
                AddProduct().updateVariation(widget.context, _selectedVariations);
              }
          ) : Container()
        ],
      ),
      body: StreamBuilder<List>(
        stream: productVariationListener.stream$,
        builder: (context, _) => _.hasData ? Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              if(_selectedVariations.length > 0)...{
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  child: Text("Selected variations :",style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600
                  ),),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  height: 40,
                  child: ListView.builder(
                    itemCount: _selectedVariations.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[400].withOpacity(0.2),
                        borderRadius: BorderRadius.circular(1000),
                        border: Border.all(color: Colors.grey[600])
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                      child: Text("${_selectedVariations[index]['name']}"),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              },
              for(var data in _.data)...{
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  child: Slidable(
                    key: Key(data['id'].toString()),
                    controller: _slidableController,
                    actionPane: SlidableService().getActionPane(_.data.indexOf(data)),
                    secondaryActions: [
                      IconSlideAction(
                        iconWidget: Icon(Icons.delete,color: Colors.white,),
                        color: kPrimaryColor,
                        onTap: (){},
                      ),
                      IconSlideAction(
                        iconWidget: Icon(Icons.edit,color: Colors.white,),
                        color: Colors.grey[900],
                        onTap: (){},
                      )
                    ],
                    actions: widget.variations != null ? [
                      IconSlideAction(
                        iconWidget: Text(checkifExist(data['id']) ? "Remove" : "Use",style: TextStyle(
                          color: Colors.white
                        ),),
                        color: checkifExist(data['id']) ? Colors.deepOrange : Colors.green,
                        onTap: (){
                          if(checkifExist(data['id'])){
                            setState(() {
                              _selectedVariations.removeWhere((element) => element['id'] == data['id']);
                            });
                          }else{
                            setState(() {
                              _selectedVariations.add(data);
                            });
                          }
                        },
                      )
                    ] : [],
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: double.infinity,
                            child: Text("${data['name']}",style: TextStyle(
                              fontWeight: FontWeight.w600
                            ),),
                          ),
                          Container(
                            width: double.infinity,
                            height: 20,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) => Text("${data['details'][index]['name']}",style: TextStyle(

                                ),),
                                separatorBuilder: (context, _) => Text(", "),
                                itemCount: data['details'].length
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                )
              },
              const SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                    color: kPrimaryColor,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kPrimaryColor,
                      kPrimaryColor.withOpacity(0.7)
                    ]
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[400],
                      blurRadius: 3,
                      offset: Offset(3,3)
                    )
                  ]
                ),
                child: FlatButton(
                  onPressed: (){
                    Navigator.push(context, PageTransition(child: VariationCreatePage(), type: PageTransitionType.leftToRight));
                  },
                  child: Center(
                    child: Text("Create new variation",style: TextStyle(
                      color: Colors.white,
                      fontSize: 16
                    ),),
                  ),
                ),
              )
            ],
          ),
        ) : Container(
          child: Center(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),),
          ),
        ),
      ),
    );
  }
}
