import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/services/my_product_listener.dart';
import 'package:ekaon/services/slidable_service.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/add_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AddCombinationPage extends StatefulWidget {
  final List combinations;
  final BuildContext context;
  AddCombinationPage({Key key, @required this.combinations, @required this.context}) : super(key : key);
  @override
  _AddCombinationPageState createState() => _AddCombinationPageState();
}

class _AddCombinationPageState extends State<AddCombinationPage> {
  SlidableController _slidableController = new SlidableController();
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  List _selectedCombinations;
  bool checkIfExists(int productId){
    for(var products in _selectedCombinations){
      if(productId == products['id']){
        return true;
      }
    }
    return false;
  }
  modifyQuantity(bool increase, id){
    for(var x=0;x<_selectedCombinations.length;x++){
      if(_selectedCombinations[x]['id'] == id){
        if(increase){
          setState(() {
            _selectedCombinations[x]['quantity'] += 1;
          });
        }else{
          if(_selectedCombinations[x]['quantity'] > 1){
            setState(() {
              _selectedCombinations[x]['quantity'] -= 1;
            });
          }
        }
        break;
      }
    }
  }
  modifyDefVar(parent_id, product_id, Map sub_var_data){
//    int index = _selectedCombinations.indexOf();
    print(product_id);
    for(var x=0;x<_selectedCombinations.length;x++){
      if(_selectedCombinations[x]['id'] == product_id){
        for(var y=0;y<_selectedCombinations[x]['selected_variations'].length; y++){
          if(_selectedCombinations[x]['selected_variations'][y]['variation']['id'] == parent_id){
            setState(() {
              _selectedCombinations[x]['selected_variations'][y]['default'] = sub_var_data;
            });
            break;
          }
        }
        break;
      }
    }
  }
  checkVariationExistence({int parent_id, sub_var_id, product_id}){
    for(var combo in _selectedCombinations){
      if(combo['id'] == product_id){
        if(combo['selected_variations'] != null){
          for(var selected_vars in combo['selected_variations']){
            if(selected_vars['variation']['id'] == parent_id && selected_vars['default']['id'] == sub_var_id){
              return true;
            }else{
              return false;
            }
          }
        }else{
          return false;
        }
        break;
      }
    }
    return false;
//    Map toCheck = _selectedCombinations.where((element) => element['product_id']).toList()[0];
//    if(toCheck != null){
//      if(toCheck['selected_variations'] != null){
//        for(var selected_variation in  toCheck['selected_variations']){
//          if(selected_variation['variation']['id'] == parent_id){
//            return true;
//          }
//        }
//        return false;
//      }
//      return false;
//    }
//    return false;
  }
  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      _selectedCombinations = widget.combinations;
    });
    print(_selectedCombinations);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black
          ),
          actions: [
            IconButton(icon: Icon(Icons.check), onPressed: (){
              Navigator.of(context).pop(null);
              AddProduct().updateCombination(widget.context, _selectedCombinations);
            })
          ],
          title: Text("Add Combination",style: TextStyle(
            color: Colors.black
          ),),
        ),
        body: StreamBuilder<List>(
          stream: myProductListener.$stream,
          builder: (context, _) {
            if(_.hasData){
              List data = _.data.where((element) => element['combinations'] == null || element['combinations']['details'].length == 0).toList();
              if(data != null && data.length > 0)
              {
                return Container(
                  width: double.infinity,
                  height: scrh,

                  child: Column(
                    children: [
                      if(_selectedCombinations.length > 0)...{
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          child: Text("Tapping the item will remove it from selected combination",style: TextStyle(
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
                              for(var item in _selectedCombinations)...{
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      _selectedCombinations.removeWhere((element) => element["id"] == item['id']);
                                    });
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                      margin : const EdgeInsets.only(left: 10),
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
                                        child: Text("${StringFormatter(string: item['name']).titlize()}",style: TextStyle(
                                            color: Colors.black54
                                        ),),
                                      )
                                  ),
                                )
                              }
                            ],
                          ),
                        ),
                      },
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                          child: ListView.separated(
                            separatorBuilder: (context, _) => SizedBox(
                              height: 10,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            itemCount: data.length,
                            itemBuilder: (context, index) => Slidable(
                              controller: _slidableController,
                              key: Key(data[index]['id'].toString()),
                              actionPane: SlidableService().getActionPane(index),
                              actions: [
                                IconSlideAction(
                                  iconWidget: Icon(checkIfExists(data[index]['id']) ? Icons.clear : Icons.check,color: Colors.white,),
                                  color: checkIfExists(data[index]['id']) ? Colors.red : Colors.green,
                                  onTap: (){
                                    print(data[index]);
                                    if(checkIfExists(data[index]['id'])){
                                      setState(() {
                                        _selectedCombinations.removeWhere((element) => element['id'] == data[index]['id']);
                                      });
                                    }else{
                                      Map val = data[index];
                                      val['quantity'] = 1;

                                      if(data[index]['variations'] != null && data[index]['variations'].length > 0){
                                        List d = [];
                                        for(var dd in data[index]['variations']){

                                          d.add({
                                            "variation" : dd['variation'],
                                            "default" : dd['variation']['details'].where((e)=> e['id'] == dd['default_variation_id']).toList()[0]
                                          });
                                        }
                                        val['selected_variations'] = d;
                                      }
                                      setState(() {
                                        _selectedCombinations.add(val);
                                      });
                                    }
                                  },
                                )
                              ],
                              child: AnimatedContainer(
                                  duration: Duration(milliseconds: 400),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.grey[100],
//                                    boxShadow: [
//                                      BoxShadow(
//                                          color: Colors.grey[300],
//                                          offset: Offset(3,3),
//                                          blurRadius: 2
//                                      )
//                                    ],
//                                    borderRadius: BorderRadius.circular(5)
                                  ),
                                  height: (this.checkIfExists(data[index]['id']) ? 130 + double.parse((data[index]['variations'] != null && data[index]['variations'].length > 0 ? data[index]['variations'].length * 80 : 0).toString()) : 80),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        child: Row(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(right: 10),
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius: BorderRadius.circular(1000),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.grey[400],
                                                        offset: Offset(3,3),
                                                      blurRadius: 3
                                                    )
                                                  ],
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: data[index]['images'].length == 0 ? AssetImage("assets/images/no-image-available.png") : NetworkImage("https://ekaon.checkmy.dev/${data[index]['images'][0]['url']}")
                                                )
                                              ),
                                            ),
                                            Expanded(
                                                child: Container(
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        child: Text("${StringFormatter(string: data[index]['name']).titlize()}",
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Container(
                                                        width: double.infinity,
                                                        child: Text("${StringFormatter(string: data[index]['description']).titlize()}",
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                            color: Colors.grey[700]
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                            ),
                                            Text("Php ${double.parse(data[index]['price'].toString()).toStringAsFixed(2)}",style: TextStyle(
                                              color: Colors.grey[700]
                                            ),)
                                          ],
                                        ),
                                      ),
                                      this.checkIfExists(data[index]['id']) ? Container(
                                        margin: const EdgeInsets.symmetric(vertical: 10),
                                        height: 30,

                                        child: Row(
                                          children: [
                                            Container(
                                              width: 30,
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                  color: kPrimaryColor,
                                                  borderRadius: BorderRadius.horizontal(left: Radius.circular(7))
                                              ),
                                              child: FlatButton(
                                                padding: const EdgeInsets.all(0),
                                                onPressed: (){
                                                  modifyQuantity(false, data[index]['id']);
                                                },
                                                child: Center(
                                                  child: Icon(Icons.remove,color: Colors.white,size: 15,),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                              color: kPrimaryColor,
                                              height: double.infinity,
                                              alignment: Alignment.center,
                                              child: Text(data[index]['quantity'].toString(),style: TextStyle(
                                                color: Colors.white
                                              ),),
                                            ),
                                            Container(
                                              width: 30,
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                  color: kPrimaryColor,
                                                  borderRadius: BorderRadius.horizontal(right: Radius.circular(7))
                                              ),
                                              child: FlatButton(
                                                padding: const EdgeInsets.all(0),
                                                onPressed: (){
                                                  modifyQuantity(true, data[index]['id']);
                                                },
                                                child: Center(
                                                  child: Icon(Icons.add,color: Colors.white,size: 15,),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ) : Container(),
                                      if(checkIfExists(data[index]['id']))...{
                                        for(var variation in data[index]['variations'])...{
                                          Expanded(
                                            child: Container(
                                              width: double.infinity,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    margin: const EdgeInsets.only(bottom: 10),
                                                    child: Text(variation['variation']['name'],style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                    ),),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      color: Colors.grey[100],
                                                      child: ListView(
                                                        scrollDirection: Axis.horizontal,
                                                        children: [
                                                          for(var subs in variation['variation']['details'])...{
                                                            Container(
//                                                              padding: const EdgeInsets.all(10),
                                                              margin: const EdgeInsets.only(right: 10),
                                                              decoration: BoxDecoration(
                                                                color: checkVariationExistence(parent_id: variation['variation']['id'],sub_var_id: subs['id'], product_id: data[index]['id']) ? kPrimaryColor : Colors.grey[300].withOpacity(0.4)
                                                              ),
                                                              child: FlatButton(
                                                                onPressed: (){
                                                                  modifyDefVar(variation['variation']['id'],data[index]['id'], subs);
                                                                },
                                                                padding: const EdgeInsets.all(0),
                                                                child: Center(
                                                                  child: Text("${subs['name']}",style: TextStyle(
                                                                    color: checkVariationExistence(parent_id: variation['variation']['id'],sub_var_id: subs['id'], product_id: data[index]['id']) ? Colors.white : Colors.black54
                                                                  ),),
                                                                ),
                                                              ),
                                                            )
                                                          }
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            color: Colors.grey,
                                          )
                                        }
                                      }
                                    ],
                                  )
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
            }
            return Container(
              child: Center(
                child: Text("No recorded product"),
              ),
            );
          },
        )
      ),
    );
  }
}
