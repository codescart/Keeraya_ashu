import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './current_user.dart';
import './db_helper.dart';
import '../helpers/app_config.dart';
import '../models/city.dart';
import '../models/location.dart';
import '../models/membership_plan.dart';
import '../models/product.dart';
import '../models/state.dart';


// https://keeraya.com/api/v1/index.php?action=register


class APIHelper extends ChangeNotifier {
  static const DETAIL_ACTIVITY_PARCELABLE = "DETAIL_ACTIVITY_PARCELABLE";
  static const BUNDLE = "bundle";
  static const BASE_URL = "keeraya.com"; // Put Your Base Url here.
  static const REGISTER_URL = "register";
  static const LOGIN_URL = "login";
  static const FORGOT_PASSWORD_URL = "forgot_password";
  static const PRODUCT_LIST_URL = "home_latest_ads";
  static const UNENCODED_PATH = 'api/v1/index.php';
  static const RELATED_ADS_URL = "related_ads";
  static const DELETE_ADS_URL = "ad_delete";
  static const SEARCH_CITY_URL = "searchCity";
  static const MY_PRODUCT_LIST_URL = "home_latest_ads";
  static const FEATURED_URGENT_LIST_URL = "featured_urgent_ads";
  static const SEARCH_LIST_URL = "search_post";
  static const PRODUCT_DETAIL_URL = "ad_detail";
  static const COUNTRY_DETAIL_URL = "installed_countries";
  static const CUSTOM_DATA_URL = "ad_custom_data";
  static const STATE_DETAIL_URL = "getStateByCountryCode";
  static const CITY_DETAIL_URL = "getCityByStateCode";
  static const TRANSACTION_DETAIL_URL = "userTransactions";
  static const PAY_U_HASH_URL = "api/v1/moneyhash.php";
  static const IMAGE_URL = BASE_URL + "/storage/profile/";
  static const IMAGE_URL_SMALL = BASE_URL + "storage/profile/small_";
  static const PRODUCT_IMAGE_URL = BASE_URL + "storage/products/";
  static const APP_CONFIG_URL = "app_config";
  static const FETCH_CHAT_URL = "get_all_msg";
  static const MAKE_AN_OFFER = "make_offer";
  static const FETCH_GROUP_CHAT_URL = "chat_conversation";
  static const FETCH_LANGUAGE_PACK_URL = "language_file";
  static const GET_CUSTOM_DATA_BY_CATEGORY = 'custom_fields_json';
  static const SEND_CHAT_URL = "send_message";
  static const GET_NOTIFICATION_MESSAGE_URL = "get_notification";
  static const ADD_FIREBASE_DEVICE_TOKEN_URL = "add_firebase_device_token";
  static const UPLOAD_PROFILE_PIC_URL = "upload_profile_picture";
  static const UPLOAD_PRODUCT_PIC_URL = "upload_product_picture";
  static const UPLOAD_PRODUCT_SAVE_POST_URL = "save_post";
  static const UPLOAD_PRODUCT_UPDATE_POST_URL = "update_post";
  static const UPLOAD_PRODUCT_PREMIUM_TRANSACTION_URL =
      "payment_success_saving";
  static const GET_UNREAD_MESSAGE_COUNT_URL = "unread_note_chat_count";
  static const GET_GADS_FBADS_URL = "get_ads_options";
  static const GET_TRANSACTION_VENDOR_CRED_URL = "payment_api_detail_config";
  static const GET_MEMBERSHIP_PLAN_URL = "get_membership_plan";
  static const GET_USER_MEMBERSHIP_PLAN_URL = "get_userMembership_by_id";
  static const UPLOAD_PRODUCT_ADDITIONAL_INFO_URL =
      BASE_URL + "getCustomFieldByCatID&catid=%s&subcatid=%s&additionalinfo=%s";
  static const MEMBERSHIP_URL =
      BASE_URL + "membership/changeplan?username=%s&password=%s&isApp=%s";
  static const FLAG_IMAGE_URL = "https://www.countryflags.io/%s/flat/64.png";
  static const IS_ADMIN_APP = false;
  static const IS_APP_CONFIG_RELOAD_REQUIRED =
      true; // UPDATE IT TO FALSE IF YOU DON'T WANT TO RELOAD YOUR CATEGORIES EVERY LAUNCH
  static var CURRENT_VERSION = "1.0";
  static const CURRENCY_IN_LEFT = "1";
  static const PREF_FILE = "cander";
  static const SUPPORT_EMAIL =
      "support@canders.in"; // Put your Support Email Here
  static const PRODUCT_LOADING_LIMIT = "16";
  static const PRODUCT_LOADING_OFFSET = 8;
  static const PRODUCT_STATUS = "active";

