import 'dart:convert';
import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/dashed_container/dashed.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/chosen_category_to_add.dart';
import 'package:ekaon/services/my_product_listener.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/products.dart';
import 'package:ekaon/services/slidable_service.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/home_page.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/add_product_image.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/categories.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/add_combination.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/variations.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

class AddProduct extends StatefulWidget {
  updateImage(BuildContext context,int index, File nImage, String nb64) {
    context.findAncestorStateOfType<_AddProductState>().updateImages(index, nImage, nb64);
  }
  updateCombination(BuildContext context, List data){
    context.findAncestorStateOfType<_AddProductState>().updateCombinations(data);
  }
  updateVariation(BuildContext context, List data){
    context.findAncestorStateOfType<_AddProductState>().updateVariations(data);
  }
//  updateCategory(BuildContext context,List<String> nCats, List<int>nCatIds){
//    _AddProductState().updateCategories(nCats, nCatIds);
//    context.findAncestorStateOfType<_AddProductState>().updateCategories(nCats, nCatIds);
//  }
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  SlidableController _slidableController = new SlidableController();
  ProductAuth _productAuth = new ProductAuth();
  List<File> _images = [];
  List<String> _base64Images = [];
  List combinations = [];
  List variations = [];
  List _newImageDetails = [];
  int _selectedImageIndex;
  bool _isMeal = false;
  TextEditingController _name = new TextEditingController();
  TextEditingController _description = new TextEditingController();
  TextEditingController _price = new TextEditingController();
  GlobalKey<ScaffoldState> _key = new GlobalKey();
  updateCombinations(List data) {
    setState(()=> combinations = data);
  }
  updateVariations(List data){
    setState(() {
      variations = data;
    });
  }
  Future uploadImages(length, productId) async {

    if(length > 0){
      var name = _images[length - 1].path.split('/')[_images[length - 1].path.split('/').length - 1].split('.')[0];
      var ext = _images[length - 1].path.split('/')[_images[length - 1].path.split('/').length - 1].split('.')[1];
      await ProductAuth().uploadImages(image: _base64Images[length - 1], productId: productId, name: name, ext: ext).then((value) {
        if(value != null){
          uploadImages(length - 1, productId);
          setState(() {
            _newImageDetails.add(value);
          });
        }else{
          uploadImages(length - 1, productId);
          Fluttertoast.showToast(msg: "An error has occurred while uploading your image");
        }
      });
    }else{
      setState(() {
        _isLoading = false;
      });
      myProductListener.updateImage(productId: productId, images: _newImageDetails);
      Navigator.pushReplacement(context, PageTransition(child: HomePage(reFetch: true,showAd: false,), type: PageTransitionType.downToUp));
      print("GOING TO Store page");
      Navigator.push(context, PageTransition(child: MyStorePage(),type: PageTransitionType.downToUp));
      return true;
    }
  }
  updateImages(int index, File image, String b64){
    setState(() {
      _images[index] = image;
      _base64Images[index] = b64;
    });
  }
  chooseFromGallery() async
  {
    var dd = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(dd != null){
      var base64Image = base64.encode(dd.readAsBytesSync());
      setState(() {
        _images.add(dd);
        _base64Images.add(base64Image);
      });
    }
  }
  cropImage() async {
    await ImageCropper.cropImage(sourcePath: _images[_selectedImageIndex].path).then((value) {
      if(value != null){
        var base64Image = base64.encode(value.readAsBytesSync());
        setState(() {
          _images[_selectedImageIndex] = value;
          _base64Images[_selectedImageIndex] = base64Image;
        });
      }
    });
  }
  chooseFromCamera() async
  {
    var dd = await ImagePicker.pickImage(source: ImageSource.camera);
    if(dd != null){
      var base64Image = base64.encode(dd.readAsBytesSync());
      setState(() {
        _images.add(dd);
        _base64Images.add(base64Image);
      });
    }
  }
  String beautifyCategories(List data){
    String finale = '';
    for(var dd in data){
      finale += "${dd['name']},";
    }
    return finale.substring(0, finale.length-1);

  }
  bool _isLoading = false;
  bool _isAvailable = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      resizeToAvoidBottomPadding: Platform.isIOS,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Add Product",style: TextStyle(
          color: Colors.black
        ),),
      ),
      body: GestureDetector(
        onTap: ()=> FocusScope.of(context).unfocus(),
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              color: Colors.grey[200],
              height: scrh,
              child: ListView(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                      text: "Product Images ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: "*",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: kPrimaryColor
                                            )
                                        )
                                      ]
                                  ),
                                ),
                              ),
