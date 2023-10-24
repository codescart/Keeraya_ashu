import 'package:flutter/cupertino.dart';

import '../helpers/api_helper.dart';
import '../models/city.dart';
import '../models/country.dart';
import '../models/state.dart';

class LocationProvider with ChangeNotifier {
  static List<Country> _countries = [];
  static List<CountryState> _countryStates = [];
  static List<City> _cities = [];

  static List<Country> get countries {
    return [..._countries];
  }

  static List<CountryState> get countryStates {
    return [..._countryStates];
  }

  static List<City> get cities {
    return [..._cities];
  }

  static Future fetchLocations() async {
    final apiHelper = APIHelper();

    _countries = await apiHelper.fetchCountryDetails();
    _countryStates =
        await apiHelper.fetchStateDetailsByCountry(countryCode: 'IN');
    // for (int i = 0; i < _countryStates.length; i++) {
    //   List<City> cityList = await apiHelper.fetchCityDetailsByState(
    //       stateCode: _countryStates[i].code);
    //   _cities.addAll(cityList);
    // }
    // _cities = await apiHelper.searchCity(dataString: '');

    // await apiHelper.fetchCityDetailsByState(stateCode: 'IN.38');
    // print(fetchedList);
  }

// static Future searchCity(String searchString, String stateCode) async {
//   final apiHelper = APIHelper();

//   _cities = await apiHelper.searchCity(
//     dataString: searchString,
//     stateId: stateCode,
//   );
//   return cities;
// }
}