  Future registerUser(
      {@required name,
      @required email,
      username = '',
      password = '',
      fbLogin = false}) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': REGISTER_URL,
    });
    print(url);
    print("aaaaaaaa");
    final response = await http.post(url, body: {
      'name': name,
      'email': email,
      'username': username,
      'password': password,
      'fb_login': fbLogin ? '1' : '0',
    });
    print("register fb : ${response.body}");
    if (response.statusCode == 200) {
    } else {
      throw Exception('Error while registering');
    }
  }
//keeraya.com/
  Future autoLoginUser({
    @required name,
    @required email,
    username = '',
    password = '',
    fbLogin = false,
    fbPicture = '',
  }) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': REGISTER_URL,
    });
    final response = await http.post(url, body: {
      'name': name,
      'email': email,
      'username': username,
      'password': password,
      'fb_login': '1',
    });
    print("register fb : ${response.body}");
    if (response.statusCode == 200) {
      final decodedResponse = await json.decode(response.body);
      CurrentUser.id = decodedResponse['user_id'];
      CurrentUser.name = decodedResponse['name'];
      CurrentUser.email = decodedResponse['email'];
      CurrentUser.username = decodedResponse['username'];

      CurrentUser.picture = fbPicture;

      CurrentUser.isLoggedIn = true;

      await DBHelper.delete('user_info');
      await DBHelper.insert('user_info', {
        'id': CurrentUser.id,
        'isLoggedIn': '1',
        'username': CurrentUser.username,
        'name': CurrentUser.name,
        'email': CurrentUser.email,
        'picture': CurrentUser.picture,
      });
    } else {
      throw Exception('Error while registering');
    }
  }

  Future loginUserUsingUsername({
    @required username,
    @required password,
    fbLogin = false,
    fbPicture = '',
  }) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': LOGIN_URL,
      'username': username,
      'password': password,
      'fb_login': fbLogin ? '1' : '0',
    });
    final response = await http.get(url);
    print("login fb : ${response.body}");
    if (response.statusCode == 200) {
      final decodedResponse = await json.decode(response.body);
      if (decodedResponse['status'] == 'success') {
        CurrentUser.id = decodedResponse['user_id'];
        CurrentUser.name = decodedResponse['name'];
        CurrentUser.email = decodedResponse['email'];
        CurrentUser.username = decodedResponse['username'];
        if (!fbLogin) {
          CurrentUser.picture = decodedResponse['picture'];
        } else {
          CurrentUser.picture = fbPicture;
        }
        CurrentUser.isLoggedIn = true;

        await DBHelper.delete('user_info');
        await DBHelper.insert('user_info', {
          'id': CurrentUser.id,
          'isLoggedIn': '1',
          'username': CurrentUser.username,
          'name': CurrentUser.name,
          'email': CurrentUser.email,
          'picture': CurrentUser.picture,
        });
      }
    } else {
      throw Exception('Error');
    }
  }

  Future loginUserUsingEmail(
      {@required email, password = '', fbLogin = false}) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': LOGIN_URL,
      'email': email,
      'password': password,
      'fb_login': fbLogin ? '1' : '0',
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedResponse = await json.decode(response.body);
      if (decodedResponse['status'] == 'success') {
        CurrentUser.id = decodedResponse['user_id'];
        CurrentUser.name = decodedResponse['name'];
        CurrentUser.email = decodedResponse['email'];
        CurrentUser.username = decodedResponse['username'];
        CurrentUser.picture = decodedResponse['picture'];
        CurrentUser.isLoggedIn = true;

        await DBHelper.delete('user_info');
        await DBHelper.insert('user_info', {
          'id': CurrentUser.id,
          'isLoggedIn': '1',
          'username': CurrentUser.username,
          'name': CurrentUser.name,
          'email': CurrentUser.email,
          'picture': CurrentUser.picture,
        });
      }
    } else {
      throw Exception('Error');
    }
  }

  Future logout() async {
    await DBHelper.delete('user_info');
    CurrentUser.id = '';
    CurrentUser.name = '';
    CurrentUser.email = '';
    CurrentUser.username = '';
    CurrentUser.picture = '';
    CurrentUser.isLoggedIn = false;
    CurrentUser.location = Location();
  }

  Future getUserData({@required userId}) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': 'get_user_data',
      'user_id': userId,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }
  }

  Future forgetPassword({@required email}) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': FORGOT_PASSWORD_URL,
      'email': email,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }
  }

  Future getUserTransactions({@required String userId}) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': TRANSACTION_DETAIL_URL,
      'sellerid': userId,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      return decodedData;
    } else {
      throw Exception('Error');
    }
  }

  // Find out what the parameters do
  Future fetchProducts({status, countryCode, state, city, page, limit}) async {
    final String url =
        'https://$BASE_URL/$UNENCODED_PATH?action=$PRODUCT_LIST_URL&status=active&country_code=$countryCode&state=$state&city=$city&page=$page&limit=$limit';
    print(url);
    final client = new http.Client();
    final response = await client.get(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );

    final decodeData = json.decode(response.body);

    print("Fetch Products");
    print(decodeData);
    List<Product> products = [];

    for (int i = 0; i < decodeData.length; i++) {
      try {
        products.add(Product.fromJson(decodeData[i]));
      } catch (e) {
        print(e);
      }
    }
    return products;
    /* final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': PRODUCT_LIST_URL,
      'status': status,
      'country_code': countryCode,^8.1.3
      'state': state,
      'city': city,
      'page': page,
      'limit': limit,
    });
   print(url);
   print(status);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = await json.decode(response.body);
      print("fetchProducts");
      print(decodedData);
      return decodedData;
    } else {
      throw Exception('Error');
    }*/
  }

  Future fetchFavProducts(
      {status, countryCode, state, city, page, limit}) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': PRODUCT_LIST_URL,
      'status': status,
      'country_code': countryCode,
      'state': state,
      'city': city,
      'page': page,
      'limit': limit,
    });
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedData = await json.decode(response.body);
        List<Map<String, dynamic>> favList = [];
        for (int i = 0; i < decodedData.length; i++) {
          final List result = await DBHelper.queryFavProduct(
              'favourite_products', decodedData[i]['id']);
          if (result.length > 0) {
            favList.add(decodedData[i]);
          }
        }
        return favList;
      } else {
        throw Exception('Error');
      }
    } on Exception catch (e) {
      print("API_HELPER fetchFavProducts error: $e");
    }
  }

  Future fetchFeaturedAndUrgentProducts({Location userLocation}) async {
    final String url =
        'https://$BASE_URL/$UNENCODED_PATH?action=$FEATURED_URGENT_LIST_URL&status=active&city=${userLocation.cityId}&country_code=${userLocation.countryCode}&state=${userLocation.stateId}';
    print(url);
    final client = new http.Client();
    final response = await client.get(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );

    final decodeData = json.decode(response.body);
    List<Product> products = [];

    for (int i = 0; i < decodeData.length; i++) {
      try {
        products.add(Product.fromJson(decodeData[i]));
      } catch (e) {
        print(e);
      }
    }

    return products;

    /* final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': FEATURED_URGENT_LIST_URL,
      'city': userLocation.cityId,
      'state': userLocation.stateId,
    });
    print(url.toString());
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<Map<String, dynamic>> decodedData = await json.decode(response.body);
      print("Decode data");
      print(decodedData);
      List<Product> products = [];
      for(int i = 0; i<decodedData.length; i++ ) {
        print("Product");
        products.add(Product.fromJson(decodedData[i]));
        print(decodedData[i]);
      }
      return products;
    } else {
      throw Exception('Error');
      print("Il y a une erreur ");
    }*/
  }

  Future fetchProductsForUser(
      {@required String userId, int page = 1, int limit = 16}) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': MY_PRODUCT_LIST_URL,
      'user_id': userId.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      return decodedData;
    } else {
      throw Exception('Error');
    }
  }

  Future fetchExpireProductsForUser(
      {@required String userId, int page = 1, int limit = 16}) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': MY_PRODUCT_LIST_URL,
      'page': page.toString(),
      'limit': limit.toString(),
      'user_id': userId,
      'status': 'expire',
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      return decodedData;
    } else {
      throw Exception('Error');
    }
  }

  Future getCustomDataByCategory({
    @required String categoryId,
    subCategoryId,
  }) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': GET_CUSTOM_DATA_BY_CATEGORY,
      'category_id': categoryId,
      'subcategory_id': subCategoryId,

      // 'page': page,
      // 'limit': limit,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = await json.decode(response.body);
      List decodedList = [];
      await decodedData.forEach((key, value) {
        decodedList.add(value);
      });
      return decodedList;
    } else {
      throw Exception('Error');
    }
  }

  Future fetchProductsByCategory({
    categoryId = '',
    subCategoryId = '',
    countryCode = '',
    state = '',
    city = '',
    sort = '',
    filter = '',
    order = '',
  }) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': SEARCH_LIST_URL,
      'category_id': categoryId,
      'subcategory_id': subCategoryId,
      'country_code': countryCode,
      'state': state,
      'city': city,
      'filter': filter, // filter / free / featured / urgent / highlight
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = await json.decode(response.body);
      if (sort == 'price' && order == 'DESC') {
        decodedData.sort((a, b) =>
            double.parse(b['price']).compareTo(double.parse(a['price'])));
      } else if (sort == 'price' && order == '') {
        decodedData.sort((a, b) =>
            double.parse(a['price']).compareTo(double.parse(b['price'])));
      } else if (sort == 'date' && order == 'DESC') {
      } else if (sort == 'date' && order == '') {}

      return sort == 'date' && order == ''
          ? decodedData.reversed.toList()
          : decodedData;
    } else {
      throw Exception('Error');
    }
  }

  Future fetchProductsByKeywords({
    countryCode = '',
    state = '',
    city = '',
    sort = '',
    filter = '',
    order = '',
    page = '',
    limit = '',
    keywords = '',
  }) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': SEARCH_LIST_URL,
      //'contry_code': countryCode,
      'country_code': countryCode,
      'state': state,
      'sort': sort, // title / price / date
      'filter': filter, // filter / free / featured / urgent / highlight
      'order': order, // "DESC"
      'city': city,
      'page': page.toString(),
      'limit': limit.toString(),
      'keywords': keywords,
    });
    print("current country $countryCode");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      if (sort == 'price' && order == 'DESC') {
        decodedData.sort((a, b) =>
            double.parse(b['price']).compareTo(double.parse(a['price'])));
      } else if (sort == 'price' && order == '') {
        decodedData.sort((a, b) =>
            double.parse(a['price']).compareTo(double.parse(b['price'])));
      } else if (sort == 'date' && order == 'DESC') {
      } else if (sort == 'date' && order == '') {}

      print("API_HELPER fetchProductsByKeywords url: $url");

      return sort == 'date' && order == ''
          ? decodedData.reversed.toList()
          : decodedData;
    } else {
      throw Exception('Error');
    }
  }

  Future fetchRelatedProducts({categoryId = '', subCategoryId = ''}) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': RELATED_ADS_URL,
      'category_id': categoryId,
      'subcategory_id': subCategoryId,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<Product> relatedProducts = [];
      final decodedData = json.decode(response.body);
      for (int i = 0; i < decodedData.length; i++) {
        relatedProducts.add(Product.fromJson(decodedData[i]));
      }
      return relatedProducts;
    } else {
      throw Exception('Error');
    }
  }

  Future deleteProducts({@required userId, @required itemId}) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': DELETE_ADS_URL,
      'user_id': userId,
      'item_id': itemId,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      return decodedData;
    } else {
      throw Exception('Error');
    }
  }

  Future<List<City>> searchCity({dataString = '', stateId = ''}) async {
    List<City> cityList = [];
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': SEARCH_CITY_URL,
      'dataString': dataString,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      for (int i = 0; i < decodedData.length; i++) {
        if (stateId == '') {
          cityList.add(City.fromJson(decodedData[i]));
        } else if (stateId != '' && stateId == decodedData[i]['stateid']) {
          cityList.add(City.fromJson(decodedData[i]));
        }
      }
      return cityList;
    } else {
      throw Exception('Error');
    }
  }

  Future fetchProductsDetails({@required itemId}) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': PRODUCT_DETAIL_URL,
      'item_id': itemId,
    });
    final response = await http.get(url);
    print("start::::");
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      print(decodedData);
      return decodedData;
    } else {
      throw Exception('Error');
    }
  }

  Future<List<dynamic>> fetchCountryDetails() async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': COUNTRY_DETAIL_URL,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      print("$decodedData");
      return decodedData;
    } else {
      throw Exception('Error');
    }
  }

  Future fetchCustomData({@required itemId}) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': CUSTOM_DATA_URL,
      'item_id': itemId,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }
  }

  Future<List<CountryState>> fetchStateDetailsByCountry(
      {@required countryCode}) async {
    List<CountryState> stateList = [];
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': STATE_DETAIL_URL,
      'country_code': countryCode,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      print("$decodedData");
      for (int i = 0; i < decodedData.length; i++) {
        stateList.add(CountryState.fromJson(decodedData[i]));
      }
      return stateList;
    } else {
      throw Exception('Error');
    }
  }

  Future<List<dynamic>> fetchCityDetailsByState(
      {@required stateCode, keywords, bool isFilter = true}) async {
    // List<City> cityList = [];
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': CITY_DETAIL_URL,
      'state_code': stateCode,
    });
    print("keyword $keywords");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List filteredList = [];
      try {
        final decodedData = json.decode(response.body);
        log("decodedData $decodedData");
        for (var i = 0; i < decodedData.length; i++) {
          if (isFilter) {
            if (decodedData[i]['name']
                .toLowerCase()
                .contains(keywords.toLowerCase())) {
              filteredList.add(decodedData[i]);
            }
          } else {
            filteredList.add(decodedData[i]);
          }
        }
        return filteredList;
      } catch (e) {
        log(e.toString());
        return filteredList;
      }
    } else {
      throw Exception('Error');
    }
  }

  Future fetchAppConfiguration({@required langCode}) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': APP_CONFIG_URL,
      'lang_code': langCode,
    });
    try {
      final response = await http.get(url);
      print("response ${response.body.toString()}");
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        return decodedData;
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      print(e);
    }
  }

  Future fetchChatMessage({
    @required sesUserId,
    @required clientId,
  }) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': FETCH_CHAT_URL,
      'ses_userid': sesUserId,
      'client_id': clientId,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      notifyListeners();
      return decodedData;
    } else {
      throw Exception('Error');
    }
  }

  Stream fetchChatMessages({sesUserId, clientId}) async* {
    notifyListeners();
    yield await fetchChatMessage(sesUserId: sesUserId, clientId: clientId);
  }

  Future fetchGroupChatMessage({
    @required sessionUserId,
  }) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': FETCH_GROUP_CHAT_URL,
      'session_user_id': sessionUserId,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = await json.decode(response.body);
      print(decodedData);
      // print(decodedData.data.length);
      return decodedData;
    } else {
      throw Exception('Error');
    }
  }

  Future fetchLanguagePack() async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': FETCH_LANGUAGE_PACK_URL,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }
  }

  Future makeAnOffer({
    ownerId,
    message,
    senderId,
    senderName,
    ownerName,
    email,
    subject,
    productTitle,
    type,
    productId,
  }) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': MAKE_AN_OFFER,
      'OwnerId': ownerId,
      'message': message,
      'SenderId': senderId,
      'SenderName': senderName,
      'OwnerName': ownerName,
      'email': email,
      'subject': subject,
      'productTitle': productTitle,
      'type': type,
      'productId': productId,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }
  }

  Future sendChatMessage({
    fromId,
    toId,
    message,
  }) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': SEND_CHAT_URL,
      'from_id': fromId,
      'to_id': toId,
      'message': message,
    });
    print(url);
    final response = await http.get(url);
    print("Response");
    print(response.statusCode);
    if (response.statusCode == 200) {
      print("Message sent");
    } else {
      print("Errorr");
      throw Exception('Error');
    }
  }

  Future getNotificationMessage({
    @required userId,
  }) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': GET_NOTIFICATION_MESSAGE_URL,
      'user_id': userId,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      return decodedData;
    } else {
      throw Exception('Error');
    }
  }

  Future addFirebaseDeviceToken({
    userId,
    deviceId,
    name,
    token,
  }) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': ADD_FIREBASE_DEVICE_TOKEN_URL,
      'user_id': userId,
      'device_id': deviceId,
      'name': name,
      'token': token,
    });
    final response = await http.get(url);
    print("FCM::");
    if (response.statusCode == 200) {
      print("FCM ${response.body.toString()}");
      return true;
    } else {
      //throw Exception('Error');
      return false;
    }
  }

  Future updateProfilePic({
    @required userId,
    @required imageFile,
  }) async {
    if (imageFile != null) {
      var request = http.MultipartRequest(
          "POST",
          Uri.https(
            BASE_URL,
            UNENCODED_PATH,
            {
              'action': UPLOAD_PROFILE_PIC_URL,
              'user_id': userId,
            },
          ));
      request.files.add(await http.MultipartFile.fromPath(
        'fileToUpload',
        imageFile.path,
      ));
      final response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        final decodedResponse = await json.decode(responseString);
        return decodedResponse;
      }
    }
  }

  Future updateUserPostedProductPic(File imageFile, prodId) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': UPLOAD_PRODUCT_PIC_URL,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }
  }

  Future uploadProductImage(List<File> imageFiles, prodId) async {
    List<String> serverImagesList = [];
    for (var i = 0; i < imageFiles.length; i++) {
      if (imageFiles[i] != null) {
        var request = new http.MultipartRequest(
            "POST",
            Uri.https(
              BASE_URL,
              UNENCODED_PATH,
              {
                'action': UPLOAD_PRODUCT_PIC_URL,
              },
            ));
        request.files.add(await http.MultipartFile.fromPath(
          'fileToUpload',
          imageFiles[i].path,
        ));
        request.send().then((response) async {
          if (response.statusCode == 200) {
            var responseData = await response.stream.toBytes();
            var responseString = String.fromCharCodes(responseData);
            final decodedResponse = json.decode(responseString);
            serverImagesList.add(decodedResponse['picture']);
          }
        });
      }
    }
    return serverImagesList;
  }

  Future postUserProduct({
    userId,
    title,
    categoryId,
    subCategoryId,
    countryCode,
    state,
    city,
    description,
    location,
    hidePhone,
    negotiable,
    price,
    phone,
    latitude,
    longitude,
    List<Map<String, String>> additionalInfo,
    productImages,
  }) async {
    String serverImagesList = '';

    for (var i = 0; i < productImages.length; i++) {
      if (productImages[i].file != null && productImages[i].isLocal) {
        var request = new http.MultipartRequest(
            "POST",
            Uri.https(
              BASE_URL,
              UNENCODED_PATH,
              {
                'action': UPLOAD_PRODUCT_PIC_URL,
              },
            ));
        request.files.add(await http.MultipartFile.fromPath(
          'fileToUpload',
          productImages[i].file.path,
        ));
        final response = await request.send();

        if (response.statusCode == 200) {
          var responseData = await response.stream.toBytes();
          var responseString = String.fromCharCodes(responseData);
          final decodedResponse = await json.decode(responseString);
          serverImagesList =
              serverImagesList + ',' + decodedResponse['picture'];
        }
      }
    }
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': UPLOAD_PRODUCT_SAVE_POST_URL,
      'user_id': userId,
      'title': title,
      'category_id': categoryId,
      'subcategory_id': subCategoryId,
      'country_code': countryCode,
      'state': state,
      'city': city,
      'description': description,
      'location': location,
      'hide_phone': hidePhone,
      'negotiable': negotiable,
      'price': price,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'item_screen': serverImagesList,
      'additionalinfo': json.encode(additionalInfo),
    });
    final response2 = await http.post(url);
    if (response2.statusCode == 200) {
      final decodedData = await json.decode(response2.body);
      return decodedData;
    } else {
      throw Exception('Error');
    }
  }

  Future updateUserProduct({
    userId,
    productId,
    title,
    categoryId,
    subCategoryId,
    countryCode,
    state,
    city,
    description,
    location,
    hidePhone,
    negotiable,
    price,
    phone,
    latitude,
    longitude,
    itemScreen,
    additionalInfo,
    productImages,
  }) async {
    String serverImagesList = '';

    for (var i = 0; i < productImages.length; i++) {
      if (!productImages[i].isLocal && productImages[i].url != null) {
        serverImagesList = serverImagesList + ',' + productImages[i].url;
      }
      if (productImages[i].isLocal && productImages[i].file != null) {
        var request = new http.MultipartRequest(
            "POST",
            Uri.https(
              BASE_URL,
              UNENCODED_PATH,
              {
                'action': UPLOAD_PRODUCT_PIC_URL,
              },
            ));
        request.files.add(await http.MultipartFile.fromPath(
          'fileToUpload',
          productImages[i].file.path,
        ));
        final response = await request.send();

        if (response.statusCode == 200) {
          var responseData = await response.stream.toBytes();
          var responseString = String.fromCharCodes(responseData);
          final decodedResponse = json.decode(responseString);
          serverImagesList =
              serverImagesList + ',' + decodedResponse['picture'];
        }
      }
    }
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': UPLOAD_PRODUCT_UPDATE_POST_URL,
      'user_id': userId,
      'product_id': productId,
      'title': title,
      'category_id': categoryId,
      'subcategory_id': subCategoryId,
      'country_code': countryCode,
      'state': state,
      'city': city,
      'description': description,
      'location': location,
      'hide_phone': hidePhone,
      'negotiable': negotiable,
      'price': price,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'item_screen': serverImagesList,
      'additionalinfo': json.encode(additionalInfo),
    });
    final response2 = await http.post(url);
    if (response2.statusCode == 200) {
      final Map<String, dynamic> decodedData =
          await json.decode(response2.body);
      return decodedData;
    } else {
      throw Exception('Error');
    }
  }

  Future postPremiumTransactionDetail(
    name,
    amount,
    userId,
    productId,
    featured,
    urgent,
    highlight,
    folder,
    paymentType,
    transDesc,
  ) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': UPLOAD_PRODUCT_PREMIUM_TRANSACTION_URL,
      'name': name,
      'amount': amount,
      'user_id': userId,
      'sub_id': productId,
      'featured': featured,
      'urgent': urgent,
      'highlight': highlight,
      'folder': folder,
      'payment_type': paymentType,
      'trans_desc': transDesc,
    });
    final response = await http.post(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      print(url);
      print(decodedData);
      return decodedData;
    } else {
      throw Exception('Error');
    }
  }

  Future postUpgradeAd(
    name,
    amount,
    userId,
    productId,
    featured,
    urgent,
    highlight,
    folder,
    paymentType,
    transDesc,
  ) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': UPLOAD_PRODUCT_PREMIUM_TRANSACTION_URL,
      'name': name,
      'amount': amount,
      'user_id': userId,
      'product_id': productId,
      'featured': featured,
      'urgent': urgent,
      'highlight': highlight,
      'folder': folder,
      'payment_type': paymentType,
      'trans_desc': transDesc,
    });
    final response = await http.post(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      print(url);
      print(decodedData);
      return decodedData;
    } else {
      throw Exception('Error');
    }
  }

  Future postPremiumAppTransactionDetail(
    name,
    amount,
    userId,
    subId,
    folder,
    paymentType,
    transDesc,
  ) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': UPLOAD_PRODUCT_PREMIUM_TRANSACTION_URL,
      'name': name,
      'amount': amount,
      'user_id': userId,
      'sub_id': subId,
      'folder': folder,
      'payment_type': paymentType,
      'trans_desc': transDesc,
    });
    final response = await http.post(url);
    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }
  }

  Future getUnReadMessageCount({
    @required userId,
  }) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': GET_UNREAD_MESSAGE_COUNT_URL,
      'user_id': userId,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }
  }

  Future getAdStatus() async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': GET_GADS_FBADS_URL,
    });
    final response = await http.get(url);
    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }
  }

  Future fetchPaymentVendorCredentials() async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': GET_TRANSACTION_VENDOR_CRED_URL,
    });
    https: //https://keeraya.com//api/v1/index.php?action=payment_api_detail_config
    https: //https://keeraya.com//api/v1/index.php?action=payment_api_detail_config
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      print(url);
      print(decodedData);
      return decodedData;
    } else {
      throw Exception('Error');
    }
  }

  Future<AppConfig> fetchAppConfig() async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      return decodedData;
    } else {
      throw Exception('Error');
    }
  }

  Future<List<MembershipPlan>> fetchMembershipPlan() async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': GET_MEMBERSHIP_PLAN_URL,
    });
    print(url.toString());
    final response = await http.get(url);
    if (response.statusCode == 200) {
      print(response.body);
      final decodedData = await json.decode(response.body);
      List<MembershipPlan> membershipList = [];
      for (int i = 0; i < decodedData['plans'].length; i++) {
        membershipList.add(MembershipPlan.fromJson(decodedData['plans'][i]));
      }
      return membershipList;
    } else {
      throw Exception('Error');
    }
  }

  Future<String> fetchCurrentUserMembershipPlan({
    @required userId,
  }) async {
    final url = Uri.https(BASE_URL, UNENCODED_PATH, {
      'action': GET_USER_MEMBERSHIP_PLAN_URL,
      'user_id': userId,
    });
    print(url.toString());
    final response = await http.get(url);
    if (response.statusCode == 200) {
      print(response.body);
      return json.decode(response.body)["plan_title"];
    } else {
      throw Exception('Error');
    }
  }
}
