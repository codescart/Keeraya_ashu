import 'package:keeraya/helpers/app_config.dart';
import 'package:keeraya/screens/color_helper.dart';
import 'package:keeraya/screens/tabs_screen.dart';
import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:provider/provider.dart';

import './location_search_screen.dart';
import '../helpers/ad_manager.dart';
import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../providers/languages.dart';
import '../widgets/product_item.dart';

class SearchAdScreen extends StatefulWidget {
  static const routeName = '/search-ad';

  @override
  _SearchAdScreenState createState() => _SearchAdScreenState();
}

class _SearchAdScreenState extends State<SearchAdScreen> {
  final unescape = HtmlUnescape();
  List foundProducts = [];
  String _keywords = '';
  String _sortingOrder = '';
  String _sortingType = '';
  var _scrollController = ScrollController();
  int _listLength = 1;
  int productLimit = 8;
  bool firstBuild = true;
  bool isOnBottom = false;
  bool allPagesAreFetched = false;
  bool loadingNewPage = false;
  int page = 1;

  Future onBack(value) async {
    setState(() {});
  }

  // final controller = NativeAdController();

  Widget _getAdContainer() {
    //! # native_admob_flutter: ^1.5.0+1 deprecated
    // return AppConfig.googleBannerOn
    //     ? Container(
    //   child: controller.isLoaded
    //       ? AdManager.nativeAdsView()
    //       : Container(
    //     child: Text("Banner"),
    //   ),
    // )
    return AppConfig.googleBannerOn
        ? Container(
            child: Text("Banner"),
          )
        : Container(
            alignment: Alignment(0.5, 1),
            child: FacebookNativeAd(
              //need a new placement id for advanced native ads
              placementId: AdManager.fbNativePlacementId,
              adType: NativeAdType.NATIVE_AD,
              listener: (result, value) {
                print("Native Banner Ad: $result --> $value");
              },
            ),
          );
  }

  //  @override
  // void dispose() {
  //   if (AppConfig.googleBannerOn) controller.dispose();
  //   super.dispose();
  // }

