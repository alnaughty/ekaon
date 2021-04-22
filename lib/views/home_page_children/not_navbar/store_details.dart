import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/custom_app_bar.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/ad.dart';
import 'package:ekaon/services/cart.dart';
import 'package:ekaon/services/cart_counter.dart';
import 'package:ekaon/services/discount.dart';
import 'package:ekaon/services/distancer.dart';
import 'package:ekaon/services/distancer_service.dart';
import 'package:ekaon/services/favorite.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/position_listener.dart';
import 'package:ekaon/services/products.dart';
import 'package:ekaon/services/store.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/services/vote.dart';
import 'package:ekaon/views/home_page_children/drawer/my_store_children/has_store_children/ticket_clipper.dart';
import 'package:ekaon/views/home_page_children/new_cart_page.dart';
import 'package:ekaon/views/home_page_children/not_navbar/store_details_children/review_page.dart';
import 'package:ekaon/views/home_page_children/not_navbar/store_details_components/grid_view.dart';
import 'package:ekaon/views/home_page_children/not_navbar/store_details_components/list_view.dart';
import 'package:ekaon/views/home_page_children/search.dart';
import 'package:ekaon/views/map_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:page_transition/page_transition.dart';

class StoreDetailsPage extends StatefulWidget {
  Map data;
  StoreDetailsPage({Key key, @required this.data}) : super(key : key);
  enableLoader(BuildContext context, bool state){
    context.findAncestorStateOfType<_StoreDetailsPageState>().load(state);
  }
  @override
  _StoreDetailsPageState createState() => _StoreDetailsPageState();
}

