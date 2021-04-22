import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/interrupts.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/keyboard_listener.dart';
import 'package:ekaon/services/my_product_listener.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/products.dart';
import 'package:ekaon/services/slidable_service.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_utils/keyboard_aware/keyboard_aware.dart';
import 'package:keyboard_utils/keyboard_listener.dart';
import 'package:keyboard_utils/keyboard_utils.dart';
import 'package:page_transition/page_transition.dart';

class EditProduct extends StatefulWidget {
  final Map productData;
  EditProduct({Key key,@required this.productData}) : super(key : key);
  appendCategory(BuildContext context, Map data){
    context.findAncestorStateOfType<_EditProductState>().appendCategory(data);
  }
  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  KeyboardBloc _bloc = KeyboardBloc();
  SlidableController _slidableController = new SlidableController();
  ScrollController _scrollController = new ScrollController();
  TextEditingController _name = new TextEditingController();
  TextEditingController _description = new TextEditingController();
  TextEditingController _price = new TextEditingController();
  String pastName;
  String pastDescription;
  String pastPrice;
  bool isLoading = false;
  pickFromGallery() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((value) {
      if(value != null){
        setState(() {
          widget.productData['images'].add({
            "isNew" : true,
            "file" : value
          });
          imageIndex = widget.productData['images'].length - 1;
        });
      }
    });
  }
  pickFromCam() async {
    await ImagePicker.pickImage(source: ImageSource.camera).then((value) {
      if(value != null){
        setState(() {
          widget.productData['images'].add({
            "isNew" : true,
            "file" : "${value.path}"
          });
          imageIndex = widget.productData['images'].length - 1;
        });
      }
    });
  }
  cropImage() async {
    await ImageCropper.cropImage(sourcePath: widget.productData['images'][imageIndex]['file'].path).then((value) {
      if(value != null){
        setState(() {
          widget.productData['images'][imageIndex]['file'] = value;
        });
      }
    });
  }
  appendCategory(Map data) {
    setState(() {
      isLoading = true;
      widget.productData['categories'].add(data);
    });
    ProductAuth().addCategory(productId: int.parse(widget.productData['id'].toString()), categoryId: int.parse(data['id'].toString())).whenComplete(() => setState(()=> isLoading = false));
  }

