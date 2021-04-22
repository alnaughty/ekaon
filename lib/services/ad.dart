import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';

class AdmobService {

  createBannerWidget() {

  }
  String getAdMobAppId(){
    if(Platform.isIOS){
      return 'ca-app-pub-3073110604164690~2088464336';
    }else if (Platform.isAndroid){
      return 'ca-app-pub-3073110604164690~9997925702';
    }
    return null;
  }
  String getStoreBannerAdId() {
    if(Platform.isIOS){
      return 'ca-app-pub-3073110604164690/1599580997';
    }else if (Platform.isAndroid){
      return 'ca-app-pub-3073110604164690/5721824680';
    }
    return null;
  }
  String getBannerAdId2() {
    if(Platform.isIOS){
      return 'ca-app-pub-3073110604164690/1491769785';
    }else if (Platform.isAndroid){
      return 'ca-app-pub-3073110604164690/4569165746';
    }
    return null;
  }
  String getBannerAdId(){
    if(Platform.isIOS){
      return 'ca-app-pub-3073110604164690/9082082241';
    }else if (Platform.isAndroid){
      return 'ca-app-pub-3073110604164690/3829771472';
    }
    return null;
  }
  String getRewardBasedVideoAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-3073110604164690/2325102205';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    }
    return null;
  }
  String getInterAdId() {
    if(Platform.isIOS){
      return "ca-app-pub-3073110604164690/8343731559";
    }else if(Platform.isAndroid){
      return "ca-app-pub-3073110604164690/6264363128";
    }
    return null;
  }
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['Game', 'Food'],
//    contentUrl: 'http://foo.com/bar.html',
    childDirected: true,
    nonPersonalizedAds: true,
  );
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: this.getBannerAdId(),
      size: AdSize.banner,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }
  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: this.getInterAdId(),
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
      },
    );
  }
}