class _StoreDetailsPageState extends State<StoreDetailsPage> with SingleTickerProviderStateMixin {
  PageController _pageController = PageController();
  List vouchers;
  void _animateSlider() async {
    if(this.mounted){
      await Future.delayed(Duration(seconds: 3)).then((_) async {
        int nextPage = _pageController.page.round() + 1;
        if(nextPage == _featuredPhoto.length) {
          await Future.delayed(Duration(seconds: 2));
          nextPage = 0;
        }
        _pageController.animateToPage(nextPage, duration: Duration(seconds: 1), curve: Curves.linear).then((_) => _animateSlider());
      });
    }
  }
  bool _isLoading = false;
  load(bool state){
    setState(() => _isLoading = state);
  }
  Store _store = new Store();
//  int chosenCategoryId;
  int chosenCatInt;
  List _productList;
  List _displayData;
  bool _isListView = true;
  String _noProduct = "No available product \nfor this store yet.";
  bool _isKeyboardActive = false;
  List _featuredPhoto;
  SlidableController slidableController;
  Future<List> _categorySearch() async {
    List _store = [];
    for(var data in _productList){
      for(var catData in data['categories'])
      {
        if(catData['id'] == chosenCatInt){
          _store.add(data);
        }
      }
    }
    return _store;
  }
  _updateStoreLikes(bool isAdding)
  {
    for(var x=0;x<displayData.length;x++)
    {
      if(displayData[x]['id'] == widget.data['id'])
      {
        if(isAdding){

          setState(() {
            displayData[x]['total_likes']+=1;
//            widget.data['total_likes'] = int.parse(widget.data['total_likes'].toString()) + 1;
          });
        }else{
          setState(() {
            displayData[x]['total_likes']-=1;
//            widget.data['total_likes']-=1;
          });
        }
      }
    }
  }
  _updateStoreDislikes(bool isAdding){
    for(var x=0;x<displayData.length;x++){
      if(displayData[x]['id'] == widget.data['id'])
      {
        if(isAdding){
          setState(() {
            displayData[x]['total_dislikes']+=1;
          });
        }else{
          setState(() {
            displayData[x]['total_dislikes']-=1;
          });
        }
      }
    }
  }
  updateFavorites(bool isAdding)
  {
    if(isAdding)
    {
      setState(() {
        favoriteStoreIds.add(widget.data['id']);
        favoriteStore.add(widget.data);
      });
    }else{
      setState(() {
        favoriteStoreIds.remove(widget.data['id']);
        favoriteStore.removeWhere((element) => element['id'] == widget.data['id']);
      });
    }
    Favorite().manage(key: "store_id", value:'${widget.data['id']}');
  }
  getProducts() async{
    var dd = await _store.getProducts(storeId: widget.data['id']);
    if(dd != null){
      setState(() {
        _productList = dd;
        _displayData = _productList;
      });
      if(_productList.length > 0){
        setState(() {
          _noProduct = "The product you are\nlooking for is not here.";
        });
      }
    }
  }
  getDeliveryStatus() async {
    await Store().getStoreDeliveyState(widget.data['id']).then((value) {
      if(value != null){
        setState(() {
          widget.data['hasDelivery'] = value['status'];
          widget.data['storeOpen'] = value['store_open'];
        });
      }
    });
  }
  bool goBack = false;
  Animation<double> _rotationAnimation;
  Color _fabColor = Colors.blue;
  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {
      _rotationAnimation = slideAnimation;
    });
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {
      _fabColor = isOpen ? Colors.green : Colors.blue;
    });
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
      slidableController = SlidableController(
        onSlideAnimationChanged: handleSlideAnimationChanged,
        onSlideIsOpenChanged: handleSlideIsOpenChanged,
      );
      Discount().get(store_id: int.parse(widget.data['id'].toString())).then((value) {
        if(value != null) {
          setState(() {
            vouchers = value['data'];
          });
        }
      });
    }

    getDeliveryStatus();
    getProducts();
    getFeaturedPhotos();
  }
  getFeaturedPhotos() async {
    await Store().getFeaturedPhotos(widget.data['id']).then((value) {
      if(value != null){
        setState(() {
          _featuredPhoto = value;
        });
        if(_featuredPhoto.length > 0){
          WidgetsBinding.instance.addPostFrameCallback((_) => _animateSlider());
        }
      }
    });
  }
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _key,
        resizeToAvoidBottomPadding: Platform.isIOS,
        body: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: Platform.isAndroid ? MediaQuery.of(context).size.height-(_isKeyboardActive ? Percentage().calculate(num: MediaQuery.of(context).size.height,percent: MediaQuery.of(context).size.height > 700 ? 45 : 50) : 0) : MediaQuery.of(context).size.height,
              child: SafeArea(
                child: Stack(
                  children: <Widget>[
                    Container(
                      child: CustomScrollView(
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                  _displayData != null ? IconButton(
                                    onPressed: (){
                                      Navigator.push(context, PageTransition(child: SearchPage(data: _displayData, type: 3,store_details: widget.data,)));
                                    },
                                    icon: Container(
                                      width: 25,
                                      height: 25,
                                      child: Image.asset("assets/images/search.png",color: Colors.black54,),
                                    ),
                                  ) : Container(),
                                  user_details != null && widget.data['owner']['id'] != user_details.id ? IconButton(
                                      onPressed: (){
                                        if(favoriteStoreIds.contains(widget.data['id'])){
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
                                          "assets/images/${favoriteStoreIds.contains(widget.data['id']) ? "filled_favorite" : "border_favorite"}.png",
                                          color:favoriteStoreIds.contains(widget.data['id']) ? kPrimaryColor : Colors.black54,
                                        ),
                                      )
                                  ) : Container()
                                ],
                              ),
                            )
                          ),
                          SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                //Carousel
                                AnimatedContainer(
                                  width: double.infinity,
                                  margin: EdgeInsets.only(bottom: 10),
                                  height: _featuredPhoto == null || _featuredPhoto.length == 0 ? 0 : Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 30),
                                  duration: Duration(milliseconds: 600),
                                  curve: Curves.linear,
                                  child: _featuredPhoto == null ? Container() : PageView(
                                    controller: _pageController,
//                              physics: NeverScrollableScrollPhysics(),
                                    children: <Widget>[
                                      for(var featured in _featuredPhoto)...{
                                        AnimatedContainer(
                                          width: double.infinity,
//                                    margin: EdgeInsets.only(bottom: _featuredPhoto == null || _featuredPhoto.length == 0 ? 60 : 10),
                                          height: _featuredPhoto == null || _featuredPhoto.length == 0 ? 0 : Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 30),
                                          duration: Duration(milliseconds: 600),
                                          curve: Curves.linear,
                                          child: FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: "https://ekaon.checkmy.dev${featured['image_url']}",fit: BoxFit.cover,),
                                        )
                                      }
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: const EdgeInsets.only(left: 20),
                                        width: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: MediaQuery.of(context).size.height > 700 ? 17 : 18),
                                        height: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: MediaQuery.of(context).size.height > 700 ? 17 : 18),
                                        decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey[300],
                                                  offset: Offset(3,3),
                                                  blurRadius: 2
                                              )
                                            ],
                                            borderRadius: BorderRadius.circular(5.0),
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: widget.data['picture'] != null ? NetworkImage('https://ekaon.checkmy.dev${widget.data['picture']}') : AssetImage("assets/images/default_store.png")
                                            )
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              width: double.infinity,
                                              child: Text("${widget.data['name'].toString()[0].toUpperCase() + widget.data['name'].toString().substring(1)}",style: TextStyle(
                                                  fontSize: Percentage().calculate(num: MediaQuery.of(context).size.width,percent:4),
                                                  fontWeight: FontWeight.bold
                                              ),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                            ),
                                            widget.data['longitude'] == null && widget.data['latitude'] == null ? Container(
                                              width: double.infinity,
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(Icons.location_on),
                                                  Expanded(
                                                    child: Text("Address location unspecified",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(
                                                        decoration: TextDecoration.underline
                                                    ),),
                                                  )
                                                ],
                                              ),
                                            ) : GestureDetector(
                                              onTap: ()async{
                                                Navigator.push(context, PageTransition(child: MapPage(name: widget.data['name'], longitude: double.parse(widget.data['longitude'].toString()), latitude: double.parse(widget.data['latitude'].toString())), type: PageTransitionType.fade));
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                child: Row(
                                                  children: <Widget>[
                                                    Icon(Icons.location_on),
                                                    Expanded(
                                                      child: Text("${widget.data['address']}",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(
                                                          decoration: TextDecoration.underline
                                                      ),),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                                width: double.infinity,
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: FlatButton(
                                                        padding: const EdgeInsets.symmetric(horizontal: 0),
                                                        onPressed: (){
                                                          Navigator.push(context, PageTransition(child: ReviewPage(data: widget.data['rating'],type: 0,), type: PageTransitionType.leftToRightWithFade));
                                                        },
                                                        child: Row(
                                                          children: <Widget>[
                                                            Icon(Icons.star,color: Colors.amber,size: 15,),
                                                            Text("${ProductAuth().ratingCalculator(ratings: widget.data['rating'])}",style: TextStyle(
                                                                color: Colors.black54,
                                                                fontSize: Percentage().calculate(num: MediaQuery.of(context).size.width,percent:3.5)
                                                            ),),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Icon(Icons.visibility,color: Colors.grey,size: 15,)

//                                                    Text("Store reviews",style: TextStyle(
//                                                        color: Colors.black54
//                                                    ),)
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    widget.data['hasDelivery'] == 1 ? Container(
                                                      width: 25,
                                                      height: 25,
                                                      child: Image.asset("assets/images/delivery_icon.png",color: Colors.green[600],),
                                                    ) : Container()
                                                  ],
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
//                                const SizedBox(
//                                  width: 10,
//                                ),
                                      Container(
                                        width: Percentage().calculate(num: scrw,percent: 20),
                                        height: 60,
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                child: FlatButton(
                                                  padding : const EdgeInsets.symmetric(horizontal: 0),
                                                  onPressed : user_details == null || user_details.id == widget.data['owner']['id'] ? null : () {
                                                    setState(() {
                                                      if(likedStore.contains(widget.data['id'])){
                                                        likedStore.remove(widget.data['id']);
                                                        _updateStoreLikes(false);
                                                        VoteAuth().vote(widget.data['id'], 1);
                                                      }else{
                                                        likedStore.add(widget.data['id']);
                                                        _updateStoreLikes(true);
                                                        if(dislikedStore.contains(widget.data['id'])){
                                                          dislikedStore.remove(widget.data['id']);
                                                          _updateStoreDislikes(false);

                                                        }
                                                        VoteAuth().vote(widget.data['id'], 2);
                                                      }
                                                    });
                                                  },
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      Icon(Icons.thumb_up,color: user_details != null ? likedStore.contains(widget.data['id']) ? kPrimaryColor : Colors.grey[600] : Colors.grey[600],),
                                                      Text("${widget.data['total_likes'] > 1000 ? "${double.parse((widget.data['total_likes']/1000).toString()).toStringAsFixed(1)}" : "${widget.data['total_likes']}"}",style: TextStyle(
                                                        color: user_details != null ? likedStore.contains(widget.data['id']) ? kPrimaryColor : Colors.grey[600] : Colors.grey[600],
                                                      ),)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                child: FlatButton(
                                                  padding : const EdgeInsets.symmetric(horizontal: 0),
                                                  onPressed : user_details == null || user_details.id == widget.data['owner']['id'] ? null : () {
                                                    setState(() {
                                                      if(dislikedStore.contains(widget.data['id']))
                                                      {
                                                        dislikedStore.remove(widget.data['id']);
                                                        _updateStoreDislikes(false);
                                                        VoteAuth().vote(widget.data['id'], 1);

                                                      }else{
                                                        dislikedStore.add(widget.data['id']);
                                                        _updateStoreDislikes(true);
                                                        if(likedStore.contains(widget.data['id'])){
                                                          likedStore.remove(widget.data['id']);
                                                          _updateStoreLikes(false);
                                                        }
                                                        VoteAuth().vote(widget.data['id'], 0);
                                                      }
                                                    });
                                                  },
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      Icon(Icons.thumb_down, color: user_details != null ? dislikedStore.contains(widget.data['id']) ? kPrimaryColor : Colors.grey[600] : Colors.grey[600],),
                                                      Text("${widget.data['total_dislikes'] > 1000 ? "${double.parse((widget.data['total_dislikes']/1000).toString()).toStringAsFixed(1)}" : "${widget.data['total_dislikes']}"}",style: TextStyle(
                                                        color: user_details != null ? dislikedStore.contains(widget.data['id']) ? kPrimaryColor : Colors.grey[600] : Colors.grey[600],
                                                      ),)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                if(vouchers != null && vouchers.length > 0)...{
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(left: 20,top: 10),
                                    child: Text("Vouchers",style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold
                                    ),),
                                  ),

                                  Container(
                                    width: double.infinity,
                                    height: 90,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: <Widget>[
                                        for(var voucher in vouchers)...{
                                          Container(
                                            margin: const EdgeInsets.only(left: 20),
                                            width: Percentage().calculate(num: scrw, percent: 60),
                                            child: TicketWidget(
                                              height: 90,
                                                color: StringFormatter(string: voucher['color']).stringToColor(),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 2,
                                                        child: Container(
                                                            alignment: AlignmentDirectional.centerStart,
                                                            child: Row(
                                                              children: <Widget>[
                                                                Expanded(
                                                                  child: RichText(
                                                                    textAlign: TextAlign.left,
                                                                    text: TextSpan(
                                                                        text: "${voucher['value']}",
                                                                        style: TextStyle(
                                                                            color: Colors.black,
                                                                            fontWeight: FontWeight.w600,
                                                                            fontSize: 35
                                                                        ),
                                                                        children: [
                                                                          TextSpan(
                                                                              text: "${int.parse(voucher['type'].toString()) == 1 ? "%" : "₱"} OFF",
                                                                              style: TextStyle(
                                                                                  fontWeight: FontWeight.w500,
                                                                                  fontSize: 13
                                                                              )
                                                                          )
                                                                        ]
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                      color: kPrimaryColor,
                                                                      borderRadius: BorderRadius.circular(5)
                                                                  ),
//                                                                padding:
                                                                  child: FlatButton(
                                                                    padding: const EdgeInsets.all(1),
                                                                    onPressed: (){
                                                                      Clipboard.setData(new ClipboardData(text: "${voucher['code']}"));
                                                                      Fluttertoast.showToast(msg: "Code copied to clipboard");
                                                                    },
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(5)
                                                                    ),
                                                                    child: Text("Copy",style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontSize: 13
                                                                    ),),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                        ),
                                                      ),
                                                  Container(
                                                              margin: const EdgeInsets.symmetric(vertical: 2.5),
                                                              width: double.infinity,
                                                              child: Text("Valid until ${DateFormat('MMM. dd').format(DateTime.parse(voucher['valid_until'].toString()))}",style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: 10
                                                              ),),
                                                            ),
                                                      brokenLines(count: 15,height: 1,color: Colors.grey[100],),
                                                      Expanded(
                                                        child: Container(
                                                          margin: const EdgeInsets.only(top: 5),
                                                          child: Container(
                                                            width: double.infinity,
                                                            child: Text("Min spend ₱${double.parse(voucher['on_reach'].toString()).toStringAsFixed(2)}",style: TextStyle(
                                                                fontSize: 10
                                                            ),),
                                                          ),
                                                        ),
                                                      )

                                                    ],
                                                  ),
                                                ),
                                            ),
                                          )
                                        }
                                      ],
                                    ),
                                  )
                                },
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(left: 20,top: 10),
                                  child: Text("Store Schedule",style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                                Container(
                                  width: double.infinity,
//                            height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 11.5),
                                  color: Colors.grey[100],
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                                    child: widget.data['schedule'] == null ? Center(
                                      child: Text("Unspecified",style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
//                                    fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3 : 3.3)
                                      ),),
                                    ) : RichText(
                                      text: TextSpan(
                                          text: "${widget.data['schedule']['time']}",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
//                                      fontSize: Percentage().calculate(num: scrw, percent: scrw > 700 ? 3 : 3.3)
                                          ),
                                          children: [
                                            TextSpan(
                                                text: "\n${widget.data['schedule']['days']}",
                                                style: TextStyle(
                                                    color: Colors.black54
                                                )
                                            )
                                          ]
                                      ),
                                    ),
                                  ),
                                ),
                                AdmobBanner(adUnitId: AdmobService().getStoreBannerAdId(), adSize: AdmobBannerSize.FULL_BANNER),
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(left: 20,top: 10),
                                  child: Text("Categories",style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                                if(widget.data['categories'] == null)...{
                                  Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(kPrimaryColor),
                                          strokeWidth: 1.5,
                                        ),
                                      )
                                  )
                                }else...{
                                  if(widget.data['categories'].length > 0)...{
                                    Container(
                                      width: double.infinity,
                                      height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 15),
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: widget.data['categories'].length,
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () async {
                                              if(chosenCatInt == widget.data['categories'][index]['id']){
                                                setState(() {
                                                  chosenCatInt = null;
                                                  _displayData = _productList;
                                                });
                                              }else{
                                                setState(() {
                                                  chosenCatInt = widget.data['categories'][index]['id'];
                                                });
                                                var data = await this._categorySearch();
                                                setState(() {
                                                  _displayData = data;
                                                });
                                              }
                                            },
                                            child: Container(
                                              width: Percentage().calculate(num: scrw,percent: 22),
                                              height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 15),
                                              margin: const EdgeInsets.only(left: 20),
                                              padding: const EdgeInsets.only(bottom: 5,left: 5,right: 5,top: 10),
                                              decoration: BoxDecoration(
                                                  color: this.chosenCatInt == widget.data['categories'][index]['id'] ? Colors.grey[400] : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(10)
                                              ),
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
                                                            image: widget.data['categories'][index]['image_url'] != null ? NetworkImage("https://ekaon.checkmy.dev${widget.data['categories'][index]['image_url']}") : AssetImage("assets/images/no-image-available.png")
                                                        )
                                                    ),
                                                  ),
