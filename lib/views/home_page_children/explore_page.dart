import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:ekaon/global/constant.dart';
import 'package:ekaon/global/custom_app_bar.dart';
import 'package:ekaon/global/data_container.dart';
import 'package:ekaon/global/interrupts.dart';
import 'package:ekaon/global/user_data.dart';
import 'package:ekaon/global/variables.dart';
import 'package:ekaon/global/widget.dart';
import 'package:ekaon/services/ad.dart';
import 'package:ekaon/services/cart.dart';
import 'package:ekaon/services/category.dart';
import 'package:ekaon/services/percentage.dart';
import 'package:ekaon/services/products.dart';
import 'package:ekaon/services/store.dart';
import 'package:ekaon/services/string_formatter.dart';
import 'package:ekaon/views/home_page.dart';
import 'package:ekaon/views/home_page_children/not_navbar/store_details.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ExplorePage extends StatefulWidget {
  final BuildContext context;
  ExplorePage({Key key, this.context}) : super(key : key);
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with SingleTickerProviderStateMixin {
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  GlobalKey<ScaffoldState> _key = new GlobalKey();
  int currentPageIndex = 0;
  bool _isKeyboardActive = false;
  final _ads = AdmobService();

  InterstitialAd _interstitialAd;
  BannerAd _bannerAd;
  RewardedVideoAd _rewardedVideoAd;


  List _displayData;
  int chosenCatInt;
  bool _isLoading = false;
  Future _getStores() async {
    await Store().get(page: page).then((value) async {
      if (value != null) {
        try{
          setState(() {
            storeDetails = value;
            displayData = value['data'];
            _displayData = value['data'];
          });
        }catch(e){
          print(e);
        }
      }else{
        setState(() {
          displayData = [];
          _displayData = [];
        });
      }
      await _getFeaturedProducts();
      await _getCategories();
    });
  }
  Future<List> _newDisplay() async {
    List _store = [];
    for(var data in displayData){
      for(var catData in data['categories'])
      {
        if(catData['id'] == chosenCatInt){
          _store.add(data);
        }
      }
    }
    return _store;
  }
  void _animateSlider() {
    if(this.mounted && featuredProducts != null && featuredProducts.length > 0){
      Future.delayed(Duration(seconds: 3)).then((_) {
        int nextPage = _pageController.page.round() + 1;
        if(nextPage == featuredProducts.length) {
          Future.delayed(Duration(seconds: 3));
          nextPage = 0;
        }
        setState(() {
          currentPageIndex = nextPage;
        });
        _pageController.animateToPage(nextPage, duration: Duration(seconds: 1), curve: Curves.linear).then((_) => _animateSlider());
      });
    }
  }
  Future _getFeaturedProducts() async {
    await ProductAuth().getFeatured().then((value) {
      if(value != null){
        setState(() {
          featuredProducts = value;
        });
        if(featuredProducts.length > 0){
          WidgetsBinding.instance.addPostFrameCallback((_) => _animateSlider());
        }
      }
    });
  }
  Future _getCategories() async {
    await Categories().get().then((value) {
      if(value != null){
        setState(() {
          localCategories = value;
        });
      }
    });
  }
  _initializeFetch({bool isPulled = false}) async {
    if(isPulled){
      await _getStores();
      _refreshController.refreshCompleted();
    }else{
      if(displayData == null){
        await _getStores();
      }else{
        setState(() {
          _displayData = displayData;
        });
      }
    }
  }

  StreamSubscription sub;
  @override
  void initState() {
    // TODO: implement initState
//    try{
////      FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
////      _bannerAd = _ads.createBannerAd()..load()..show(
////        anchorOffset: 65,
////      );
////      _interstitialAd = _ads.createInterstitialAd()..load()..show();
////      RewardedVideoAd.instance.listener =
////          (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
////        print("RewardedVideoAd event $event");
////        if (event == RewardedVideoAdEvent.rewarded) {
////        }
////      };
//    }catch(e){
//      print("AD ERROR : $e");
//    }
    super.initState();
    if(this.mounted) {
      setState(() {
        sub = KeyboardVisibility.onChange.listen((event) {
            _isKeyboardActive = event;
        });
      });
      _initializeFetch();
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
    sub.cancel();
  }
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
      onWillPop: () => Interrupts().showAppExit(context),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Scaffold(
              body: Container(
                width: double.infinity,
                height: Platform.isAndroid ? _isKeyboardActive ? Percentage().calculate(num: scrh, percent: 55) : scrh : scrh,
                child: SafeArea(
                  child: SmartRefresher(
//                enablePullUp: true,
                    enablePullDown: true,
                    controller: _refreshController,
                    header: MaterialClassicHeader(
                      color: kPrimaryColor,
                      backgroundColor: Colors.white,
                    ),
                    onRefresh: (){
                      setState(() {
                        chosenCatInt = null;
                      });
                      _initializeFetch(isPulled: true);
                    },
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          automaticallyImplyLeading: false,
                          backgroundColor: Colors.white,
                          elevation: 0,
                          expandedHeight: 60,
                          collapsedHeight: 10,
                          toolbarHeight: 0,
                          pinned: false,
                          snap: false,
                          floating: true,
                          flexibleSpace: CustomizedWidgets(key: _key, fromStore: true, toSearch: _displayData).Appbar(context),
                        ),
                        SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              AnimatedContainer(
                                margin: EdgeInsets.only(bottom: featuredProducts == null || featuredProducts.length == 0 ? 60 : 10),
                                width: double.infinity,
                                height: featuredProducts == null || featuredProducts.length == 0 ? 0 : Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 30),
                                color: Colors.grey[200],
                                child: featuredProducts == null ? Center(
                                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(kPrimaryColor),),
                                ) : Stack(
                                  alignment: AlignmentDirectional.bottomEnd,
                                  children: <Widget>[
                                    Container(
                                      child: PageView(
                                        onPageChanged: (index)=> setState(()=> currentPageIndex = index),
                                        controller: _pageController,
                                        children: <Widget>[
                                          for(var featured in featuredProducts)...{
                                            AnimatedContainer(
                                              width: double.infinity,
                                              height: featuredProducts == null || featuredProducts.length == 0 ? 0 : Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 30),
                                              duration: Duration(milliseconds: 600),
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: featured['images'].length > 0 ? NetworkImage("https://ekaon.checkmy.dev${featured['images'][0]['url']}") : AssetImage("assets/images/no-image-available.png")
                                                  )
                                              ),
                                              child: Column(
                                                children: <Widget>[
                                                  Spacer(),
                                                  ListTile(
                                                    title: Text("${featured['name']}",style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 17
                                                    ),),
                                                    subtitle: Text("${featured['description']}",style: TextStyle(
                                                      color: Colors.white70,
                                                    ),),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                                    width: double.infinity,
                                                    height : 45,
                                                    child: Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: kPrimaryColor,
                                                                borderRadius: BorderRadius.circular(2.5)
                                                            ),
                                                            child: FlatButton(
                                                              onPressed: (){
                                                                Navigator.push(context, PageTransition(child: StoreDetailsPage(data: featured['store_details']), type: PageTransitionType.leftToRightWithFade));
                                                              },
                                                              child: Center(
                                                                child: Text("View store",style: TextStyle(
                                                                    color: Colors.white
                                                                ),),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 20,
                                                        ),
                                                        Expanded(
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors.grey[900],
                                                                borderRadius: BorderRadius.circular(2.5)
                                                            ),
                                                            child: FlatButton(
                                                              onPressed: (){
                                                                if(user_details != null){
                                                                  if(featured['store_details']['owner']['id'] == user_details.id) {
                                                                    Fluttertoast.showToast(msg: "You can't order your own product");
                                                                  }else {
                                                              HomePage().loader(widget.context, true);
                                                                    Map _data;
                                                                    setState(() {
                                                                      _data = featured;
                                                                      _data['quantity'] = 1;
                                                                      _data['sub_total'] = double.parse((1 * featured['price']).toString());
                                                                    });
                                                                    String var_ids;

                                                                    if(_data['variations'] != null && _data['variations'].length > 0){
                                                                      List vars = [];
                                                                      for(var variation in _data['variations']){
                                                                        vars.add(variation['default_variation_id']);
                                                                      }
                                                                      var_ids = vars.join(',');
                                                                    }
                                                                    print(_data);

                                                              cartAuth.addToCart(product: _data, variationIds: var_ids).whenComplete(() => HomePage().loader(widget.context, false));
//                                                          if(cartAuth.checkStore(storeId: featured['store_details']['id'])){
//
//                                                            if(cartAuth.checkProduct(data: _data, storeId: featured['store_details']['id'])){
//                                                              //update quantity x total
//                                                              cartAuth.updateProduct(store_id: featured['store_details']['id'], data: _data);
//                                                            }else{
//                                                              //append product to store
//                                                              print("WARA AN PRODUCT");
//                                                              cartAuth.appendProduct(data: featured,storeId: featured['store_details']['id'], quantity: 1, total: double.parse((1 * featured['price']).toString()));
//                                                            }
//                                                          }else{
////                                                        setState(() {
////                                                          _isLoading = true;
////                                                        });
//                                                            cartAuth.add(storeId: featured['store_details']['id'], productId: featured['id'], quantity: 1, total: double.parse((1 * featured['price']).toString()));
//                                                          }
                                                                  }
                                                                }else{
                                                                  Fluttertoast.showToast(msg: "You are a guest user, please login");
                                                                }
                                                              },
                                                              child: Center(
                                                                child: Text("Add to cart",style: TextStyle(
                                                                    color: Colors.white
                                                                ),),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 40,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          }
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 20,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          for(var x =0;x< featuredProducts.length;x++)...{
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                  color: currentPageIndex == x ? Colors.white : Colors.white54,
                                                  borderRadius: BorderRadius.circular(100)
                                              ),
                                              margin: const EdgeInsets.only(left: 10),
                                            )
                                          }
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                duration: Duration(milliseconds: 500),
                              ),
                              AdmobBanner(adUnitId: _ads.getBannerAdId2(), adSize: AdmobBannerSize.FULL_BANNER),
                              Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(left: 20,top: 10),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text("Categories",style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold
                                        ),),
                                      ),
                                    ],
                                  )
                              ),
                              if(localCategories == null)...{
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
                                Container(
                                  width: double.infinity,
                                  height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 15),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: localCategories.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () async {
                                          if(chosenCatInt == localCategories[index]['id']){
                                            setState(() {
                                              chosenCatInt = null;
                                              _displayData = displayData;
                                            });
                                          }else{
                                            setState(() {
                                              chosenCatInt = localCategories[index]['id'];
                                            });
                                            var data = await this._newDisplay();
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
                                                color: this.chosenCatInt == localCategories[index]['id'] ? Colors.grey[300] : Colors.transparent,
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
                                                          image: localCategories[index]['image_url'] != null ? NetworkImage("https://ekaon.checkmy.dev${localCategories[index]['image_url']}") : AssetImage("assets/images/no-image-available.png")
                                                      )
                                                  ),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  child: Text("${StringFormatter(string: localCategories[index]['name']).titlize()}",textAlign: TextAlign.center,style: TextStyle(
                                                      fontSize: Percentage().calculate(num: MediaQuery.of(context).size.width,percent: 3),
                                                      fontWeight: FontWeight.w600
                                                  ),),
                                                )
                                              ],
                                            )
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                AdmobBanner(adUnitId: _ads.getBannerAdId(), adSize: AdmobBannerSize.FULL_BANNER),
                              },
                              if(_displayData != null)...{
                                if(_displayData.length > 0)...{
                                  _storeList(),
                                }else...{
                                  SizedBox(
                                    height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 5),
                                  ),
                                  Center(
                                    child: Image.asset("assets/images/store-not-found.png"),
                                  )
                                }
                              }else...{
                                SizedBox(
                                  height: Percentage().calculate(num: MediaQuery.of(context).size.height,percent: 30),
                                ),
                                Center(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(kPrimaryColor),
                                  ),
                                ),
                              },
                            ]
                          ),
                        )
                      ],
                    )
                  ),
                ),
              ),
            ),
            _isLoading ? MyWidgets().loader() : Container()
          ],
        ),
      ),
    );
  }

  Widget _storeList() {
    return ListView.builder(

      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
      itemCount: _displayData.length,
      itemBuilder: (context, index) => _storeCard(
          data: _displayData[index]
      )
    );
  }

  Widget _storeCard({Map data}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, PageTransition(child: StoreDetailsPage(data: data), type: PageTransitionType.leftToRightWithFade)),
      child: Card(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(5),
              width: scrw,
              height:
                  scrw > 700 ? scrw / 2 : scrh > 700 ? scrh / 4.5 : scrh / 3.5,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: data['picture'] != null
                          ? NetworkImage("https://ekaon.checkmy.dev" + data['picture'])
                          : AssetImage('assets/images/default_store.png'),
                      fit: BoxFit.cover)),
            ),
            Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                  text: "${data['name']
                            .toString()[0]
                            .toUpperCase() +
                                      data['name']
                                .toString()
                                .substring(1)}\n",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: scrw > 700
                                      ? scrw / 35
                                      : scrw / 25,
                                    color: kPrimaryColor
                                  )),
                              TextSpan(text: 'Starting price: ₱ ${data['minPrice'] == null ? 0 : double.parse(data['minPrice'].toString()).toStringAsFixed(2)}'),
                            ]),
                      ),
                    ),
                    Icon(Icons.thumb_up, color: Colors.grey,),
                    Text(" ${data['total_likes'] != null ? data['total_likes'] : "0"}  ",style: TextStyle(
                      fontSize: scrw > 700
                          ? scrw / 35
                          : scrw / 25
                    ),),
                    Icon(Icons.thumb_down,color: Colors.grey,),
                    Text(" ${data['total_dislikes'] != null ? data['total_dislikes'] : "0"}",style: TextStyle(
                        fontSize: scrw > 700
                            ? scrw / 35
                            : scrw / 25
                    ),)
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}
