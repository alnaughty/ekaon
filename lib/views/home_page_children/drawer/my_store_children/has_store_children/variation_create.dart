import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/store_product_variations.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VariationCreatePage extends StatefulWidget {
  @override
  _VariationCreatePageState createState() => _VariationCreatePageState();
}

class _VariationCreatePageState extends State<VariationCreatePage> {
  TextEditingController name = new TextEditingController();
  ScrollController _listViewController = new ScrollController();
  bool _isLoading = false;
  bool _isKeyboardActive = false;
  List<Widget> sub_vars = [];
  List sub_var_data = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    KeyboardVisibility.onChange.listen((event) {
      setState(() {
        _isKeyboardActive = event;
      });
    });
    setState(() {
      sub_vars.add(sub_var_widget());
    });
  }
  String get names {
    List data = sub_var_data.where((element) => element['name'] != null && element['price'] != null).toList();
    List n = [];
    for(var name in data){
      n.add(name['name']);
    }
    return n.join(',');
  }
  String get prices {
    List data = sub_var_data.where((element) => element['name'] != null && element['price'] != null).toList();
    List p = [];
    for(var d in data){
      p.add(d['price']);
    }
    return p.join(',');
  }
  bool checkIfExist(int id){
    for(var subs in sub_var_data){
      if(subs['id'] == id && subs['name'] != null && subs['price'] != null){
        return true;
      }
    }
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.black
              ),
              title: Text("Create variation", style: TextStyle(
                color: Colors.black
              ),),
              actions: [
                sub_var_data.where((element) => element['name'] != null && element['price'] != null).toList().length > 1 && name.text.isNotEmpty? IconButton(
                    icon: Icon(Icons.check), onPressed: (){
                      setState(() {
                        _isLoading = true;
                      });
                      print("NAMES : $names");
                      print("Prices : $prices");
                      Map payload = {
                        "name" : StringFormatter(string: name.text).titlize(),
                        "product_id" : "0",
                        "store_id" : "${myStoreDetails['id']}",
                        "variation_names" : names,
                        "variation_prices" : prices
                      };
                      productVariationListener.create(payload).whenComplete(() {
                        setState(()=> _isLoading = false);
                        Navigator.of(context).pop(null);
                      });
                }
                ) : Container()
              ],
            ),
            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                controller: _listViewController,
                children: [
                  if(sub_var_data.where((element) => element['name'] != null && element['price'] != null).toList().length > 0)...{
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Text("Saved sub variations :",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600
                        ),),
                    ),
                    Container(
                      width: double.infinity,
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: sub_var_data.where((element) => element['name'] != null && element['price'] != null).toList().length,
                        itemBuilder: (context, index) {
                          List list_data = sub_var_data.where((element) => element['name'] != null && element['price'] != null).toList();
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(1000),
                                border: Border.all(color: Colors.grey),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[400],
                                  blurRadius: 3,
                                  offset: Offset(3,3)
                                )
                              ]
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: "${StringFormatter(string: list_data[index]['name']).titlize()} : ",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "Php ${double.parse(list_data[index]['price']).toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400
                                    )
                                  )
                                ]
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  },
                  Container(
                    width: double.infinity,
                    child: TextField(
                      controller: name,
                      cursorColor: kPrimaryColor,
                      decoration: InputDecoration(
                        hintText: "Name"
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text("Sub Variation(s) :",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                          ),),
                        ),
                        IconButton(icon: Icon(Icons.add), onPressed: () async {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            sub_vars.add(sub_var_widget());
                          });
                          await Future.delayed(Duration(milliseconds: 400));
                          _listViewController.animateTo(_listViewController.position.maxScrollExtent, duration: Duration(milliseconds: 500), curve: Curves.fastLinearToSlowEaseIn);

                        })
                      ],
                    ),
                  ),
                  for(var sub_var in sub_vars)...{
                    sub_var,
                    const SizedBox(
                      height: 10,
                    )
                  }
                ],
              ),
            ),
          ),
          _isLoading ? MyWidgets().loader() : Container()
        ],
      ),
    );
  }
  Widget sub_var_widget() {
    TextEditingController name = new TextEditingController();
    TextEditingController price = new TextEditingController();
    int id = sub_vars.length + 1;
    setState(() {
      sub_var_data.add({
        'id' : id,
        'name' : null,
        'price' : null,
      });
    });
    print("GENERATED ID : $id");
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[400],
            blurRadius: 3,
            offset: Offset(3,3)
          )
        ]
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: TextField(
              controller: name,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                hintText: "Name"
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            child: TextField(
              controller: price,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                  hintText: "Additional price"
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            width: double.infinity,
            height: 60,
            child: Row(
              children: [
                Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(7)
                      ),
                      child: FlatButton(
                        onPressed: (){
                          print(sub_var_data);
                          print("GENERATED ID : $id");
                          int index;
                          for(var x = 0;x<sub_var_data.length;x++){
                            if(sub_var_data[x]['id'] == id)
                            {
                              index = x;
                              break;
                            }
                          }
                          setState(() {
                            sub_vars.removeAt(index);
                            sub_var_data.removeAt(index);
                          });
                          print(index);
                        },
                        child: Center(
                          child: Text("Remove",style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),),
                        ),
                      ),
                    )
                ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(7)
                        ),
                        child: FlatButton(
                          onPressed: (){
                            FocusScope.of(context).unfocus();
                            if(name.text.isNotEmpty && price.text.isNotEmpty)
                            {
                              int index;
                              for(var x = 0;x<sub_var_data.length;x++){
                                if(sub_var_data[x]['id'] == id)
                                {
                                  index = x;
                                  break;
                                }
                              }
                              setState(() {
                                name.text = StringFormatter(string: name.text).titlize();
                                sub_var_data[index] = {
                                  "id" : id,
                                  "name" : name.text,
                                  "price" : price.text
                                };
                              });
                            }else{
                              Fluttertoast.showToast(msg: "Do not leave empty fields");
                            }
                          },
                          padding: const EdgeInsets.all(0),
                          child: Center(
                            child: Text("Save",style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),),
                          ),
                        ),
                      )
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
