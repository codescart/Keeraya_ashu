import 'package:keeraya/helpers/app_config.dart';
import 'package:keeraya/helpers/db_helper.dart';
import 'package:keeraya/screens/color_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../providers/languages.dart';
import '../providers/products.dart';
import '../screens/membership_plan_screen.dart';
import '../widgets/grid_products.dart';
import '../widgets/my_product_item.dart';

class NotificationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context, listen: false).selected;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          shape: AppBarBottomShape(),
          iconTheme: IconThemeData(
            color: Colors.grey[800],
          ),
          elevation: 2,
          backgroundColor: HexColor(),
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 4,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            tabs: [
              Tab(
                text: 'ADS',
              ),
              Tab(
                text: 'FAVOURITES',
              ),
            ],
          ),
          title: Text(
            langPack['My Ads'],
            textDirection: CurrentUser.textDirection,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: TabBarView(
          children: [
            MyAds(),
            FavoriteAds(),
          ],

          // body: ListView.builder(
          //     itemCount: 4,
          //     itemBuilder: (ctx, i) => ListTile(
          //           onTap: () {
          //             Navigator.of(context)
          //                 .pushNamed(ChatScreen.routeName, arguments: i + 1);
          //           },
          //           leading: CircleAvatar(
          //             child: Icon(Icons.person),
          //           ),
          //           title: Text('Name Surname ${i + 1}'),
          //         )),
        ),
      ),
    );
  }
}

class MyAds extends StatefulWidget {
  @override
  _MyAdsState createState() => _MyAdsState();
}

class _MyAdsState extends State<MyAds> {
  List myProducts = [];
  final _pageSize = 8;
  var _scrollController = ScrollController();
  int _listLength = 1;
  int productLimit = 8;
  bool firstBuild = true;
  bool isOnBottom = false;
  bool allPagesAreFetched = false;
  bool loadingNewPage = false;
  int page = 1;
  AppConfig appConfig = AppConfig();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("highlightFee");
    print(AppConfig.highlightFee);
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
                .fetchProductsForUser(
              userId: CurrentUser.id,
              limit: productLimit,
              page: page,
            );
            setState(() {
              loadingNewPage = false;
            });
            if (newProducts.length > 0) {
              for (int i = 0; i < newProducts.length; i++) {
                myProducts.add(newProducts[i]);
              }
              setState(() {
                _listLength++;
              });
            } else {
              allPagesAreFetched = true;
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context, listen: false).selected;
    final apiHelper = Provider.of<APIHelper>(context, listen: false);
    final productsProvider = Provider.of<Products>(context);

    if (myProducts.length == 0) {
      myProducts = productsProvider.myProductsItems;
      firstBuild = myProducts.length == 0 ? true : false;
    }