//                                                  Expanded(
//                                                    child: Container(
//                                                      margin: const EdgeInsets.only(top: 10),
////                                        width: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: 16),
////                                        height: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: 16),
//                                                      decoration: BoxDecoration(
//                                                          color: Colors.grey[200],
//                                                          borderRadius: BorderRadius.circular(100),
//                                                          boxShadow: [
//                                                            BoxShadow(
//                                                                color: Colors.grey[300],
//                                                                blurRadius: 5,
//                                                                spreadRadius: 5
//                                                            )
//                                                          ],
//                                                          image: DecorationImage(
//                                                              fit: BoxFit.cover,
//                                                              image: widget.data['categories'][index]['image_url'] != null ? NetworkImage("https://ekaon.checkmy.dev${widget.data['categories'][index]['image_url']}") : AssetImage("assets/images/no-image-available.png")
//                                                          )
//                                                      ),
//                                                    ),
//                                                  ),
                                                  MediaQuery.of(context).size.height > 700 ? SizedBox(
                                                    height: 10,
                                                  ) : Container(),
                                                  Container(
//                                                    margin: const EdgeInsets.only(top: 10),
                                                    width: double.infinity,
                                                    child: Text("${widget.data['categories'][index]['name']}",textAlign: TextAlign.center,style: TextStyle(
                                                        fontSize: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: 3)
                                                    ),),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  }else...{
                                    Container(
                                      margin: const EdgeInsets.only(top: 20),
                                      width: double.infinity,
                                      child: Text("No category found in this store yet",textAlign: TextAlign.center,style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    )
                                  }
                                },
                                Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(left: 20,top: 20),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text("Menu",style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold
                                          ),),
                                        ),
                                        IconButton(
                                          onPressed: (){
                                            setState(() {
                                              _isListView = !_isListView;
                                            });
                                          },
                                          icon: Icon(!_isListView ? Icons.list : Icons.grid_on),
                                        )
                                      ],
                                    )
                                ),
                                if(_productList == null)...{
                                  SizedBox(
                                    height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 25),
                                  ),
                                  Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(kPrimaryColor),
                                      strokeWidth: 2,
                                    ),
                                  )
                                }else...{
                                  if(_displayData.length > 0)...{
                                    if(_isListView)...{
                                      //ListView
                                      for(var x = 0;x<_displayData.length;x++)...{
                                        Stack(
                                          children: <Widget>[
                                            ListViewProduct(_key.currentContext,data: _displayData[x], controller: slidableController, index: x, storeOwnerId: widget.data['owner']['id'],storeDetails: widget.data,),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            _displayData[x]['isAvailable'] == 0 ? Container(
                                              width: double.infinity,
                                              height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: MediaQuery.of(context).size.height > 700 ? 10 : 12),
                                              color: Colors.grey[200].withOpacity(0.6),
                                            ) : Container()
                                          ],
                                        )
                                      }
                                    }else...{
                                      //Gridview
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: GridViewProduct(data: _displayData, storeDetails: widget.data,),
                                      )
                                    }
                                  }else...{
                                    Container(
                                      margin: const EdgeInsets.only(top: 20),
                                      width: double.infinity,
                                      child: Text("No products found in this store yet",textAlign: TextAlign.center,style: TextStyle(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold
                                      ),),
                                    )
                                  }
                                }
                              ],
                            ),
                          )
                        ],
                      )
                    ),
                    widget.data['storeOpen'] == 1 ? Container() : Container(
                      color: Colors.grey[300].withOpacity(0.8),
                      width: double.infinity,
                      child: Column(
                        children: [
                          Container(
                            height: 60,
                            width: double.infinity,
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: (){
                                Navigator.of(context).pop(null);
                              },
                              icon: Container(
                                width: 25,
                                height: 25,
                                padding: EdgeInsets.all(2.5),
                                child: Image.asset("assets/images/${Platform.isIOS ? "left-arrow-ios" : "left-arrow"}.png",color: kPrimaryColor,),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Image.asset("assets/images/closed.png"),
                            ),
                          )
                        ],
                      )
                    ),
