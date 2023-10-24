import 'package:keeraya/helpers/app_config.dart';
import 'package:keeraya/helpers/db_helper.dart';
import 'package:flutter/cupertino.dart';

import '../models/location.dart';

class CurrentUser with ChangeNotifier {
  static String id = '';
  static String name = '';
  static String username = '';
  static String email = '';
  static String picture = '';
  static String language = 'English';
  static bool isLoggedIn = false;
  static bool uploadingAd = false;
  static bool fromSearchScreen = false;

  //static Location location = Location(name: 'Kuwait');
  static Location location = Location(name: AppConfig.adCountryName);
  static Location prodLocation = Location();
  static bool showUpdateAlert = true;
  static TextDirection textDirection =
      language == 'English' ? TextDirection.ltr : TextDirection.rtl;

  static Future initialize() async {
    final dataList = await DBHelper.read('user_info');
    print('dataListUser: $dataList');
    if (dataList.length >= 1) {
      final lastUser = dataList[0];
      id = lastUser['id'];
      username = lastUser['username'] ?? '';
      name = lastUser['name'] ?? '';
      email = lastUser['email'] ?? '';
      picture = lastUser['picture'] ?? '';
      isLoggedIn = lastUser['isLoggedIn'] == '1' ? true : false;
      location.name =
          lastUser['locationName'] != null ? lastUser['locationName'] : '';
      location.cityId =
          lastUser['locationCityId'] != null ? lastUser['locationCityId'] : '';
      location.cityName = lastUser['locationCityName'] != null
          ? lastUser['locationCityName']
          : '';
      location.stateId = lastUser['locationStateId'] != null
          ? lastUser['locationStateId']
          : '';
      location.stateName = lastUser['locationStateName'] != null
          ? lastUser['locationStateName']
          : '';
      location.cityState = lastUser['locationCityState'] != null
          ? lastUser['locationCityState']
          : '';
      location.countryCode =
          lastUser['countryCode'] != null ? lastUser['countryCode'] : '';
      print('$id $name $username $email $picture $isLoggedIn');
      if (location.name == '' &&
          location.cityId == '' &&
          location.cityName == '' &&
          location.stateId == '' &&
          location.stateName == '' &&
          location.cityState == '') {
        location.name = AppConfig.adCountryName;
      }
      if (language == '') {
        language == 'English';
      }
    }
  }

  void setProductLocation({
    prodCityState = '',
    prodCityId = '',
    prodCityName = '',
    prodStateId = '',
    prodStateName = '',
    prodLocationName = '',
    prodLongitude = '',
    prodLatitude = '',
    prodCountryCode = '',
    prodCountryName = '',
  }) {
    // prodLocation.name = cityState == '' ? cityName : cityState;
    // prodLocation.cityId = cityId;
    // prodLocation.cityName = cityName;
    // prodLocation.stateId = stateId;
    // prodLocation.stateName = stateName;
    // prodLocation.cityState = cityState;
    prodLocation.name = prodLocationName;
    prodLocation.cityId = prodCityId;
    prodLocation.cityName = prodCityName;
    prodLocation.stateId = prodStateId;
    prodLocation.stateName = prodStateName;
    prodLocation.cityState = prodCityState;
    prodLocation.longitude = prodLongitude;
    prodLocation.latitude = prodLatitude;
    prodLocation.countryCode = prodCountryCode;
    prodLocation.countryName = prodCountryName;
    notifyListeners();
  }

  Location get prodLocationGetter {
    return prodLocation;
  }
}
