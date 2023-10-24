import 'package:keeraya/helpers/app_config.dart';
import 'package:flutter/cupertino.dart';

import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../models/category.dart';
import '../models/location.dart';
import '../models/product.dart';

class Products with ChangeNotifier {
  final apiHelper = APIHelper();
  List<Product> _products = [];
  List<Product> _featuredAndUrgentProducts = [];
  List<Category> _categories = [];
  List _myProducts = [];
  List _notifications = [];

  set products(value) {
    _products = value;
  }

  set featuredAndUrgentProducts(value) {
    _featuredAndUrgentProducts = value;
  }

  set categories(value) {
    _categories = value;
  }

  set myProducts(value) {
    _myProducts = value;
  }

  set notifications(value) {
    _notifications = value;
  }

  List<Product> get items {
    return [..._products];
  }

  List<Product> get featuredAndUrgentItems {
    return [..._featuredAndUrgentProducts];
  }

  List<Category> get categoriesItems {
    return [..._categories];
  }

  List get myProductsItems {
    return [..._myProducts];
  }

  List get notificationItems {
    return [..._notifications];
  }

  // Future<Map<String, List<dynamic>>> fetchHomeProducts(
  //     {Location userLocation}) async {
  //   List<Product> fetchedProducts = [];
  //   List<Category> fetchedCategories = [];
  //   Map<String, List<dynamic>> fetchedMap = {
  //     'recentProducts': [],
  //     'featuredProducts': [],
  //     'categories': [],
  //   };

  //   final productsConvertedData = await apiHelper.fetchProducts(
  //     city: userLocation.cityName,
  //     state: userLocation.stateName,
  //     countryCode: CurrentUser.location.countryCode != null &&
  //             CurrentUser.location.countryCode != ''
  //         ? CurrentUser.location.countryCode
  //         : 'IN',
  //   );
  //   final featuredConvertedData =
  //       await apiHelper.fetchFeaturedAndUrgentProducts(
  //     userLocation: userLocation,
  //   );
  //   final appConfigConvertedData =
  //       await apiHelper.fetchAppConfiguration(langCode: 'en');
  //   final categories = appConfigConvertedData['categories'];

  //   // print('All the API works )');

  //   // Converting products from JSON to Product objects
  //   for (int i = 0; i < productsConvertedData.length; i++) {
  //     // print('in loop');
  //     print(productsConvertedData[i]['location']);
  //     if ((productsConvertedData[i]['cityid'] == userLocation.cityId &&
  //             productsConvertedData[i]['stateid'] == userLocation.stateId &&
  //             productsConvertedData[i]['cityid'] != '' &&
  //             productsConvertedData[i]['stateid'] != '') ||
  //         (productsConvertedData[i]['cityid'] == '' &&
  //             productsConvertedData[i]['stateid'] == userLocation.stateId &&
  //             userLocation.cityId == '') ||
  //         (userLocation.cityId == '' && userLocation.stateId == '')) {
  //       fetchedProducts.add(Product.fromJson(productsConvertedData[i]));
  //     }
  //     // print('in loop after condition');
  //   }
  //   if (fetchedProducts != [] && fetchedProducts != null) {
  //     _products = fetchedProducts;
  //     fetchedMap['recentProducts'] = _products;
  //     fetchedProducts = [];
  //   }

  //   // print('After prod convert');

  //   print('Și za huineaaaaaaaaaaaaaaaaaa:::::::::  $fetchedMap');
  //   // Converting featured and urgent ads from JSON to Product object
  //   for (int i = 0; i < featuredConvertedData.length; i++) {
  //     if (featuredConvertedData[i]['location'] == userLocation.name ||
  //         userLocation.name == 'Kuwait') {
  //       fetchedProducts.add(Product.fromJson(featuredConvertedData[i]));
  //     }
  //   }
  //   if (fetchedProducts != [] && fetchedProducts != null) {
  //     _featuredAndUrgentProducts = fetchedProducts;
  //     fetchedMap['featuredProducts'] = _featuredAndUrgentProducts;
  //     fetchedProducts = [];
  //   }

  //   // Converting categories from JSON to Category object
  //   for (int i = 0; i < categories.length; i++) {
  //     fetchedCategories.add(Category.fromJson(categories[i]));
  //   }
  //   if (fetchedCategories != [] && fetchedCategories != null) {
  //     _categories = fetchedCategories;
  //     fetchedMap['categories'] = _categories;
  //     fetchedCategories = [];
  //   }
  //   return fetchedMap;
  // }

  Future<List<Category>> fetchCategories() async {
    List<Category> fetchedCategories = [];
    final appConfigConvertedData =
        await apiHelper.fetchAppConfiguration(langCode: 'en');
    final categories = appConfigConvertedData['categories'];

    for (int i = 0; i < categories.length; i++) {
      fetchedCategories.add(Category.fromJson(categories[i]));
    }
    if (fetchedCategories != [] && fetchedCategories != null) {
      _categories = fetchedCategories;
      // fetchedMap['categories'] = _categories;
      // fetchedCategories = [];
    }
    return fetchedCategories;
  }

  Future fetchFeaturedProducts(Location userLocation) async {
    List<Product> fetchedProducts = [];

    fetchedProducts = await apiHelper.fetchFeaturedAndUrgentProducts(
      userLocation: userLocation,
    );
    _featuredAndUrgentProducts = fetchedProducts;

    return _featuredAndUrgentProducts;
  }

  Future fetchHomeLatestProducts({Location userLocation, page, limit}) async {
    List<Product> fetchedProducts = [];
    print("Le country code");
    print(CurrentUser.location.countryCode);
    fetchedProducts = await apiHelper.fetchProducts(
      page: page.toString(),
      limit: limit.toString(),
      city: userLocation.cityId,
      state: userLocation.stateId,
      countryCode: CurrentUser.location.countryCode != null &&
              CurrentUser.location.countryCode != ''
          ? CurrentUser.location.countryCode
          : AppConfig.defaultCountry,
    );
    /* for (int i = 0; i < productsConvertedData.length; i++) {
      fetchedProducts.add(Product.fromJson(productsConvertedData[i]));
    }*/
    if (fetchedProducts != [] && fetchedProducts != null && page == 1) {
      _products = fetchedProducts;
    }

    return fetchedProducts;
  }

  void clearProductsCache() {
    products = <Product>[];
    categories = <Category>[];
    featuredAndUrgentProducts = <Product>[];
  }
}