//                    SafeArea(
//                      child:
//                    ),
                  ],
                ),
              )
//                color: Colors.white30,
            ),
            _isLoading ? MyWidgets().loader() : Container()
          ],
        ),
      ),
    );
  }
//  Row schedView() => Row(
//    children: <Widget>[
//      schedBox("${scheduleListener.strToTime(widget.data['schedule']['sun'].toString(), 0)}", "${scheduleListener.strToTime(widget.data['schedule']['sun'].toString(), 1)}", "Sunday"),
//      schedBox("${scheduleListener.strToTime(widget.data['schedule']['mon'].toString(), 0)}", "${scheduleListener.strToTime(widget.data['schedule']['mon'].toString(), 1)}", "Monday"),
//      schedBox("${scheduleListener.strToTime(widget.data['schedule']['tue'].toString(), 0)}", "${scheduleListener.strToTime(widget.data['schedule']['tue'].toString(), 1)}", "Tuesday"),
//      schedBox("${scheduleListener.strToTime(widget.data['schedule']['wed'].toString(), 0)}", "${scheduleListener.strToTime(widget.data['schedule']['wed'].toString(), 1)}", "Wednesday"),
//      schedBox("${scheduleListener.strToTime(widget.data['schedule']['thu'].toString(), 0)}", "${scheduleListener.strToTime(widget.data['schedule']['thu'].toString(), 1)}", "Thursday"),
//      schedBox("${scheduleListener.strToTime(widget.data['schedule']['fri'].toString(), 0)}", "${scheduleListener.strToTime(widget.data['schedule']['fri'].toString(), 1)}", "Friday"),
//      schedBox("${scheduleListener.strToTime(widget.data['schedule']['sat'].toString(), 0)}", "${scheduleListener.strToTime(widget.data['schedule']['sat'].toString(), 1)}", "Saturday"),
//    ],
//  );
  Widget schedBox(String openTime, String closeTime, String day) =>Container(
    width: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 12),
    height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 12),
    margin: const EdgeInsets.only(left: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(7.0)
    ),
    child: Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: scrh > 700 ? 5 : 5),
