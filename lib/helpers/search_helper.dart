import 'package:keeraya/helpers/app_config.dart';
import 'package:flutter/material.dart';

import './db_helper.dart';
import '../helpers/current_user.dart';
import '../providers/location_provider.dart';
import '../screens/tabs_screen.dart';

class LocationSearch extends SearchDelegate<String> {
  LocationSearch({
    this.contextPage,
  });

  BuildContext contextPage;

  // List<CountryState> stateList;
  // List<Country> countryList;
  // List<City> cityList;
  bool _isState = true;
  String _chosenStateCode = '';

  final suggestions1 = [AppConfig.adCountryName];

  @override
  String get searchFieldLabel => _isState ? "State" : 'City';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // final suggestions = query.isEmpty ? suggestions1 : [];
    return StatefulBuilder(
        builder: (BuildContext statCtx, StateSetter setState) {
      List<dynamic> suggestions = [];
      if (_isState) {
        LocationProvider.countryStates.forEach((element) {
          if (element.name.contains(query)) {
            suggestions.add(element);
          }
        });
      } else {
        LocationProvider.cities.forEach((element) {
          if (element.name.contains(query) &&
              element.stateId == _chosenStateCode) {
            suggestions.add(element);
          }
        });
      }
      return Column(
        children: [
          ListTile(
            trailing: Icon(Icons.arrow_right),
            title: Text(LocationProvider.countries[0].name),
            onTap: () async {
              if (!CurrentUser.uploadingAd) {
                CurrentUser.location.name = LocationProvider.countries[0].name;
                CurrentUser.location.cityId = '';
                CurrentUser.location.cityName = '';
                CurrentUser.location.stateId = '';
                CurrentUser.location.stateName = '';
                CurrentUser.location.cityState = '';

                await DBHelper.update('user_info', {
                  'locationName': CurrentUser.location.name,
                  'locationCityId': '',
                  'locationCityName': '',
                  'locationStateId': '',
                  'locationStateName': '',
                  'locationCityState': '',
                });

                Navigator.pushNamedAndRemoveUntil(context, TabsScreen.routeName,
                    (Route<dynamic> route) => false);
              } else {
                CurrentUser.uploadingAd = false;
                CurrentUser.prodLocation.name =
                    LocationProvider.countries[0].name;
                CurrentUser.prodLocation.cityId = '';
                CurrentUser.prodLocation.cityName = '';
                CurrentUser.prodLocation.stateId = '';
                CurrentUser.prodLocation.stateName = '';
                CurrentUser.prodLocation.cityState = '';
                close(context, LocationProvider.countries[0].name);
              }
            },
          ),
          if (_isState)
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (content, i) => ListTile(
                  trailing: Icon(Icons.arrow_right),
                  title: Text(suggestions[i].name),
                  onTap: () async {
                    _chosenStateCode = suggestions[i].code;
                    if (LocationProvider.cities
                            .where((element) =>
                                _chosenStateCode == element.stateId)
                            .toList()
                            .length ==
                        0) {
                      if (!CurrentUser.uploadingAd) {
                        CurrentUser.location.name = suggestions[i].name;
                        CurrentUser.location.cityId = '';
                        CurrentUser.location.cityName = '';
                        CurrentUser.location.stateId = suggestions[i].code;
                        CurrentUser.location.stateName = suggestions[i].name;
                        CurrentUser.location.cityState = '';

                        await DBHelper.update('user_info', {
                          'locationName': CurrentUser.location.name,
                          'locationCityId': '',
                          'locationCityName': '',
                          'locationStateId': CurrentUser.location.stateId,
                          'locationStateName': CurrentUser.location.stateName,
                          'locationCityState': '',
                        });
                        Navigator.pushNamedAndRemoveUntil(
                            context,
                            TabsScreen.routeName,
                            (Route<dynamic> route) => false);
                      } else {
                        CurrentUser.prodLocation.name = suggestions[i].name;
                        CurrentUser.prodLocation.cityId = '';
                        CurrentUser.prodLocation.cityName = '';
                        CurrentUser.prodLocation.stateId = suggestions[i].code;
                        CurrentUser.prodLocation.stateName =
                            suggestions[i].name;
                        CurrentUser.prodLocation.cityState = '';
                        CurrentUser.uploadingAd = false;
                        close(context, suggestions[i].name);
                      }
                    } else {
                      setState(() {
                        _isState = false;
                      });
                    }
                    //suggestions = [];
                  },
                ),
              ),
            ),
          if (!_isState)
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (content, i) => ListTile(
                  trailing: Icon(Icons.arrow_right),
                  title: Text(suggestions[i].name),
                  onTap: () async {
                    if (!CurrentUser.uploadingAd) {
                      CurrentUser.location.name = suggestions[i].cityState;
                      CurrentUser.location.cityId = suggestions[i].id;
                      CurrentUser.location.cityName = suggestions[i].name;
                      CurrentUser.location.stateId = suggestions[i].stateId;
                      CurrentUser.location.stateName = suggestions[i].stateName;
                      CurrentUser.location.cityState = suggestions[i].cityState;

                      await DBHelper.update('user_info', {
                        'locationName': CurrentUser.location.name,
                        'locationCityId': CurrentUser.location.cityId,
                        'locationCityName': CurrentUser.location.cityName,
                        'locationStateId': CurrentUser.location.stateId,
                        'locationStateName': CurrentUser.location.stateName,
                        'locationCityState': CurrentUser.location.cityState,
                      });
                      Navigator.pushNamedAndRemoveUntil(
                          context,
                          TabsScreen.routeName,
                          (Route<dynamic> route) => false);
                    } else {
                      CurrentUser.prodLocation.name = suggestions[i].cityState;
                      CurrentUser.prodLocation.cityId = suggestions[i].id;
                      CurrentUser.prodLocation.cityName = suggestions[i].name;
                      CurrentUser.prodLocation.stateId = suggestions[i].stateId;
                      CurrentUser.prodLocation.stateName =
                          suggestions[i].stateName;
                      CurrentUser.prodLocation.cityState =
                          suggestions[i].cityState;
                      CurrentUser.uploadingAd = false;
                      close(context, suggestions[i].name);
                    }
                  },
                ),
              ),
            ),
        ],
      );
    });
  }
}