//  List _images;
  List imagesToRemove = [];
  int imageIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc.start();
    setState(() {
      pastDescription = widget.productData['description'].toString();
      pastName = widget.productData['name'].toString();
      pastPrice = widget.productData['price'].toString();
      _description.text = widget.productData['description'].toString();
      _name.text = widget.productData['name'].toString();
      _price.text = widget.productData['price'].toString();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap :() => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _key,
        resizeToAvoidBottomPadding: Platform.isIOS,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Image.asset("assets/images/logo.png", width: 60,),
          centerTitle: true,
        ),
        body: StreamBuilder(
          stream: _bloc.stream,
          builder: (context, snapshot) {
            return Padding(
              padding:  EdgeInsets.only(
                  bottom: Platform.isAndroid ? double.parse((snapshot.hasData && snapshot.data > 0 ? snapshot.data + 60 : 0 ).toString()) : 10),
              child: Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverAppBar(
                          expandedHeight: Percentage().calculate(num: scrh,percent: 40),
                          automaticallyImplyLeading: false,
                          backgroundColor: Colors.grey[200],
                          flexibleSpace: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: widget.productData['images'].length == 0 ? Image.asset("assets/images/no-image-available.png",alignment: Alignment.center,) : widget.productData['images'][imageIndex]['isNew'] != null ? Image.file(widget.productData['images'][imageIndex]['file']) : Image.network("https://ekaon.checkmy.dev${widget.productData['images'][imageIndex]['url']}",alignment: Alignment.center,),
                          ),
                        ),
                        if(widget.productData['images'].length > 0)...{
                          SliverToBoxAdapter(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                              child: Text("Hold the image to show options",textAlign: TextAlign.center,style: TextStyle(
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w600,
                                  fontSize: Theme.of(context).textTheme.bodyText2.fontSize
                              ),),
                            ),
                          ),
                        },
                        SliverToBoxAdapter(
                          child: Container(
                            width: double.infinity,
                            height: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 13),percent: 80),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                for(var x = 0;x<widget.productData['images'].length;x++)...{
                                  GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        imageIndex = x;
                                      });
                                    },
                                    onLongPress: (){
                                      setState(() {
                                        imageIndex = x;
                                      });
                                      if(imageIndex == x && widget.productData['images'].length > 1){
                                        onLongPress(buttons: [
                                          widget.productData['images'][x]['isNew'] != null && x == imageIndex ? ListTile(
                                            title: Text("Crop"),
                                            leading: Icon(Icons.crop),
                                            onTap: (){
                                              Navigator.of(context).pop(null);
                                              cropImage();
                                            },
                                          ) : null,
                                          imageIndex == x && widget.productData['images'].length > 1 ? ListTile(
                                            title: Text("Remove"),
                                            leading: Icon(Icons.remove),
                                            onTap: (){
                                              Navigator.of(context).pop(null);
                                              if(widget.productData['images'][x]['isNew'] == null){
                                                setState(() {
                                                  imagesToRemove.add(widget.productData['images'][x]);
                                                });
                                                print(imagesToRemove);
                                              }
                                              setState(() {
                                                if(imageIndex != 0) {
                                                  imageIndex--;
                                                }
                                                widget.productData['images'].removeAt(x);
                                              });
                                            },
                                          ) : null
                                        ]);
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 20),
                                      width: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 13),percent: 80),
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          border: Border.all(color: x == imageIndex ? kPrimaryColor : Colors.transparent,width: 2),
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: widget.productData['images'].length == 0 ? AssetImage("assets/images/no-image-available.png") : widget.productData['images'][x]['isNew'] != null ? FileImage(widget.productData['images'][x]['file']) : NetworkImage("https://ekaon.checkmy.dev${widget.productData['images'][x]['url']}")
                                          )
                                      ),
                                    ),
                                  )
                                },
                                PopupMenuButton(
                                  offset: Offset(0,100),
                                  onSelected: (v){
                                    print(v);
                                    if(v == 1){
                                      this.pickFromGallery();
                                    }else{
                                      this.pickFromCam();
                                    }
                                  },
                                  itemBuilder: (context) {
                                    var list = List<PopupMenuEntry<Object>>();
                                    list.add(
                                        PopupMenuItem(
                                          child: Text("Gallery"),
                                          value: 1,
                                        )
                                    );
                                    list.add(
                                        PopupMenuItem(
                                          child: Text("Camera"),
                                          value: 2,
                                        )
                                    );
                                    return list;
                                  },
                                  child: Container(
                                    width: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 13),percent: 80),
                                    height: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 13),percent: 80),
                                    decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(7)
                                    ),
                                    margin: const EdgeInsets.only(left: 20),
                                    child: Center(
                                      child: Icon(Icons.add,color: Colors.white,size: Percentage().calculate(num: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 13),percent: 80),percent: 70),),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate([
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text("Product information :",style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                  fontSize: Theme.of(context).textTheme.headline6.fontSize - 1
                              ),),
                            ),
                            PiBox(label: "Name",controller: _name),
                            PiBox(label: "Description", controller: _description),
                            PiBox(label: "Price", controller: _price),
                            Divider(),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text("Availability :",style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                  fontSize: Theme.of(context).textTheme.headline6.fontSize - 1
                              ),),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                              width: double.infinity,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text("Available",style: TextStyle(
                                        fontSize: Theme.of(context).textTheme.subtitle1.fontSize,
                                      fontWeight: FontWeight.w600
                                    ),),
                                  ),
                                  IconButton(icon: Icon(widget.productData['isAvailable'] == 1 ? Icons.check_box_outlined : Icons.check_box_outline_blank ,color: widget.productData['isAvailable'] == 1 ? kPrimaryColor : Colors.grey,), onPressed: (){
                                    if(widget.productData['isAvailable'] == 1) {
                                      setState(() {
                                        widget.productData['isAvailable'] = 0;
                                      });
                                    }else{
                                      setState(() {
                                        widget.productData['isAvailable'] = 1;
                                      });
                                    }
                                  })
                                ],
                              ),
                            ),
                            Divider(),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text("Categories :",style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                  fontSize: Theme.of(context).textTheme.headline6.fontSize - 1
                              ),),
                            ),
                            for(var category in widget.productData['categories'])...{
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Slidable(
                                  key: Key(widget.productData['categories'].indexOf(category).toString()),
                                  controller: _slidableController,
                                  secondaryActions: [
                                    IconSlideAction(
                                      iconWidget: Icon(Icons.remove,color: Colors.white,),
                                      color: Colors.grey[900],
                                      onTap: (){
                                        Interrupts().showProductCategoryDeletion(context, category['name'], category['id'].toString(), (){
                                          Navigator.of(context).pop(null);
                                          setState(() {
                                            isLoading = true;
                                          });
                                          ProductAuth().removeCategory(productId: widget.productData['id'],categoryId: category['id']).then((value) {
                                            if(value){
                                              print("ASDAD");
                                              setState(() {
                                                int index = widget.productData['categories'].indexOf(category);
                                                widget.productData['categories'].removeAt(index);
                                              });
                                            }
                                          }).whenComplete(() => setState(()=> isLoading = false));
                                        });
                                      },
                                    )
                                  ],
                                  actionPane: SlidableService().getActionPane(widget.productData['categories'].indexOf(category)),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                    color: Colors.grey[200].withOpacity(0.8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius: BorderRadius.circular(1000),
                                              image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: category['image_url'] != null ? NetworkImage("https://ekaon.checkmy.dev${category['image_url']}") : AssetImage("assets/images/no-image-available.png")
                                              )
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text("${category['name']}",style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: Theme.of(context).textTheme.bodyText1.fontSize + 2,
                                              fontWeight: FontWeight.w600
                                          ),),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            },
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: Colors.grey[400]),
                                borderRadius: BorderRadius.circular(5)
                              ),
                              child: FlatButton(
                                onPressed: (){
                                  Navigator.push(context, PageTransition(child: CategoriesPage(parentContext: _key.currentContext, fromEdit: true,)));
                                },
                                child: Center(
                                  child: Text("Add category",style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16.5
                                  ),),
                                ),
                              ),
                            ),
                            Divider(),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              width: double.infinity,
                              height: Percentage().calculate(num: scrh, percent: 9),
                              decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              child: FlatButton(
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await save().whenComplete(() => Navigator.of(context).pop(null));
                                },
                                child: Center(
                                  child: Text("Submit",style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: Percentage().calculate(num: scrw,percent: 4.5)
                                  ),),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ]),
                        )
                      ],
                    ),
                  ),
                  isLoading ? MyWidgets().loader() : Container()
                ],
              ),
            );
          }
        )
      ),
    );
  }
  bool checkIfSame(String toCheck, type) {
    if(type == "Name"){
      if(toCheck == pastName){
        return true;
      }
      return false;
    }else if(type == "Description"){
      if(toCheck == pastDescription){
        return true;
      }
      return false;
    }else{
      if(toCheck == pastPrice){
        return true;
      }
      return false;
    }
  }
  PiBox({String label, TextEditingController controller}) {
    String textX;
    TextInputType keyType;
    if(label == "Name"){
      keyType = TextInputType.text;
//      _edit.text = pastName;
      textX = pastName;
    }else if(label == "Description"){
      keyType = TextInputType.multiline;
//      _edit.text = pastDescription;
      textX = pastDescription;
    }else{
      keyType = TextInputType.numberWithOptions(decimal: true);
//      _edit.text = pastPrice;
      textX = pastPrice;
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: double.infinity,
            child: Text("$label",style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: Theme.of(context).textTheme.subtitle1.fontSize
            ),),
          ),
          Container(
            child: TextField(
              onSubmitted: (text){
              },
              maxLines: label == "Description" ? null : 1,
              keyboardType: keyType,
              cursorColor: kPrimaryColor,
              decoration: InputDecoration(
                  hintText: "$textX",
                  suffixIcon: IconButton(
                      icon: Icon(Icons.clear_all),
                      onPressed: (){
                        controller.clear();
                      }
                  )
              ),
              controller: controller,
            ),
          )
        ],
      ),
    );
  }
  onLongPress({List<ListTile> buttons}){
    int length = buttons.where((element) => element != null).toList().length;
    print(length);
    showModalBottomSheet(
        context: _key.currentContext,
        backgroundColor: Colors.grey[100],
        builder: (context) => Container(
          height: (length + 1) * 60.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(5))
          ),
          child: Column(
            children: [
              for(var button in buttons)...{
                button != null ? button : Container()
              },
              ListTile(
                leading: Icon(Icons.close),
                title: Text('Close'),
                onTap: (){
                  Navigator.of(context).pop(null);
                },
              )
            ],
          ),
        )
    );
  }
  Future uploadNewImages() async {

    for(var x = 0; x<widget.productData['images'].length;x++ )
    {
      if(widget.productData['images'][x]['isNew'] != null){
        var name = widget.productData['images'][x]['file'].path.toString().split('/')[widget.productData['images'][x]['file'].path.toString().split('/').length - 1].split('.')[0];
        var ext = widget.productData['images'][x]['file'].path.toString().split('/')[widget.productData['images'][x]['file'].path.toString().split('/').length - 1].split('.')[1];
        var b64Image = base64.encode(widget.productData['images'][x]['file'].readAsBytesSync());
        await ProductAuth().uploadImages(image: b64Image,productId: widget.productData['id'],ext: ext,name: name).then((value) {
          if(value != null){
            setState(() {
              widget.productData['images'][x] = value;
            });
          }
        });
      }
    }
    return true;
  }

  Future save() async {
    if(imagesToRemove.length > 0){
      for(var x in imagesToRemove){
        await ProductAuth().removeImage(x['id']);
      }
    }
    if(widget.productData['images'].where((element) => element['isNew'] != null).toList().length > 0){
      await this.uploadNewImages();
    }
    myProductListener.updateImage(productId: widget.productData['id'],images: widget.productData['images']);
    await ProductAuth().update(widget.productData['id'], myProductListener.changeDetected("${_name.text}", "name", widget.productData['id']), myProductListener.changeDetected("${_description.text}", "description", widget.productData['id']), myProductListener.changeDetected("${_price.text}", "price", widget.productData['id']), widget.productData['isAvailable']);

    setState(()=>isLoading = false);
  }
}