//          height: Percentage().calculate(num: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 12), percent: 20),
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(7))
          ),
          child: Text("$day".toUpperCase().substring(0,3),style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),textAlign: TextAlign.center,),
        ),
        if(openTime != "null" || closeTime != "null")...{
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    child: Text("From:",style: TextStyle(
                        fontSize: Percentage().calculate(num: scrw,percent: 2.5),
                        color: Colors.black54,
                        fontWeight: FontWeight.w600
                    ),),
                  ),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text("${DateFormat().add_jm().format(DateTime.parse("${DateTime.now().toString().split(' ')[0]} $openTime"))}",textAlign: TextAlign.left,),
                    ),
                  )
                ],
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    child: Text("To:",style: TextStyle(
                        fontSize: Percentage().calculate(num: scrw,percent: 2.5),
                        color: Colors.black54,
                        fontWeight: FontWeight.w600
                    ),),
                  ),
                  Expanded(
                    child: FittedBox(
                      child: Text("${DateFormat().add_jm().format(DateTime.parse("${DateTime.now().toString().split(' ')[0]} $closeTime"))}"),
                    ),
                  )
                ],
              ),
            ),
          )
        }else...{
          Expanded(
            child: Center(
              child: Text("Unavailable"),
            ),
          )
        }
      ],
    ),
  );
}

