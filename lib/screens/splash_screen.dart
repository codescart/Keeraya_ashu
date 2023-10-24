import 'package:keeraya/helpers/api_helper.dart';
import 'package:keeraya/helpers/current_user.dart';
import 'package:keeraya/models/location.dart';
import 'package:keeraya/providers/languages.dart';
import 'package:keeraya/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplasScreenPage extends StatefulWidget {
  @override
  _SplasScreenPageState createState() => _SplasScreenPageState();
}

class _SplasScreenPageState extends State<SplasScreenPage> {
  var STEP_COUNTRY = 0;
  var STEP_STATE = 1;
  var STEP_CITY = 2;
  var currentStep = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  _fetchData(int step) {
    if (step == STEP_COUNTRY) {
      return Provider.of<APIHelper>(context, listen: false)
          .fetchCountryDetails();
    }
    if (step == STEP_STATE) {
      return Provider.of<APIHelper>(context, listen: false)
          .fetchStateDetailsByCountry(
              countryCode: CurrentUser.location.countryCode);
    }

    if (step == STEP_CITY) {
      return Provider.of<APIHelper>(context, listen: false)
          .fetchCityDetailsByState(
              stateCode: CurrentUser.location.stateId,
              isFilter: false,
              keywords: '');
    }

    return Provider.of<APIHelper>(context, listen: false).fetchCountryDetails();
  }

  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    return Material(
        child: Scaffold(
            body: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 64, bottom: 32),
                        child: Text(langPack['Select language']),
                      ),
                      FutureBuilder(
                          future: _fetchData(currentStep),
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
                                    itemBuilder: (content, i) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 16),
                                          child: Card(
                                            child: ListTile(
                                              onTap: () {
                                                if (currentStep ==
                                                    STEP_COUNTRY) {
                                                  CurrentUser.location =
                                                      new Location(
                                                          name: snapshot.data[i]
                                                              ['name'],
                                                          countryCode: snapshot
                                                              .data[i]['code']);
                                                } else if (currentStep ==
                                                    STEP_STATE) {
                                                  CurrentUser.location.stateId =
                                                      snapshot.data[i].code;
                                                  CurrentUser.location.name =
                                                      snapshot.data[i].name;
                                                  print(
                                                      "state ${CurrentUser.location.stateId} | ${CurrentUser.location.name}");
                                                } else if (currentStep ==
                                                    STEP_CITY) {
                                                  CurrentUser.location.cityId =
                                                      snapshot.data[i]['code'];
                                                  CurrentUser
                                                          .location.cityName =
                                                      snapshot.data[i]['name'];
                                                  Navigator.of(context)
                                                      .pushAndRemoveUntil(
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    TabsScreen(
                                                              title:
                                                                  'Classified',
                                                            ),
                                                          ),
                                                          (Route<dynamic>
                                                                  route) =>
                                                              false);
                                                }
                                                if (currentStep != STEP_CITY) {
                                                  setState(() {
                                                    currentStep++;
                                                    print("STEP $currentStep");
                                                  });
                                                }
                                              },
                                              title: Center(
                                                  child: Text(parseData(i,
                                                      currentStep, snapshot))),
                                            ),
                                          ),
                                        ));
                            }
                          }),
                    ],
                  ),
                ))));
  }

  String parseData(int i, int step, AsyncSnapshot<dynamic> snapshot) {
    try {
      if (step == STEP_STATE) return snapshot.data[i].name;
      return snapshot.data[i]['name'];
    } catch (e) {
      print(e);
      return "";
    }
  }
}
