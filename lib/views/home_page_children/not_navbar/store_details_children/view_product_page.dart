import 'dart:io';

import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/interrupts.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/cart.dart';
import 'package:ekaon/services/cart_counter.dart';
import 'package:ekaon/services/favorite.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/products.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/home_page_children/new_cart_page.dart';
import 'package:ekaon/views/home_page_children/not_navbar/store_details_children/review_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class ProductPage extends StatefulWidget {
  final Map details;
  final Map storeDetails;

  ProductPage({Key key, @required this.details, @required this.storeDetails}) : super(key : key);
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  ScrollController _controller = new ScrollController();
  List _images;
  int _imageIndex = 0;
  int _quantity = 1;
  bool _isLoading = false;
  List relatedProducts;
  bool _errorOnRelated = false;
  List otherProducts;
  bool _errorOnOther = false;
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  Future<List> getCatNames() async {
    setState(() {
      _errorOnRelated = false;
    });
    String catNames;
    List d = [];
    for(var names in widget.details['categories']){
      d.add(names['name']);
    }
    setState(() {
      catNames = d.join(',');
    });
    print("Categories : $catNames");
    await ProductAuth().getRelatedProducts(catNames, widget.details['id'], widget.storeDetails['id']).then((value) {
      if(value != null){
        setState(() {
          relatedProducts = value;
        });
      }else{
        setState(() {
          _errorOnRelated = true;
        });
      }
    });
  }
  List selectedVariations;
  bool checkIfExist(int id){
    for(var selected in selectedVariations){
      if(selected['child_id'] == id){
        return true;
      }
    }
    return false;
  }
  getStoreOther() async {
    setState(() {
      _errorOnOther  = false;
    });
    await ProductAuth().getOtherStoreProducts(widget.details['id'], widget.storeDetails['id']).then((value) {
      if(value != null){
        setState(() {
          otherProducts = value;
        });
      }else{
        setState(() {
          _errorOnOther = true;
        });
      }
    });
  }
  getDefaults(){
    for(var parent in widget.details['variations']){
      setState(() {
        selectedVariations.add({
          "parent_id" : parent['id'],
          "child_id" : parent['default_variation_id']
        });
      });
    }
  }
  changeSelectedVarValue(int id, parent_id){
    for(var parent in selectedVariations){
      if(parent['parent_id'] == parent_id){
        setState(() {
          parent['child_id'] = id;
        });
        print("${parent['child_id']}");
      }
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _images = widget.details['images'];
    });
    if(widget.details['variations'] != null){
      setState(() {
        selectedVariations = [];
      });
      getDefaults();
    }
    getCatNames();
    getStoreOther();
  }
  quantityChecker({bool isInc}){
    if(!isInc)
      {
        if(_quantity > 1){
          setState(() {
            _quantity--;
          });
        }
      }
    else
      {
        setState(() {
          _quantity++;
        });
      }
  }
  updateFavorites(bool isAdding)
  {
    Map data = widget.details;
    data['store'] = widget.storeDetails;

    if(isAdding)
    {
      setState(() {
        favoriteProductIds.add(widget.details['id']);
        favoriteProduct.add(widget.details);
      });
    }else{
      setState(() {
        favoriteProductIds.remove(widget.details['id']);
        favoriteProduct.removeWhere((element) => element['id'] == widget.details['id']);
      });
    }
    Favorite().manage(key: 'product_id', value: '${widget.details['id']}');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Scaffold(
            key: _key,
            resizeToAvoidBottomPadding: Platform.isIOS,
            body: Container(
              width: double.infinity,
              alignment: AlignmentDirectional.centerStart,
              child: Scrollbar(
                child: CustomScrollView(
                  controller: _controller,
                  physics: AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      automaticallyImplyLeading: true,
                      expandedHeight: 60,
                      collapsedHeight: 10,
                      toolbarHeight: 0,
                      pinned: false,
                      snap: false,
                      floating: true,
                      flexibleSpace: Container(
                          width: double.infinity,
                          height: 60,
//            alignment: AlignmentDirectional.centerStart,
                          child: Row(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              IconButton(
                                onPressed: (){
                                  Navigator.of(context).pop(null);
                                },
                                icon: Container(
                                  width: 25,
                                  height: 25,
                                  padding: const EdgeInsets.all(2.5),
                                  child: Image.asset("assets/images/${Platform.isIOS ? "left-arrow-ios" : "left-arrow"}.png",color: Colors.black54,),
                                ),
                              ),
                              Spacer(),
                              user_details != null
                                  ? StreamBuilder(
                                stream: cartCounter.stream$,
                                builder: (context, result) => result.hasData ? IconButton(
                                    onPressed: () => Navigator.push(context, PageTransition(child: NewCartPage(),type: PageTransitionType.upToDown)),
                                    icon: MyWidgets().iconWithBadge(image: Image.asset(
                                      "assets/images/cart.png",
                                      color: Colors.black54,
                                    ), badgeColor: Colors.green, count: result.data)
                                ) : Container(),
                              )
                                  : Container(),
//                              IconButton(
//                                icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,color: kPrimaryColor,),
//                                onPressed: ()=> Navigator.of(_key.currentContext).pop(null),
//                              ),
//                              const Spacer(),
//                              user_details != null ? StreamBuilder(
//                                stream: cartCounter.stream$,
//                                builder: (context, result) => result.hasData ? IconButton(
//                                    onPressed: () => Navigator.push(context, PageTransition(child: NewCartPage(),type: PageTransitionType.upToDown)),
//                                    icon: MyWidgets().iconWithBadge(image: Image.asset(
//                                      "assets/images/cart.png",
//                                      color: kPrimaryColor,
//                                    ), badgeColor: Colors.green, count: result.data)
//                                ) : Container(),
//                              ) : Container(),
                              user_details != null && widget.storeDetails['owner']['id'] != user_details.id ? IconButton(
                                  onPressed: (){
                                    if(favoriteProductIds.contains(widget.details['id'])){
                                      updateFavorites(false);
                                    }else{
                                      updateFavorites(true);
                                    }
                                  },
                                  //Icon(favoriteProductIds.contains(widget.details['id']) ? Icons.favorite : Icons.favorite_border,color: kPrimaryColor,)
                                  icon: Container(
                                    width: 25,
                                    height: 25,
                                    child: Image.asset(
                                      "assets/images/${favoriteProductIds.contains(widget.details['id']) ? "filled_favorite" : "border_favorite"}.png",
                                      color:favoriteProductIds.contains(widget.details['id']) ? kPrimaryColor : Colors.black54,
                                    ),
                                  )
                              ) : Container()
                            ],
                          )
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          GestureDetector(
                            onTap: (){
                              Interrupts().showImageFull(_images.length == 0 ? null : _images[_imageIndex]['url'], _key.currentContext);
                            },
                            child: AnimatedContainer(
                              width: double.infinity,
                              height: Percentage().calculate(num: scrh, percent: 45),
                              duration: Duration(milliseconds: 600),
                              color: Colors.grey[100],
                              child: _images.length > 0 ? Image.network("https://ekaon.checkmy.dev/${_images[_imageIndex]['url']}") : Image.asset("assets/images/no-image-available.png",fit: BoxFit.cover,),
                            ),
                          ),
                          _images.length > 0 ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    for(var x =0;x<_images.length;x++)...{
                                      GestureDetector(
                                        onTap: () => setState(()=> _imageIndex = x),
                                        child: Container(
                                          width: Percentage().calculate(num: scrw,percent: 20),
                                          height: Percentage().calculate(num: scrw,percent: 20),
                                          margin: EdgeInsets.only(right: 10, left: x == 0 ? 20 : 0),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: x == _imageIndex ? kPrimaryColor : Colors.transparent,width: 3),
                                              borderRadius: BorderRadius.circular(5)
                                          ),
                                          child: Image.network("https://ekaon.checkmy.dev/${_images[x]['url']}"),
                                        ),
                                      )
                                    }
                                  ],
                                ),
                              ),
                            ),
                          ) : Container(),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text("${widget.details['name']}".toUpperCase(),style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: scrw > 700 ? 3.5 : 4)
                            ),),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text("${widget.details['description']}",style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                                fontSize: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: scrw > 700 ? 3 : 3.5)
                            ),),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            width: double.infinity,
                            child: Text("Php${double.parse(widget.details['price'].toString()).toStringAsFixed(2)}",style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: scrw > 700 ? 2.7 : 3.4)
                            ),),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            child: Row(
                              children: <Widget>[
                                for(var x = 0;x<5;x++)...{
                                  Icon(Icons.star,color: double.parse(ProductAuth().ratingCalculator(ratings: widget.details['ratings']).toString()) <= x ? Colors.grey :  Colors.orangeAccent,size: 15,)
                                },
                                const SizedBox(
                                  width: 10,
                                ),
                                Text("${ProductAuth().ratingCalculator(ratings: widget.details['ratings'])} ",style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: Percentage().calculate(num: scrw, percent: 3)
                                ),),
                                widget.details['ratings'].length > 0 ? Container(
                                  child: Text(""),
                                ) : Container(),
                                GestureDetector(
                                  onTap: (){
                                    print("Go to review page");
                                    Navigator.push(context, PageTransition(child: ReviewPage(data: widget.details['ratings'], type: 1)));
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.orangeAccent,
                                          borderRadius: BorderRadius.circular(100)
                                      ),
                                      child: Text("${widget.details['ratings'].length >= 1000 ? "${double.parse((widget.details['ratings'].length/1000).toString()).toStringAsFixed(1)}k+" : "${widget.details['ratings'].length}"} Reviews",style: TextStyle(
                                          color: Colors.white
                                      ),)
                                  ),
                                ),
                                Spacer(),
                                widget.details['is_meal'] > 0 ? Container(
                                  width: 25,
                                  height: 25,
                                  child: Center(
                                    child: Image.asset("assets/images/meal.png",color: kPrimaryColor,),
                                  ),
                                ) : Container(),
                              ],
                            ),
                          ),
                          if(widget.details['combinations'] != null && widget.details['combinations'].length > 0)...{
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text("Comes with :",style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Theme.of(context).textTheme.headline6.fontSize - 5
                              ),),
                            ),
                            for(var combination in widget.details['combinations']['details'])...{
                              Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey[300],
                                            offset: Offset(3,3),
                                            blurRadius: 3
                                        )
                                      ]
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        margin: const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(1000),
                                            color: Colors.grey[100],
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey[400],
                                                  offset: Offset(3,3),
                                                  blurRadius: 3
                                              )
                                            ],
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: combination['product_details']['images'].length == 0 ? AssetImage("assets/images/no-image-available.png") : NetworkImage("https://ekaon.checkmy.dev${combination['product_details']['images'][0]['url']}")
                                            )
                                        ),
                                      ),
                                      Expanded(
                                          child: Column(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                child: Text("${StringFormatter(string: combination['product_details']['name']).titlize()}",style: TextStyle(
                                                    color: Colors.black54,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: Theme.of(context).textTheme.bodyText1.fontSize
                                                ),),
                                              ),
                                              combination['def_var_det_ids'] == null ? Container() : Container(
                                                width: double.infinity,
                                                child: Column(
                                                  children: [
                                                    for(var variation in combination['default_variation_data'])...{
                                                      Container(
                                                        width: double.infinity,
                                                        child: Text("${variation['name']} : ${variation['default']['name']}",style: TextStyle(
                                                            fontStyle: FontStyle.italic,
                                                            color: Colors.grey[400]
                                                        ),),
                                                      )
                                                    }
                                                  ],
                                                ),
                                              )
                                            ],
                                          )
                                      ),
                                      Text("Qty: ${combination['quantity']}",style: TextStyle(
                                          color: Colors.black54
                                      ),)
                                    ],
                                  )
                              ),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                child: Divider(),
                              )
                            }
                          },
                          if(widget.details['variations'] != null && widget.details['variations'].length > 0)...{

                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text("Variations :",style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Theme.of(context).textTheme.headline6.fontSize - 5
                              )),
                            ),

                            for(var parent in widget.details['variations'])...{
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                width: double.infinity,
                                child: Text(parent['variation']['name'],style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600
                                ),),
                              ),
                              for(var child in parent['variation']['details'])...{
                                GestureDetector(
                                  onTap: user_details == null || widget.storeDetails['owner']['id'] == user_details.id ? null : (){
                                    changeSelectedVarValue(child['id'], parent['id']);
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                        color: user_details == null || widget.storeDetails['owner']['id'] == user_details.id ? Colors.grey[100] : checkIfExist(child['id']) ? kPrimaryColor : Colors.transparent,
                                        borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Text("${child['name']}",style: TextStyle(
                                                color: user_details == null || widget.storeDetails['owner']['id'] == user_details.id ? Colors.black54 : checkIfExist(child['id']) ? Colors.white : Colors.black54
                                            ),),
                                          ),
                                        ),
                                        Text(child['price'] > 0 ? "+${child['price']}" : "Free",style: TextStyle(
                                            color: user_details == null || widget.storeDetails['owner']['id'] == user_details.id ? kPrimaryColor : checkIfExist(child['id']) ? Colors.white : kPrimaryColor
                                        ))
                                      ],
                                    ),
                                  ),
                                )
                              }
                            }
                          },
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text("Category :",style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: scrw > 700 ? 2.7 : 3.4)
                            )),
                          ),
                          Container(
                            width: double.infinity,
                            height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 15),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.details['categories'].length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: Percentage().calculate(num: scrw,percent: 22),
                                  height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 15),
                                  margin: const EdgeInsets.only(left: 20),
                                  padding: const EdgeInsets.only(bottom: 5,left: 5,right: 5,top: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        width: Percentage().calculate(num: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 15),percent: 60),
                                        height: Percentage().calculate(num: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 15),percent: 60),
                                        decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(100),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey[300],
                                                  blurRadius: 5,
                                                  spreadRadius: 5
                                              )
                                            ],
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: widget.details['categories'][index]['image_url'] != null ? NetworkImage("https://ekaon.checkmy.dev${widget.details['categories'][index]['image_url']}") : AssetImage("assets/images/no-image-available.png")
                                            )
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: Text("${widget.details['categories'][index]['name']}",textAlign: TextAlign.center,style: TextStyle(
                                            fontSize: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: 3)
                                        ),),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          user_details == null || widget.storeDetails['owner']['id'] == user_details.id ? Container() : Container(
                            width: double.infinity,
                            alignment: AlignmentDirectional.centerStart,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: kPrimaryColor,
                                    borderRadius: BorderRadius.horizontal(left: Radius.circular(5))
                                  ),
                                  child: IconButton(
                                    onPressed: ()=>quantityChecker(isInc: false),
                                    icon: Icon(Icons.remove,color: Colors.white,),
                                  ),
                                ),
                                Container(
                                  height: 48,
                                  color: kPrimaryColor,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text("$_quantity",style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600
                                  ),),
                                ),
                                Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      borderRadius: BorderRadius.horizontal(right: Radius.circular(5))
                                  ),
                                  child: IconButton(
                                    onPressed: ()=>quantityChecker(isInc: true),
                                    icon: Icon(Icons.add,color: Colors.white,),
                                  ),
                                )
                              ],
                            ),
                          ),

                          user_details == null || widget.storeDetails['owner']['id'] == user_details.id ? Container() : Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                            height: 60,
                            child: MyWidgets().button(
                                pressed: (){
                                  Map _data;
                                  setState(() {
                                    _isLoading = true;
                                    _data = widget.details;
                                    _data['quantity'] = _quantity;
                                    _data['sub_total'] = double.parse((_quantity * widget.details['price']).toString());
                                  });
                                  List variationIds = [];
                                  for(var _id in selectedVariations){
                                    variationIds.add(_id['child_id']);
                                  }
                                  String variationIdsSend = variationIds.join(',');
                                  cartAuth.addToCart(
                                      product: _data,
                                      variationIds: variationIds.length == 0 ? null : variationIdsSend
                                  ).whenComplete(() => setState(() => _isLoading = false)).whenComplete(() => setState(()=> _isLoading = false));
//                          if(cartAuth.checkStore(storeId: widget.storeDetails['id'])){
//                            Map _data;
//                            setState(() {
//                              _data = widget.details;
//                              _data['quantity'] = _quantity;
//                              _data['sub_total'] = double.parse((_quantity * widget.details['price']).toString());
//                            });
//                            if(cartAuth.checkProduct(data: _data, storeId: widget.storeDetails['id'], selectedVariations: selectedVariations)){
//                              //update quantity x total
//                              print("ASD");
//                              cartAuth.updateProduct(store_id: widget.storeDetails['id'], data: _data);
//                            }else{
//                              //append product to store
//                              print("WARA AN PRODUCT");
//                              cartAuth.appendProduct(data: widget.details,storeId: widget.storeDetails['id'], quantity: _quantity, total: double.parse((_quantity * widget.details['price']).toString()));
//                            }
//                          }else{
//                            setState(() {
//                              _isLoading = true;
//                            });
//                            cartAuth.add(storeId: widget.storeDetails['id'], productId: widget.details['id'], quantity: _quantity, total: double.parse((_quantity * widget.details['price']).toString())).whenComplete(() => setState(() => _isLoading = false));
//                          }
//                          setState(() {
//                            _quantity = 1;
//                          });
//                          Map _product = widget.details;
//                          _product['quantity'] = _quantity;
//                          _product['sub_total'] = double.parse(_quantity.toString()) * double.parse(widget.details['price'].toString());
//                          Cart(store: widget.storeDetails, product: _product).add().then((value) {
//                            if(value != null){
//                              setState(() {
//                                myCart = value;
//                              });
//                            }
//                          });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.add_shopping_cart,color: Colors.white,),
                                    Text(" Add to cart",style: TextStyle(
                                        color: Colors.white,
                                        fontSize: scrw > 700 ? scrw/35 : scrw/25,
                                        fontWeight: FontWeight.w600
                                    ),)
                                  ],
                                )
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text("Store products :",style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: scrw > 700 ? 2.7 : 3.4)
                            )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: scrw > 700 ? 14 : 19),
                            child: otherProducts == null ? Center(
                              child: _errorOnOther ? Text("An error has occurred, please try again later") : SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                                  strokeWidth: 1.5,
                                ),
                              ),
                            ) : otherProducts.length > 0 ? ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: otherProducts.length,
                                itemBuilder: (context, index)=> _otherProducts(data: otherProducts[index], onPressed: (){
                                  Navigator.of(context).pop();
                                  Navigator.push(context, PageTransition(child: ProductPage(details: otherProducts[index], storeDetails: widget.storeDetails), type: PageTransitionType.leftToRightWithFade));
                                })
                            ) : Center(
                              child: Text("There are no related products"),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text("Related products :",style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: scrw > 700 ? 2.7 : 3.4)
                            )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: double.infinity,
                            height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: scrw > 700 ? 14 : 19),
                            child: relatedProducts == null ? Center(
                              child: _errorOnRelated ? Text("An error has occurred, please try again later") : SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                                  strokeWidth: 1.5,
                                ),
                              ),
                            ) : relatedProducts.length > 0 ? ListView.builder(
                                itemCount: relatedProducts.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index)=> _otherProducts(data: relatedProducts[index], onPressed: (){
                                  Navigator.of(context).pop();
                                  print("ADTO NA SA HOMEPAGE");
                                  Navigator.of(context).pop();
                                  Navigator.push(context, PageTransition(child: ProductPage(details: relatedProducts[index], storeDetails: relatedProducts[index]['store_details']), type: PageTransitionType.leftToRightWithFade));
                                })
                            ) : Center(
                              child: Text("There are no related products"),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ),
            ),
          ),
          _isLoading ? MyWidgets().loader() : Container()
        ],
      ),
    );
  }

  Widget _otherProducts({Map data, Function onPressed}) => GestureDetector(
      onTap: onPressed,
    child: Container(
      margin: const EdgeInsets.only(left: 20),
      width: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: 30),
      height: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey[100],
          image: DecorationImage(
              fit: BoxFit.cover,
              image: data['images'].length > 0 ? NetworkImage("https://ekaon.checkmy.dev${data['images'][0]['url']}") : AssetImage("assets/images/no-image-available.png")
          )
      ),
    ),
  );
}
