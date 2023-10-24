import 'dart:io';

import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'app_config.dart';

class AdManager {
  static int numberOfClicks = 0;
  static int interstitialAdInterval = 3;
  static bool interstitialAdLoaded = false;

  /*static String fbInterstitialPlacementId = '2244587745860156_2351931271792469';
  //need a facebook native ad placement id
  //static String fbNativePlacementId = '385157572510735_521283342231490';
  static String fbNativePlacementId = '1962039007276579_1962039907276489';*/

  static String fbInterstitialPlacementId = AppConfig.fbNative;

  //need a facebook native ad placement id
  //static String fbNativePlacementId = '385157572510735_521283342231490';
  static String fbNativePlacementId = AppConfig.fbNative;

  static String appId = AppConfig.adAppId;
  static String nativeAdId =
      Platform.isAndroid ? AppConfig.adNative : AppConfig.adIosNative;

  //static String adMobBanner = 'ca-app-pub-3940256099942544/6300978111';
  static String adMobNativeAdUnit = AppConfig.adNative;

  // static String appId = 'ca-app-pub-9259101471660565~4568491044';
  // static String nativeAdId = 'ca-app-pub-9259101471660565/8555196884';
  // static String adMobBanner = 'ca-app-pub-6370111532336036~5661435384';
  // static String adMobBannerAdUnit = 'ca-app-pub-6370111532336036/4512005249';
  // static String adMobInterstitialAdUnit =
  //     'ca-app-pub-6370111532336036/7079943350';

  /* static String appId = Platform.isAndroid
      ? 'ca-app-pub-4063523331079688~9972492391'
      : 'ca-app-pub-4063523331079688~3175983907';
  static String nativeAdId = Platform.isAndroid
      ? 'ca-app-pub-4063523331079688/6043666306'
      : 'ca-app-pub-4063523331079688/8602381039';
  static String adMobBanner = 'ca-app-pub-3940256099942544/6300978111';
  static String adMobNativeAdUnit =
       Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';*/
  static String adMobInterstitialAdUnit =
      'ca-app-pub-3940256099942544/1033173712';

  static void loadInterstitialAd() {
    FacebookInterstitialAd.loadInterstitialAd(
      placementId: fbInterstitialPlacementId,
      listener: (result, value) async {
        if (result == InterstitialAdResult.LOADED) {
          print('INTERStiiiiiiiiiiilailtjadl AAAAAAAaDDDDDDDD');
          interstitialAdLoaded = true;
          await FacebookInterstitialAd.showInterstitialAd(delay: 5000);
        }
        if (result == InterstitialAdResult.DISMISSED &&
            value['invalidated'] == true) {
          interstitialAdLoaded = false;
          loadInterstitialAd();
        }
      },
    );
  }

  static void showInterstitialAd() {
    numberOfClicks++;
    print('Number of clicks =>>>>>>>>>>>>>> $numberOfClicks');
    if (numberOfClicks > interstitialAdInterval) {
      if (interstitialAdLoaded) {
        FacebookInterstitialAd.showInterstitialAd();
        numberOfClicks = 0;
      } else {
        Fluttertoast.showToast(
          msg: 'The interstitial ad is not loaded',
        );
      }
    }
  }

// static NativeAd nativeAdsView() => NativeAd(
//   height: 320,
//   unitId: AdManager.adMobNativeAdUnit,
//   builder: (context, child) {
//     return Material(
//       elevation: 1,
//       child: child,
//     );
//   },
//   buildLayout: mediumAdTemplateLayoutBuilder,
//   // buildLayout: fullBuilder,
//   loading: Text('loading'),
//   error: Text('error'),
//   icon: AdImageView(size: 40),
//   headline: AdTextView(
//     style: TextStyle(
//       fontSize: 16,
//       fontWeight: FontWeight.bold,
//       color: Colors.black,
//     ),
//     maxLines: 1,
//   ),
//   body: AdTextView(style: TextStyle(color: Colors.black), maxLines: 1),
//   media: AdMediaView(
//     height: 170,
//     width: MATCH_PARENT,
//   ),
//   attribution: AdTextView(
//     width: WRAP_CONTENT,
//     text: 'Ad',
//     decoration: AdDecoration(
//       border: BorderSide(color: Colors.green, width: 2),
//       borderRadius: AdBorderRadius.all(16.0),
//     ),
//     style: TextStyle(color: Colors.green),
//     padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
//   ),
//   button: AdButtonView(
//     elevation: 18,
//     decoration: AdDecoration(backgroundColor: Colors.blue),
//     height: MATCH_PARENT,
//     textStyle: TextStyle(color: Colors.white),
//   ),
//   ratingBar: AdRatingBarView(starsColor: Colors.white),
// );

}