  @override
  void initState() {
    super.initState();

    // if (AppConfig.googleBannerOn) {
    //   controller.load(keywords: ['valorant', 'games', 'fortnite']);
    //   controller.onEvent.listen((event) {
    //     if (event.keys.first == NativeAdEvent.loaded) {
    //       setState(() {});
    //     }

    //   });
    // }

    _scrollController.addListener(() async {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
          // You're at the top.
        } else {
          // You're at the bottom.
          print('Congrats... you reached the bottom....');
          if (!allPagesAreFetched && !loadingNewPage) {
            page++;
            List newProducts = [];
            setState(() {
              loadingNewPage = true;
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
              );
            });
            newProducts = await Provider.of<APIHelper>(context, listen: false)
                .fetchProductsByKeywords(
              page: page,
              limit: productLimit,
              keywords: _keywords,
              order: _sortingOrder,
              sort: _sortingType,
              city: CurrentUser.location.cityId,
              state: CurrentUser.location.stateId,
              countryCode: CurrentUser.location.countryCode,
            );
            await getLocationForProductItem(newProducts);
            setState(() {});
            setState(() {
              loadingNewPage = false;
            });
            if (newProducts.length > 0) {
              foundProducts.addAll(newProducts);
              setState(() {
                _listLength++;
              });
            } else {
              allPagesAreFetched = true;
            }
          }
        }
      }
      // if (_scrollController.position.pixels ==
      //     _scrollController.position.maxScrollExtent) {
      //   // Perform your task
      //   // You're at the bottom.
      //   print('Congrats... you reached the bottom....');
      //   _listLength++;
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    if (loadingNewPage) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130),
        child: SafeArea(
          child: AppBar(
            shape: AppBarBottomShape(),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () async {
                Navigator.pushNamedAndRemoveUntil(context, TabsScreen.routeName,
                    (Route<dynamic> route) => false);
              },
            ),

            iconTheme: IconThemeData(color: Colors.white),
            flexibleSpace: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                        labelText: langPack['Enter your keyword to search'],
                        suffixIcon: Icon(Icons.search, color: Colors.grey),
                      ),
                      onChanged: (value) async {
                        setState(() {
                          _keywords = value;
                          firstBuild = false;
                        });
                        List newProducts = [];
                        newProducts =
                            await Provider.of<APIHelper>(context, listen: false)
                                .fetchProductsByKeywords(
                          page: page,
                          limit: productLimit,
                          keywords: value,
                          order: _sortingOrder,
                          // DESC
                          sort: _sortingType,
                          city: CurrentUser.location.cityId,
                          state: CurrentUser.location.stateId,
                          countryCode: CurrentUser.location.countryCode,
                        );
                        print(
                            '-------------------------------------------------------');
                        print('newProducts: ${newProducts.length}');
                        setState(() {
                          firstBuild = true;
                        });
                        setState(() {
                          if (newProducts.length > 0) {
                            foundProducts = newProducts;
                            if (value != null || value != '') {
                              // _listLength++;
                            }
                          } else {
                            foundProducts = [];
                          }
                        });
                        getLocationForProductItem(newProducts).then((value) {
                          setState(() {});
                        });
                      }),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          // print('Tapped the search bar');
                          //CurrentUser.uploadingAd = true;
                          CurrentUser.fromSearchScreen = true;
                          // showSearch(
                          //         context: context, delegate: LocationSearch())
                          //     .then(onBack);
                          await Navigator.of(context)
                              .pushNamed(LocationSearchScreen.routeName);
                          setState(() {});
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                width: 1,
                                color: Colors.grey[800],
                              )),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.grey[600],
                              ),
                              Flexible(
                                child: Consumer<CurrentUser>(
                                    key: ValueKey('PostSearchLocationKey'),
                                    child: Text(
                                      langPack['Location'],
                                      textDirection: CurrentUser.textDirection,
                                    ),
                                    builder: (ctx, data, child) {
                                      print(
                                          'CurrentUser.location.name: ${CurrentUser.location.name}');
                                      if (CurrentUser.location.name != null ||
                                          CurrentUser.location.name != '') {
                                        return Text(
                                            '${CurrentUser.location.name}');
                                      }
                                      if (data.prodLocationGetter.name == '') {
                                        return child;
                                      }
                                      return Text(data.prodLocationGetter.name);
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        var result = await showDialog(
                          context: context,
                          builder: (ctx) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      langPack['Sort by'],
                                      textDirection: CurrentUser.textDirection,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    Divider(),
                                    ListTile(
                                      onTap: () {
                                        Navigator.of(context).pop({
                                          'sortingOrder': 'DESC',
                                          'sortingType': 'date',
                                        });
                                      },
                                      title: Text(
                                        langPack['Newest to Oldest'],
                                        textDirection:
                                            CurrentUser.textDirection,
                                      ),
                                      trailing: Icon(
                                        Icons.access_time,
                                      ),
                                    ),
                                    ListTile(
                                      onTap: () {
                                        Navigator.of(context).pop({
                                          'sortingOrder': '',
                                          'sortingType': 'date',
                                        });
                                      },
                                      title: Text(
                                        langPack['Oldest to Newest'],
                                        textDirection:
                                            CurrentUser.textDirection,
                                      ),
                                      trailing: Icon(
                                        Icons.access_time,
                                      ),
                                    ),
                                    ListTile(
                                      onTap: () {
                                        Navigator.of(context).pop({
                                          'sortingOrder': 'DESC',
                                          'sortingType': 'price',
                                        });
                                      },
                                      title: Text(
                                        langPack['Price Highest to Lowest'],
                                        textDirection:
                                            CurrentUser.textDirection,
                                      ),
                                      trailing: Icon(
                                        Icons.trending_down,
                                      ),
                                    ),
                                    ListTile(
                                      onTap: () {
                                        Navigator.of(context).pop({
                                          'sortingOrder': '',
                                          'sortingType': 'price',
                                        });
                                      },
                                      title: Text(
                                        langPack['Price Lowest to Highest'],
                                        textDirection:
                                            CurrentUser.textDirection,
                                      ),
                                      trailing: Icon(
                                        Icons.trending_up,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                        if (result != null) {
                          setState(() {
                            _sortingOrder = result['sortingOrder'];
                            _sortingType = result['sortingType'];
                          });

                          List newProducts = [];
                          newProducts = await Provider.of<APIHelper>(context,
                                  listen: false)
                              .fetchProductsByKeywords(
                            page: page,
                            limit: productLimit,
                            keywords: _keywords,
                            order: _sortingOrder,
                            // DESC
                            sort: _sortingType,
                            city: CurrentUser.location.cityId,
                            state: CurrentUser.location.stateId,
                            countryCode: CurrentUser.location.countryCode,
                          );
                          print(
                              '-------------------------------------------------------');
                          print('newProducts: ${newProducts.length}');
                          setState(() {
                            firstBuild = true;
                          });
                          setState(() {
                            if (newProducts.length > 0) {
                              foundProducts = newProducts;
                            } else {
                              foundProducts = [];
                            }
                          });
                          getLocationForProductItem(newProducts).then((value) {
                            setState(() {});
                          });
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          right: 10,
                        ),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              width: 1,
                              color: Colors.grey[800],
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.sort,
                              color: Colors.grey[600],
                            ),
                            Text('Sort'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            //title: Text('Home Tab'),
            backgroundColor: HexColor(),
            elevation: 2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: _listLength,
              itemBuilder: (ctx, i) {
                if (!firstBuild)
                  print('-----------NOT FIRST BUILD------------');
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!firstBuild)
                      GridView.builder(
                        itemCount: foundProducts.length % productLimit == 0
                            ? productLimit
                            : foundProducts.length < productLimit
                                ? foundProducts.length
                                : i == _listLength - 1
                                    ? foundProducts.length - i * productLimit
                                    : productLimit,
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        padding: EdgeInsets.all(10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 3 / 5,
                        ),
                        itemBuilder: (ctx, index) {
                          if (foundProducts.isNotEmpty) {
                            return ProductItem(
                              id: foundProducts[i * productLimit + index]
                                          ['id'] ==
                                      null
                                  ? ''
                                  : foundProducts[i * productLimit + index]
                                      ['id'],
                              isHighlighted:
                                  foundProducts[i * productLimit + index]
                                              ['highlight'] ==
                                          null
                                      ? false
                                      : foundProducts[i * productLimit + index]
                                                  ['highlight'] ==
                                              '1'
                                          ? true
                                          : false,
                              name: foundProducts[i * productLimit + index]
                                          ['product_name'] ==
                                      null
                                  ? ''
                                  : foundProducts[i * productLimit + index]
                                      ['product_name'],
                              imageUrl: foundProducts[i * productLimit + index]
                                          ['picture'] ==
                                      null
                                  ? ''
                                  : foundProducts[i * productLimit + index]
                                      ['picture'],
                              price: double.parse(
                                  foundProducts[i * productLimit + index]
                                              ['price'] ==
                                          null
                                      ? '0'
                                      : foundProducts[i * productLimit + index]
                                          ['price']),
                              location: foundProducts[i * productLimit + index]
                                      ['location'] ??
                                  foundProducts[i * productLimit + index]
                                      ['city'] ??
                                  CurrentUser.prodLocation.name ??
                                  '',
                              isFeatured:
                                  foundProducts[i * productLimit + index]
                                              ['featured'] ==
                                          '1'
                                      ? true
                                      : false,
                              isUrgent: foundProducts[i * productLimit + index]
                                          ['urgent'] ==
                                      '1'
                                  ? true
                                  : false,
                              currency: unescape.convert(
                                  foundProducts[i * productLimit + index]
                                              ['currency'] ==
                                          null
                                      ? ''
                                      : foundProducts[i * productLimit + index]
                                          ['currency']),
                            );
                          }
                          return Container();

                          // return Container();
                        },
                      ),
                    if (firstBuild)
                      FutureBuilder(
                        future: Provider.of<APIHelper>(
                          context,
                          listen: false,
                        ).fetchProductsByKeywords(
                          page: page,
                          limit: productLimit,
                          keywords: _keywords,
                          order: _sortingOrder,
                          sort: _sortingType,
                          city: CurrentUser.location.cityId,
                          state: CurrentUser.location.stateId,
                          countryCode: CurrentUser.location.countryCode,
                        ),
                        builder: (ctx, snapshot) {
                          firstBuild = false;
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                              return Center(
                                child: Container(
                                  width: 100,
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.grey,
                                  ),
                                ),
                              );
                              break;
                            default:
                              if (snapshot.hasError) {
                                return Container(
                                    child: Text(snapshot.error.toString()));
                              }
                              if (snapshot.data.length < productLimit) {
                                allPagesAreFetched = true;
                              }
                              if (snapshot.data.length > 0) {
                                foundProducts.addAll(snapshot.data);
                                getLocationForProductItem(foundProducts)
                                    .then((value) {
                                  setState(() {});
                                });
                                return GridView.builder(
                                  itemCount: snapshot.data.length,
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  padding: EdgeInsets.all(10),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: 3 / 5,
                                  ),
                                  itemBuilder: (ctx, index) {
                                    return ProductItem(
                                      id: snapshot.data[i * productLimit +
                                                  index]['id'] ==
                                              null
                                          ? ''
                                          : snapshot.data[
                                              i * productLimit + index]['id'],
                                      isHighlighted: snapshot.data[
                                                      i * productLimit + index]
                                                  ['highlight'] ==
                                              null
                                          ? false
                                          : snapshot.data[i * productLimit +
                                                      index]['highlight'] ==
                                                  '1'
                                              ? true
                                              : false,
                                      name: snapshot.data[i * productLimit +
                                                  index]['product_name'] ==
                                              null
                                          ? ''
                                          : snapshot.data[i * productLimit +
                                              index]['product_name'],
                                      imageUrl: snapshot.data[i * productLimit +
                                                  index]['picture'] ==
                                              null
                                          ? ''
                                          : snapshot.data[i * productLimit +
                                              index]['picture'],
                                      price: double.parse(snapshot.data[
                                                      i * productLimit + index]
                                                  ['price'] ==
                                              null
                                          ? '0'
                                          : snapshot.data[i * productLimit +
                                              index]['price']),
                                      location: snapshot.data[i * productLimit +
                                              index]['location'] ??
                                          snapshot.data[i * productLimit +
                                              index]['city'] ??
                                          CurrentUser.prodLocation.name ??
                                          '',
                                      isFeatured: snapshot.data[
                                                      i * productLimit + index]
                                                  ['featured'] ==
                                              '1'
                                          ? true
                                          : false,
                                      isUrgent: snapshot.data[i * productLimit +
                                                  index]['urgent'] ==
                                              '1'
                                          ? true
                                          : false,
                                      currency: unescape.convert(snapshot.data[
                                                      i * productLimit + index]
                                                  ['currency'] ==
                                              null
                                          ? ''
                                          : snapshot.data[i * productLimit +
                                              index]['currency']),
                                    );

                                    // return Container();
                                  },
                                );
                              }
                              return Container(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Text(langPack[
                                    'No products found, please refine your search']),
                              );
                          }
                        },
                      ),
                    _getAdContainer(),
                    if (loadingNewPage)
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 30),
                          width: 100,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.grey,
                            // color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getLocationForProductItem(List<dynamic> list) async {
    if (list.isNotEmpty) {
      for (int i = 0; i < list.length; i++) {
        final response = await Provider.of<APIHelper>(context, listen: false)
            .fetchProductsDetails(
          itemId: list[i]['id'],
        );
        list[i]['location'] =
            response['location'] ?? '${response['city']}, ${response['state']}';
      }
    }
  }
}
