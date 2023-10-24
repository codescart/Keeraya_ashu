import 'package:html_unescape/html_unescape.dart';

import './api_helper.dart';
import '../models/language.dart';

class AppConfig {
  // ignore: non_constant_identifier_names
  static int FCM_COUNT = 10;

  // ignore: non_constant_identifier_names
  static String FCM_ID = "";

  // ignore: non_constant_identifier_names
  static String APP_VERION = "1.0";

  //* revenueCat Configuration
  static String revenueCatApiKey = 'appl_gnjinxKOPLOznzAIMginlaEWDuC';
  static String revenueCatProductIdentifier = 'Upgrade to Premium';
  static String upgradeToPremiumPlan = 'Upgrade_To_Premium_Professional';
  static String upgradeToBasicPlan = 'Upgrade_To_Premium_Basic';
  static String addFeaturedToAd = 'communilifer_premium_feature';
  static String addUrgentToAd = 'communilifer_premium_urgent';
  static String addHighlightedToAd = 'communilifer_premium_highlight';

  //? terms of use and privacy policy
  static String termsOfUse = 'Terms of Use (EULA)';
  static String termsOfUseURL =
      'https://keeraya.com/page/term-condition';
  static String privacyPolicy = 'Privacy Policy';
  static String privacyPolicyURL =
      'https://keeraya.com/page/privacy-policy';

  static String appName;
  static bool disableAdSocial;
  static bool disableFbSocial;
  static String appVersion;
  static String defaultCountry;
  static String defaultLangCode;
  static String defaultLanguage;
  static String termsPageLink;
  static String policyPageLink;
  static String featuredFee;
  static String urgentFee;
  static String highlightFee;
  static String currencyCode;
  static String currencySign;
  static bool isPremium;
  static String paypalClientId = '';
  static String paypalSecret = '';
  static String paypalUsername = '';
  static String paypalPassword = '';
  static bool paypalSandboxMode = true;
  static String payUMoneyMerchantKey = '';
  static String payUMoneyMerchantId = '';
  static String payUMoneyMerchantSalt = '';
  static bool payUMoneySandboxMode = true;
  static String payUMoneyAuthHeader = '';
  static String paystackPublicKey = '';
  static String paystackSecretKey = '';
  static String flutterwavePublicKey = '';
  static String flutterwaveEncKey = '';
  static bool flutterwaveStagingMode = false;

  static String razorpayKey = '';
  static bool paypalOn = true;
  static bool payStackOn = true;
  static bool payUMoneyOn = true;
  static bool razorpayOn = true;
  static bool flutterwaveOn = true;
  static List<Language> languages = [];
  static int interstitialAdInterval = 6;
  static int numberOfClicks = 0;
  static bool googleBannerOn = true;
  static bool googleInterstitialOn = false;
  static String adNative;
  static String adAppId;
  static String fbNative;
  static String adIosNative;
  static String adCountryName;

  static Future initialize() async {
    final apiHelper = APIHelper();
    final decodedData = await apiHelper.fetchAppConfiguration(langCode: 'en');
    final paymentInfo = await apiHelper.fetchPaymentVendorCredentials();
    final unescape = HtmlUnescape();

    paypalClientId = paymentInfo['paypal_client_id'];
    paypalSecret = paymentInfo['paypal_api_signature'];
    paypalUsername = paymentInfo['paypal_api_username'];
    paypalPassword = paymentInfo['paypal_api_password'];
    paypalSandboxMode =
        paymentInfo['paypal_sandbox_mode'] == 'Yes' ? true : false;
    payUMoneyMerchantId = paymentInfo['payumoney_merchant_id'];
    payUMoneyMerchantKey = paymentInfo['payumoney_merchant_key'];
    payUMoneyMerchantSalt = paymentInfo['payumoney_merchant_salt'];
    payUMoneySandboxMode =
        paymentInfo['payumoney_sandbox_mode'] == 'test' ? true : false;
    payUMoneyAuthHeader = paymentInfo['payumoney_authheader_id'];

    paystackPublicKey = paymentInfo['paystack_public_key'];
    paystackSecretKey = paymentInfo['paystack_secret_key'];
    paypalOn = decodedData['payment_method']['paypal'] == '1' ? true : false;
    payStackOn =
        decodedData['payment_method']['paystack'] == '1' ? true : false;
    payUMoneyOn =
        decodedData['payment_method']['payumoney'] == '1' ? true : false;
    razorpayOn =
        decodedData['payment_method']['razorpay'] == '1' ? true : false;
    flutterwaveOn =
        decodedData['payment_method']['flutterwave'] == '1' ? true : false;
    razorpayKey = paymentInfo['razorpay_key'];
    flutterwavePublicKey = paymentInfo['flutterwave_public_key'];
    flutterwaveEncKey = paymentInfo['flutterwave_enc_key'];
    flutterwaveStagingMode =
        paymentInfo['flutterwave_staging_mode'] == 'Yes' ? true : false;
    googleBannerOn = decodedData['google_banner'];
    googleInterstitialOn = decodedData['google_interstitial'];

    appName = decodedData['app_name'];
    appVersion = decodedData['app_version'];
    defaultCountry = decodedData['default_country'];
    defaultLangCode = decodedData['default_lang_code'];
    defaultLanguage = decodedData['default_lang'];
    termsPageLink = decodedData['terms_page_link'];
    policyPageLink = decodedData['policy_page_link'];
    featuredFee = decodedData['featured_fee'];
    urgentFee = decodedData['urgent_fee'];
    highlightFee = decodedData['highlight_fee'];
    currencyCode = decodedData['currency_code'];
    currencySign = unescape.convert(decodedData['currency_sign']);
    isPremium = decodedData['premium_app'];
    disableAdSocial = decodedData['disable_ad_social'];
    disableFbSocial = decodedData['disable_fb_social'];
    adNative = decodedData['ad_native'];
    adAppId = decodedData['ad_appid'];
    fbNative = decodedData['fb_native'];
    adIosNative = decodedData['ad_ios_native'];
    adCountryName = decodedData['ad_country_name'];
    // isPremium = false;
    for (int i = 0; i < decodedData['languages'].length; i++) {
      languages.add(Language(
        id: decodedData['languages'][i]['id'],
        code: decodedData['languages'][i]['code'],
        direction: decodedData['languages'][i]['direction'],
        name: decodedData['languages'][i]['name'],
        fileName: decodedData['languages'][i]['file_name'],
        isActive: decodedData['languages'][i]['active'] == '1' ? true : false,
        isDefault: decodedData['languages'][i]['default'] == '1' ? true : false,
      ));
    }
  }
}
