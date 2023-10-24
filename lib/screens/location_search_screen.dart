import 'package:keeraya/screens/color_helper.dart';
import 'package:keeraya/screens/search_ad_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../helpers/db_helper.dart';
import '../providers/languages.dart';
import '../providers/products.dart';
import '../screens/tabs_screen.dart';

class LocationSearchScreen extends StatefulWidget {
  static const routeName = '/location-search';

  @override
  _LocationSearchScreenState createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  bool _isState = false;
  bool _isCountry = true;
  String _keyword = '';
  String _chosenStateCode = '';
  String _chosenStateName = '';
  String _chosenCountryName = '';
  String _chosenCountryCode = '';
  String _chosenCityName = '';
  String _chosenCityCode = '';

  // bool isCitySearch = false;
  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    final productsProvider = Provider.of<Products>(context);
    // List snapshot.data = [];
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: SafeArea(
          child: AppBar(
            shape: AppBarBottomShape(),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () async {
                await DBHelper.update('user_info', {
                  'id': CurrentUser.id,
                  'locationName': CurrentUser.location.name,
                  'locationCityId': CurrentUser.location.cityId,
                  'locationCityName': CurrentUser.location.cityName,
                  'locationStateId': CurrentUser.location.stateId,
                  'locationStateName': CurrentUser.location.stateName,
                  'locationCityState': CurrentUser.location.cityState,
                });
                final dataList = await DBHelper.read('user_info');

                print(
                    "isUpload ${CurrentUser.uploadingAd} | isFromSearch ${CurrentUser.fromSearchScreen}");

                if (!CurrentUser.uploadingAd) {
                  if (CurrentUser.fromSearchScreen) {
                    // Navigator.of(context).pop();
                    Navigator.of(context).pushNamed(SearchAdScreen.routeName);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(context,
                        TabsScreen.routeName, (Route<dynamic> route) => false);
                  }
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            iconTheme: IconThemeData(
              color: Colors.grey[800],
            ),
            flexibleSpace: Container(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 55,
                right: 10,
              ),
              child: TextField(
                cursorColor: Colors.grey[800],
                textDirection: CurrentUser.textDirection,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintTextDirection: CurrentUser.textDirection,
                  labelText: langPack[_isCountry
                      ? 'Country'
                      : _isState
                          ? 'State'
                          : 'City'],
                  suffixIcon: Icon(Icons.search, color: Colors.grey),
                ),
                onChanged: (value) {
                  setState(() {
                    _keyword = value;
                  });
                },
              ),
            ),
            //title: Text('Home Tab'),
            backgroundColor: HexColor(),
            elevation: 2,
          ),
        ),
      ),
      body: _isCountry
          ? FutureBuilder(
              future: Provider.of<APIHelper>(context, listen: false)
                  .fetchCountryDetails(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: Container(
                        width: 100,
                        margin: EdgeInsets.only(top: 20),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey,
                          // color: Colors.black,
                        ),
                      ),
                    );

                    break;
                  default:
                    if (snapshot.hasError) {
                      return Container(
                        child: Text(snapshot.error.toString()),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount: snapshot.data.length,
                      itemBuilder: (content, i) => ListTile(
                        trailing: CurrentUser.language == 'Arabic'
                            ? null
                            : Icon(Icons.arrow_right),
                        leading: CurrentUser.language == 'Arabic'
                            ? Icon(Icons.arrow_left)
                            : null,
                        // trailing: Icon(Icons.arrow_right),
                        title: Text(
                          snapshot.data[i]['name'],
                          textAlign: CurrentUser.language == 'Arabic'
                              ? TextAlign.end
                              : TextAlign.start,
                        ),
                        onTap: () async {
                          _chosenCountryName = snapshot.data[i]['name'];
                          _chosenCountryCode = snapshot.data[i]['code'];
                          print("data out here $_chosenCountryName");
                          if (!CurrentUser.uploadingAd) {
                            CurrentUser.location.name = '$_chosenCountryName';
                            print(
                                "data in here ${CurrentUser.location.name} | $_chosenCountryCode");
                            // , ${_chosenStateName}';
                            CurrentUser.location.cityId = '';
                            CurrentUser.location.cityName = '';
                            CurrentUser.location.stateId = _chosenStateCode;
                            CurrentUser.location.stateName = _chosenStateName;
                            CurrentUser.location.cityState = '';
                            CurrentUser.location.countryCode =
                                _chosenCountryCode;
                            CurrentUser.location.countryName =
                                _chosenCountryName;

                            await DBHelper.update('user_info', {
                              'id': CurrentUser.id,
                              'locationName': CurrentUser.location.name,
                              'locationCityId': CurrentUser.location.cityId,
                              'locationCityName': CurrentUser.location.cityName,
                              'locationStateId': CurrentUser.location.stateId,
                              'locationStateName':
                                  CurrentUser.location.stateName,
                              'locationCityState':
                                  CurrentUser.location.cityState,
                            });
                            // Navigator.pushNamedAndRemoveUntil(
                            //     context,
                            //     TabsScreen.routeName,
                            //     (Route<dynamic> route) => false);
                            productsProvider.clearProductsCache();
                            setState(() {
                              _isCountry = false;
                              _isState = true;
                            });
                          } else {
                            // CurrentUser.prodLocation.name =
                            //     '${snapshot.data[i]['name']}';
                            // // ${_chosenStateName}';
                            // CurrentUser.prodLocation.cityId = '';
                            // CurrentUser.prodLocation.cityName = '';
                            // CurrentUser.prodLocation.stateId = _chosenStateCode;
                            // CurrentUser.prodLocation.stateName =
                            //     _chosenStateName;
                            // CurrentUser.prodLocation.cityState = '';
                            // // '${snapshot.data[i]['name']}, ${_chosenStateName}';
                            // CurrentUser.prodLocation.longitude = '';
                            // // snapshot.data[i]['longitude'];
                            // CurrentUser.prodLocation.latitude = '';
                            // // snapshot.data[i]['latitude'];
                            // CurrentUser.prodLocation.countryCode =
                            //     snapshot.data[i]['code'];
                            // CurrentUser.prodLocation.countryName =
                            //     snapshot.data[i]['name'];

                            Provider.of<CurrentUser>(context, listen: false)
                                .setProductLocation(
                              prodCityId: '',
                              prodCityName: '',
                              prodCityState: '',
                              prodCountryCode: _chosenCountryCode,
                              prodCountryName: _chosenCountryName,
                              prodLatitude: '',
                              prodLocationName: _chosenCountryName,
                              prodLongitude: '',
                              prodStateId: _chosenStateCode,
                              prodStateName: _chosenStateName,
                            );
                            // CurrentUser.uploadingAd = false;
                            // close(context, snapshot.data[i].name);
                            // Navigator.of(context).pop();
                            setState(() {
                              _isCountry = false;
                              _isState = true;
                            });
                          }
                        },
                      ),
                    );
                }
              })
          : _isState
              ? FutureBuilder(
                  future: Provider.of<APIHelper>(context, listen: false)
                      .fetchStateDetailsByCountry(
                          countryCode: _chosenCountryCode),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        print('State Waiting !');
                        return Center(
                          child: Container(
                            width: 100,
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.grey,
                              // color: Colors.black,
                            ),
                          ),
                        );

                        break;
                      default:
                        if (snapshot.hasError) {
                          return Container(
                            child: Text(snapshot.error.toString()),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: snapshot.data.length,
                          itemBuilder: (content, i) {
                            print('Fetched State ::::>>>> ${snapshot.data[i]}');
                            if (snapshot.data[i].name
                                .toLowerCase()
                                .contains(_keyword.toLowerCase())) {
                              return ListTile(
                                // trailing: Icon(Icons.arrow_right),
                                trailing: CurrentUser.language == 'Arabic'
                                    ? null
                                    : Icon(Icons.arrow_right),
                                leading: CurrentUser.language == 'Arabic'
                                    ? Icon(Icons.arrow_left)
                                    : null,
                                title: Text(
                                  snapshot.data[i].name,
                                  textAlign: CurrentUser.language == 'Arabic'
                                      ? TextAlign.end
                                      : TextAlign.start,
                                ),
                                onTap: () async {
                                  _chosenStateCode = snapshot.data[i].code;
                                  _chosenStateName = snapshot.data[i].name;
                                  // if (LocationProvider.cities
                                  //         .where((element) =>
                                  //             _chosenStateCode == element.stateId)
                                  //         .toList()
                                  //         .length ==
                                  //     0) {
                                  if (!CurrentUser.uploadingAd) {
                                    CurrentUser.location.name =
                                        _chosenStateName +
                                            ', ' +
                                            CurrentUser.location.countryName;
                                    CurrentUser.location.cityId = '';
                                    CurrentUser.location.cityName = '';
                                    CurrentUser.location.stateId =
                                        _chosenStateCode;
                                    CurrentUser.location.stateName =
                                        _chosenStateName;
                                    CurrentUser.location.cityState = '';

                                    await DBHelper.update('user_info', {
                                      'id': CurrentUser.id,
                                      'locationName': CurrentUser.location.name,
                                      'locationCityId': '',
                                      'locationCityName': '',
                                      'locationStateId':
                                          CurrentUser.location.stateId,
                                      'locationStateName':
                                          CurrentUser.location.stateName,
                                      'locationCityState': '',
                                    });
                                    productsProvider.clearProductsCache();
                                    // Navigator.pushNamedAndRemoveUntil(
                                    //     context,
                                    //     TabsScreen.routeName,
                                    //     (Route<dynamic> route) => false);
                                  } else {
                                    // CurrentUser.prodLocation.name =
                                    //     snapshot.data[i].name +
                                    //         ', ' +
                                    //         CurrentUser.location.countryName;
                                    // CurrentUser.prodLocation.cityId = '';
                                    // CurrentUser.prodLocation.cityName = '';
                                    // CurrentUser.prodLocation.stateId =
                                    //     snapshot.data[i].code;
                                    // CurrentUser.prodLocation.stateName =
                                    //     snapshot.data[i].name;
                                    // CurrentUser.prodLocation.cityState = '';

                                    Provider.of<CurrentUser>(context,
                                            listen: false)
                                        .setProductLocation(
                                      prodCityId: '',
                                      prodCityName: '',
                                      prodCityState: '',
                                      prodCountryCode: _chosenCountryCode,
                                      prodCountryName: _chosenCountryName,
                                      prodLatitude: '',
                                      prodLocationName: _chosenStateName +
                                          ', ' +
                                          _chosenCountryName,
                                      prodLongitude: '',
                                      prodStateId: _chosenStateCode,
                                      prodStateName: _chosenStateName,
                                    );

                                    // CurrentUser.uploadingAd = false;
                                    // close(context, snapshot.data[i].name);
                                  }
                                  // } else {
                                  setState(() {
                                    _isState = false;
                                  });
                                  // }
                                  //snapshot.data = [];
                                },
                              );
                            }
                            return Center(
                              child: Text("Error"),
                            );
                          },
                        );
                    }
                  })
              : FutureBuilder(
                  future:
                      Provider.of<APIHelper>(context).fetchCityDetailsByState(
                    stateCode: _chosenStateCode,
                    keywords: _keyword,
                  ),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                            width: 100,
                            margin: EdgeInsets.only(top: 20),
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.grey,
                              // color: Colors.black,
                            ),
                          ),
                        );

                        break;
                      default:
                        if (snapshot.hasError) {
                          return Container(
                            child: Text(snapshot.error.toString()),
                          );
                        }
                        if (snapshot.data.length != 0) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemCount: snapshot.data.length,
                            itemBuilder: (content, i) => ListTile(
                              trailing: CurrentUser.language == 'Arabic'
                                  ? null
                                  : Icon(Icons.arrow_right),
                              leading: CurrentUser.language == 'Arabic'
                                  ? Icon(Icons.arrow_left)
                                  : null,
                              // trailing: Icon(Icons.arrow_right),
                              title: Text(
                                snapshot.data[i]['name'],
                                textAlign: CurrentUser.language == 'Arabic'
                                    ? TextAlign.end
                                    : TextAlign.start,
                              ),
                              onTap: () async {
                                _chosenCityName = snapshot.data[i]['name'];
                                _chosenCityCode = snapshot.data[i]['id'];
                                if (!CurrentUser.uploadingAd) {
                                  CurrentUser.location.name =
                                      '$_chosenCityName, $_chosenStateName';
                                  CurrentUser.location.cityId = _chosenCityCode;
                                  CurrentUser.location.cityName =
                                      _chosenCityName;
                                  CurrentUser.location.stateId =
                                      _chosenStateCode;
                                  CurrentUser.location.stateName =
                                      _chosenStateName;
                                  CurrentUser.location.cityState =
                                      '$_chosenCityName, $_chosenStateName';

                                  await DBHelper.update('user_info', {
                                    'id': CurrentUser.id,
                                    'locationName': CurrentUser.location.name,
                                    'locationCityId':
                                        CurrentUser.location.cityId,
                                    'locationCityName':
                                        CurrentUser.location.cityName,
                                    'locationStateId':
                                        CurrentUser.location.stateId,
                                    'locationStateName':
                                        CurrentUser.location.stateName,
                                    'locationCityState':
                                        CurrentUser.location.cityState,
                                  });
                                  productsProvider.clearProductsCache();

                                  Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      TabsScreen.routeName,
                                      (Route<dynamic> route) => false);
                                } else {
                                  // CurrentUser.prodLocation.name =
                                  //     '$_chosenCityName, ${_chosenStateName}';
                                  // CurrentUser.prodLocation.cityId =
                                  //     _chosenCityCode;
                                  // CurrentUser.prodLocation.cityName =
                                  //     _chosenCityName;
                                  // CurrentUser.prodLocation.stateId =
                                  //     _chosenStateCode;
                                  // CurrentUser.prodLocation.stateName =
                                  //     _chosenStateName;
                                  // CurrentUser.prodLocation.cityState =
                                  //     '$_chosenCityName, $_chosenStateName';
                                  // CurrentUser.prodLocation.longitude =
                                  //     snapshot.data[i]['longitude'];
                                  // CurrentUser.prodLocation.latitude =
                                  //     snapshot.data[i]['latitude'];

                                  Provider.of<CurrentUser>(context,
                                          listen: false)
                                      .setProductLocation(
                                    prodCityId: _chosenCityCode,
                                    prodCityName: _chosenCityName,
                                    prodCityState:
                                        '$_chosenCityName, $_chosenStateName',
                                    prodCountryCode: _chosenCountryCode,
                                    prodCountryName: _chosenCountryName,
                                    prodLatitude: snapshot.data[i]['latitude'],
                                    prodLocationName:
                                        '${snapshot.data[i]['name']}, $_chosenStateName',
                                    prodLongitude: snapshot.data[i]
                                        ['longitude'],
                                    prodStateId: _chosenStateCode,
                                    prodStateName: _chosenStateName,
                                  );

                                  CurrentUser.uploadingAd = false;
                                  // close(context, snapshot.data[i].name);
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          );
                        } else {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context).primaryColor)),
                                  onPressed: () => Navigator.of(context)
                                      .pushReplacementNamed(
                                          TabsScreen.routeName),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "No Info about cities move to Home",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white,
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          );
                        }
                    }
                  }),
    );
  }
}