//                              GestureDetector(
//                                onTap: (){
//                                  if(_selectedImageIndex != null){
//                                    print("CROP IMAGE at index : $_selectedImageIndex");
//                                    cropImage();
//                                  }
//                                },
//                                child: Row(
//                                  children: <Widget>[
//                                    Icon(Icons.crop,color: _selectedImageIndex != null ? kPrimaryColor : Colors.grey,),
//                                    const SizedBox(
//                                      width: 5,
//                                    ),
//                                    Text("Crop",style: TextStyle(
//                                        color: _selectedImageIndex != null ? kPrimaryColor : Colors.grey,
//                                        fontWeight: FontWeight.w600
//                                    ),)
//                                  ],
//                                ),
//                              )
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          height: Percentage().calculate(num: scrh,percent: 10),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              for(var x = 0; x<_images.length;x++)...{
                                GestureDetector(
                                  onLongPress: (){
                                    setState(() {
                                      _selectedImageIndex = x;
                                    });
                                    showImageDeleteOption();
                                  },
                                  child: Container(
                                    width: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 10),percent: 80),
                                    height: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 10),percent: 80),
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
//                                        border: Border.all(color: _selectedImageIndex == x ? kPrimaryColor : Colors.transparent, width: 2),
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Image.file(_images[x]),
                                  ),
                                )
                              },
                              Container(
                                width: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 10),percent: 80),
                                height: Percentage().calculate(num: Percentage().calculate(num: scrh,percent: 10),percent: 80),
                                child: DashedContainer(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: FittedBox(
                                      child: PopupMenuButton(
                                        offset: Offset(0,100),
                                        onSelected: (val) => val == 'cam' ? chooseFromCamera() : chooseFromGallery(),
                                        itemBuilder: (_) =><PopupMenuItem<String>>[
                                          new PopupMenuItem<String>(
                                              child: const Text('Camera'), value: 'cam'),
                                          new PopupMenuItem<String>(
                                              child: const Text('Gallery'), value: 'gal'),
                                        ],
                                        child: Icon(Icons.add,color: kPrimaryColor,),
                                      ),
                                    ),
                                  ),
                                  dashColor: kPrimaryColor,
                                  borderRadius: 5.0,
                                  dashedLength: 10.0,
                                  blankLength: 3.0,
                                  strokeWidth: 2.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //End of images
                  const SizedBox(
                    height: 10,
                  ),
                  //Product name
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          child: RichText(
                            text: TextSpan(
                                text: "Product Name ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: "*",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: kPrimaryColor
                                      )
                                  )
                                ]
                            ),
                          ),
                        ),
                        Container(
                          child: TextField(
                            controller: _name,
                            cursorColor: kPrimaryColor,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter Product Name"
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  //Product description
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          child: RichText(
                            text: TextSpan(
                                text: "Product Description ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: "*",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: kPrimaryColor
                                      )
                                  )
                                ]
                            ),
                          ),
                        ),
                        Container(
                          child: TextField(
                            controller: _description,
                            cursorColor: kPrimaryColor,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter Product Description"
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  //Price
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: RichText(
                            text: TextSpan(
                                text: "Set Price ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: "*",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: kPrimaryColor
                                      )
                                  )
                                ]
                            ),
                          ),
                        ),
                        Container(
                          width: Percentage().calculate(num: scrw,percent: 20),
                          child: TextField(
                            controller: _price,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: "Price",
                              border: InputBorder.none
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  //category
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            child: RichText(
                              text: TextSpan(
                                text: "Category",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: " *",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: kPrimaryColor
                                    )
                                  )
                                ]
                              ),
                            )
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, PageTransition(child: CategoriesPage(), type: PageTransitionType.leftToRightWithFade));
                          },
                          child: Container(
                              child: StreamBuilder(
                                stream: chosenCat.stream$,
                                builder: (context, result) => result.hasData ? Container(
                                  width: Percentage().calculate(num: scrw, percent: 30),
                                  child: Text(result.data.length == 0 ? "Select categories" : "${beautifyCategories(result.data)}",style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),overflow: TextOverflow.ellipsis,maxLines: 1,textAlign: TextAlign.right,),
                                ) : Container(),
                              )
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  //meal
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Text("Meal",style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),)
                        ),
                        Spacer(),
                        Container(
                            child: Text("${_isMeal ? "Yes" : "No"}",style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),)
                        ),
                        PopupMenuButton(
                          offset: Offset(0,100),
                          onSelected: (val) {
                            setState(()=> _isMeal = val == "Yes");
                            if(!_isMeal){
                              setState(() {
                                combinations.clear();
                              });
                            }
                          },
                          itemBuilder: (_) =><PopupMenuItem<String>>[
                            new PopupMenuItem<String>(
                                child: const Text('Yes'), value: 'Yes'),
                            new PopupMenuItem<String>(
                                child: const Text('No'), value: 'No'),
                          ],
                          icon: Icon(Icons.chevron_right),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            textAlign: TextAlign.left,
                            text: TextSpan(
                              text: "Available",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: "\nIf product is available after creation",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 13.5
                                  )
                                )
                              ]
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(_isAvailable ? Icons.check_box_outlined : Icons.check_box_outline_blank, color: _isAvailable ? kPrimaryColor : Colors.grey,),
                          onPressed: ()=>setState(() => _isAvailable = !_isAvailable),
                        )
                      ],
                    ),
                  ),
                  if(_isMeal)...{
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            child: Text("Combination",style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),),
                          ),
                          Container(
                            width: double.infinity,
                            child: Text("Note: This is not necessary, this is only if you want to create a product with combination of other product (e.g. A1 (rice, chicken, drinks, fries)",style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic
                            ),),
                          ),
                          for(var combination in combinations)...{
                            const SizedBox(height: 10,),
                            Slidable(
                              key: Key(combination['id'].toString()),
                              controller: _slidableController,
                              secondaryActions: [
                                IconSlideAction(
                                  color: Colors.grey[900],
                                  iconWidget: Icon(Icons.delete,color: Colors.white,),
                                  onTap: () {
                                    setState(() {
                                      combinations.removeWhere((element) => element["id"] == combination['id']);
                                    });
                                  },
                                ),
                              ],
                              actionExtentRatio: 0.20,
                              actionPane: SlidableService().getActionPane(combinations.indexOf(combination)),
                              child: Container(
                                width: double.infinity,
                                height: combination['selected_variations'] != null && combination['selected_variations'].length > 0 ? 90 : 60,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.horizontal(left: Radius.circular(5)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey[300],
                                          offset: Offset(-3,3),
                                          blurRadius: 2
                                      )
                                    ]
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(1000),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey[400],
                                            blurRadius: 3,
                                            offset: Offset(3,3)
                                          )
                                        ],
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: combination['images'].length > 0 ? NetworkImage("https://ekaon.checkmy.dev${combination['images'][0]['url']}") : AssetImage("assets/images/no-image-available.png")
                                        )
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            child: Text("${StringFormatter(string: combination['name']).titlize()}",style: TextStyle(
                                              fontWeight: FontWeight.w600
                                            ),),
                                          ),
                                          //add condition
                                          if(combination['selected_variations'] != null && combination['selected_variations'].length > 0)...{
                                            Container(
                                              width: double.infinity,
                                              margin: const EdgeInsets.only(top: 5),
                                              height: 50,
                                              child: ListView(
                                                scrollDirection: Axis.horizontal,
                                                children: [
                                                  for(var data in combination['selected_variations'])...{
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300].withOpacity(0.6),
                                                        border: Border.all(color: Colors.black38),
                                                        borderRadius: BorderRadius.circular(5)
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Container(
                                                            child: Text("${data['variation']['name']}",style: TextStyle(
                                                              color: Colors.grey[700],
                                                              fontSize: 12.5,
                                                              fontWeight: FontWeight.w600
                                                            ),),
                                                          ),
                                                          Container(
                                                            child: Text("${data['default']['name']}",style: TextStyle(
                                                                color: Colors.grey[600],
                                                              fontSize: 12.5,
                                                            ),),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  }
                                                ],
                                              ),
                                            )
                                          }
                                        ],
                                      ),
                                    ),
                                     const SizedBox(
                                       width: 10,
                                     ),
                                     Text("x ${combination['quantity']}",style: TextStyle(
                                      color: Colors.grey[700]
                                    ),),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          },

                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.grey)
                            ),
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                              ),
                              onPressed: (){
                                Navigator.push(context, PageTransition(child: AddCombinationPage(combinations: combinations,context: _key.currentContext,), type: PageTransitionType.downToUp));
                              },
                              child: Center(
                                child: Text("Add combination"),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  },
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(child: Text("Variation",style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),),
                              variations.length > 0 ? IconButton(
                                  icon: Icon(Icons.clear_all),
                                  onPressed: ()=> setState(()=> variations.clear()),
                                padding: const EdgeInsets.all(0),
                              ) : Container()
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if(variations.length > 0)...{
                          for(var x= 0;x<variations.length;x++)...{
                            Container(
                              width: double.infinity,
                              child: Text("${variations[x]['name']}",style: TextStyle(
                                fontSize: 14.5,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600
                              ),),
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          }
                        },
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey)
                          ),
                          child: FlatButton(
                            onPressed: (){
                              Navigator.push(context, PageTransition(child: VariationPage(context: _key.currentContext,variations: variations,),type: PageTransitionType.downToUp));
                            },
                            child: Center(
                              child: Text("Add variation"),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),

                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: FlatButton(
                                padding: const EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)
                                ),
                                onPressed: (){
                                  Navigator.of(context).pop(null);
                                  chosenCat.updateAll([]);
                                },
                                child: Center(
                                  child: Text("Cancel",style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),),
                                )
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: FlatButton(
                                padding: const EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)
                                ),
                                onPressed: (){
                                  FocusScope.of(context).unfocus();
                                  if(_name.text.isNotEmpty && _description.text.isNotEmpty && _price.text.isNotEmpty && chosenCatsIds.length > 0){
                                    String stringsCatIds = chosenCatsIds.toString().replaceAll("[", '').replaceAll("]", "");
                                    if(_price.text != "0"){
                                      Map _body = {
                                        "store_id" : "${myStoreDetails['id']}",
                                        "name" : _name.text,
                                        "description" : _description.text,
                                        "price" : _price.text,
                                        "category_ids" : stringsCatIds,
                                        "is_meal" : _isMeal ? "1" : "0",
                                        "isAvailable" : _isAvailable ? "1" : "0"
                                      };
                                      List vv = [];
                                      for(var variation in variations){
                                        Map xx = {
                                          "\"variation_id\"" : "\"${variation['id']}\"",
                                          "\"default_variation_id\"" : "\"${variation['details'][0]['id']}\""
                                        };
                                        vv.add(xx);
                                      }
                                      //[{"product_id" : 1, "quantity" : 2, "variation_list" : [{"variation_id" : 1, "default_variation_id" : 2}, {"variation_id": 2, "default_variation_id" : 4}]}, {"product_id" : 2,"quantity" : 1}]

                                      if(vv.length > 0){
                                        _body['variation'] = "$vv";
                                      }
                                      List cc = [];
                                      for(var combi in combinations){
                                        Map xx = {
                                          "\"product_id\"" : "\"${combi['id']}\"",
                                          "\"quantity\"" : "\"${combi['quantity']}\"",
                                        };
                                        if(combi['selected_variations'] != null){
                                          xx["\"variation_list\""] = [];
                                          for(var z in combi['selected_variations']){
                                            xx["\"variation_list\""].add({
                                              "\"variation_id\"" : "\"${z['variation']['id']}\"",
                                              "\"default_variation_id\"" : "\"${z['default']['id']}\"",
                                            });
                                          }
                                        }
                                        cc.add(xx);
                                      }
                                      if(cc.length > 0){
                                        _body['data'] = "$cc";
                                      }
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      _productAuth.add(body: _body).then((value) async {
                                        if(value != null){
                                          _price.clear();
                                          _name.clear();
                                          _description.clear();
                                          chosenCatsIds.clear();
                                          chosenCatsNames.clear();
                                          chosenCat.updateAll([]);
                                          setState(() {
                                            _isMeal = false;
                                          });
                                          await this.uploadImages(_images.length, value['id']);
                                        }
                                      });
                                    }else{
                                      Fluttertoast.showToast(msg: "You can't add a free product");
                                    }
                                  }else{
                                    Fluttertoast.showToast(msg: "Please dont leave a field empty");
                                  }
                                },
                                child: Center(
                                  child: Text("Publish",style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold
                                  ),),
                                )
                            ),
                          ),
                        )
                      ],
                    )
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
            _isLoading ? MyWidgets().loader() : Container()
          ],
        ),
      ),
    );
  }

  showImageDeleteOption() => showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        width: double.infinity,
        height: 200,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.delete),
              title: Text("Remove image"),
              onTap: (){
                _images.removeAt(_selectedImageIndex);
                _base64Images.removeAt(_selectedImageIndex);
                setState(() {
                  _selectedImageIndex =null;
                });
                Navigator.of(context).pop(null);
              },
            ),
            ListTile(
              leading: Icon(Icons.crop),
              title: Text("Crop"),
              onTap: () async {
                await cropImage();
                setState(() {
                  _selectedImageIndex =null;
                });
                Navigator.of(context).pop(null);
              },
            ),
            ListTile(
              leading: Icon(Icons.close),
              title: Text("Close"),
              onTap: (){
                setState(() {
                  _selectedImageIndex =null;
                });
                Navigator.of(context).pop(null);
              },
            )
          ],
        ),
      )
  );
}