    if (loadingNewPage) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
    }
    if (CurrentUser.isLoggedIn) {
      return RefreshIndicator(
        onRefresh: () {
          setState(() {
            productsProvider.myProducts = [];
            myProducts = [];
            _listLength = 1;
            firstBuild = true;
            page = 1;
            allPagesAreFetched = false;
          });
          return Future.delayed(Duration(milliseconds: 400));
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!firstBuild)
                ListView.builder(
                  itemCount: myProducts.length,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemBuilder: (ctx, i) {
                    List<String> locations = [
                      myProducts[i]['city'],
                      myProducts[i]['state']
                    ];
                    locations.removeWhere(
                        (element) => element == null || element == '');
                    locations.join(',');
                    return Column(
                      children: [
                        if (i == 0)
                          Container(
                            margin: EdgeInsets.only(
                              top: 10,
                              left: 10,
                              right: 10,
                            ),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.blueAccent,
                            ),
                            child: Row(
                              textDirection: CurrentUser.textDirection,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Heavy discount on Packages',
                                    softWrap: true,
                                    maxLines: null,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                TextButton(
                                  child: Text(
                                    'View Packages',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                        MembershipPlanScreen.routeName);
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        side: BorderSide(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        MyProductItem(
                          parent: this,
                          stateId: myProducts[i]['stateid'].toString(),
                          cityId: myProducts[i]['cityid'].toString(),
                          picture: myProducts[i]['picture'].toString(),
                          currencySign: myProducts[i]['currency'] ?? "₹",
                          location: locations.join(", "),
                          id: myProducts[i]['id'].toString(),
                          name: myProducts[i]['product_name'].toString(),
                          createdAt: myProducts[i]['created_at'].toString(),
                          expireAt: myProducts[i]['expire_date'].toString(),
                          price: myProducts[i]['price'].toString(),
                          status: myProducts[i]['status'].toString(),
                        ),
                        if (i == myProducts.length - 1)
                          SizedBox(
                            height: 20,
                          ),
                      ],
                    );
                  },
                ),
              if (firstBuild)
                FutureBuilder(
                  future: apiHelper.fetchProductsForUser(
                      userId: CurrentUser.id, limit: productLimit, page: page),
                  builder: (ctx, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                            width: 100,
                            margin: EdgeInsets.only(top: 10),
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.grey,
                              // color: Colors.black,
                            ),
                          ),
                        );
                        break;
                      default:
                        firstBuild = false;
                        if (snapshot.hasError) {
                          return Container(
                            child: Text(snapshot.error.toString()),
                          );
                        }
                        if (snapshot.data.length < productLimit) {
                          allPagesAreFetched = true;
                        }
                        if (snapshot.data.length > 0) {
                          myProducts.addAll(snapshot.data);
                          productsProvider.myProducts = myProducts;

                          return ListView.builder(
                            // controller: _scrollController,
                            itemCount: snapshot.data.length,
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemBuilder: (ctx, i) {
                              print('${snapshot.data[i]}');
                              List<String> locations = [
                                snapshot.data[i]['city'],
                                snapshot.data[i]['state']
                              ];
                              locations.removeWhere((element) =>
                                  element == null || element == '');
                              locations.join(',');
                              print("Le produit personnel");
                              print(snapshot.data[i]);
                              return Column(
                                children: [
                                  if (i == 0)
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 10,
                                        left: 10,
                                        right: 10,
                                      ),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.blueAccent,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Heavy discount on Packages',
                                              softWrap: true,
                                              maxLines: null,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            child: Text(
                                              'View Packages',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(
                                                  MembershipPlanScreen
                                                      .routeName);
                                            },
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  side: BorderSide(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  MyProductItem(
                                    parent: this,
                                    stateId:
                                        myProducts[i]['stateid'].toString(),
                                    cityId: myProducts[i]['cityid'].toString(),
                                    picture:
                                        myProducts[i]['picture'].toString(),
                                    currencySign:
                                        myProducts[i]['currency'] ?? "₹",
                                    location: locations.join(", "),
                                    id: myProducts[i]['id'].toString(),
                                    name: myProducts[i]['product_name']
                                        .toString(),
                                    createdAt:
                                        myProducts[i]['created_at'].toString(),
                                    expireAt:
                                        myProducts[i]['expire_date'].toString(),
                                    price: myProducts[i]['price'].toString(),
                                    status: myProducts[i]['status'].toString(),
                                  ),
                                  if (i == snapshot.data.length - 1)
                                    SizedBox(
                                      height: 20,
                                    ),
                                ],
                              );
                            },
                          );
                        }
                    }
                    return Center(
                        child: Text(
                      langPack['No products found, please refine your search'],
                      textDirection: CurrentUser.textDirection,
                    ));
                  },
                ),
              if (loadingNewPage)
                Center(
                  child: Container(
                    width: 100,
                    margin: EdgeInsets.only(bottom: 30),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey,
                      // color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      return Center(
          child: Text(
        langPack['You must be logged in to use this feature'],
        textDirection: CurrentUser.textDirection,
      ));
    }
  }
}

class FavoriteAds extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context, listen: false).selected;
    final apiHelper = Provider.of<APIHelper>(context, listen: false);
    Future getProducts() async {
      List<Map<String, dynamic>> productIdList =
          await DBHelper.queryFavProduct(DBHelper.favTableName, "NOT NULL");
      List<dynamic> result = [];
      for (int i = 0; i < productIdList.length; i++) {
        result.add(
          await apiHelper.fetchProductsDetails(
            itemId: productIdList[i]["prodId"],
          ),
        );
      }
      return result;
    }

    return FutureBuilder(
      future: getProducts(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              width: 100,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey,
                // color: Colors.black,
              ),
            ),
          );
        }
        if (snapshot.data.length > 0) {
          return GridProducts(
            productsList: snapshot.data,
            isMyAds: false,
          );
        }
        return Center(
            child: Text(
          langPack['No products found, please refine your search'],
          textDirection: CurrentUser.textDirection,
        ));
      },
    );
  }
}
