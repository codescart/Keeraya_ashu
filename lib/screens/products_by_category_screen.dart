import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './filter_screen.dart';
import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../providers/languages.dart';
import '../widgets/grid_products.dart';

class ProductsByCategoryScreen extends StatefulWidget {
  static const routeName = '/products-by-category';

  @override
  _ProductsByCategoryScreenState createState() =>
      _ProductsByCategoryScreenState();
}

class _ProductsByCategoryScreenState extends State<ProductsByCategoryScreen> {
  String _sortingOrder = '';
  List<Map> filters = [];

  String _sortingType = '';

  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    final Map<String, dynamic> pushedMap =
        ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pushedMap['chosenSubCat'] != ''
              ? pushedMap['chosenSubCat'].name
              : pushedMap['chosenCat'].name,
          style: TextStyle(
            color: Colors.grey[800],
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.grey[800],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    label: Text('Filter'),
                    icon: Icon(Icons.filter_alt_outlined),
                    onPressed: () async {
                      // final dataList = await Provider.of<APIHelper>(context)
                      //     .getCustomDataByCategory(
                      //         categoryId: pushedMap['chosenCat'].id,
                      //         subCategoryId: pushedMap['chosenSubCat'] != ''
                      //             ? pushedMap['chosenSubCat']
                      //             : '');
                      Navigator.of(context)
                          .pushNamed(FilterScreen.routeName, arguments: {
                        // 'dataList': dataList,
                        'chosenCat': pushedMap['chosenCat'],
                        'chosenSubCat': pushedMap['chosenSubCat'],
                      }).then((value) {
                        setState(() {
                          filters = value;
                        });
                      });
                    },
                  ),
                  VerticalDivider(
                    width: 10,
                    // color: Colors.white,
                    // thickness: 2,
                  ),
                  TextButton.icon(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    label: Text('Sort'),
                    icon: Icon(Icons.sort),
                    onPressed: () {
                      showDialog(
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
                                      textDirection: CurrentUser.textDirection,
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
                                      textDirection: CurrentUser.textDirection,
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
                                      textDirection: CurrentUser.textDirection,
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
                                      textDirection: CurrentUser.textDirection,
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
                      ).then((value) {
                        print(value);
                        setState(() {
                          _sortingOrder = value['sortingOrder'];
                          _sortingType = value['sortingType'];
                        });
                      });
                    },
                  ),
                ],
              ),
            ),
            FutureBuilder(
              future: Provider.of<APIHelper>(context, listen: false)
                  .fetchProductsByCategory(
                city: CurrentUser.location.cityId,
                state: CurrentUser.location.stateId,
                countryCode: CurrentUser.location.countryCode,
                categoryId: pushedMap['chosenCat'].id,
                subCategoryId: pushedMap['chosenSubCat'] != ''
                    ? pushedMap['chosenSubCat'].id
                    : '',
                filter: json.encode(filters),
                order: _sortingOrder,
                sort: _sortingType,
              ),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
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
                }
                if (snapshot.data != null && snapshot.data.length > 0) {
                  return GridProducts(
                    productsList: snapshot.data,
                  );
                }
                return Center(
                  child: Text(
                    langPack['No products found, please refine your search'],
                    textDirection: CurrentUser.textDirection,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
