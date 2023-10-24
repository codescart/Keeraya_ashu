import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

import './product_item.dart';
import '../helpers/ad_manager.dart';
import '../helpers/app_config.dart';

class GridProducts extends StatefulWidget {
  final productsList;
  final bool isMyAds;

  GridProducts({
    this.productsList,
    this.isMyAds = false,
  });

  @override
  _GridProductsState createState() => _GridProductsState();
}

class _GridProductsState extends State<GridProducts> {
  //! # native_admob_flutter: ^1.5.0+1 deprecated
  // final controller = NativeAdController();
//! # native_admob_flutter: ^1.5.0+1 deprecated
  // @override
  // void dispose() {
  //   if (AppConfig.googleBannerOn) controller.dispose();
  //   super.dispose();
  // }
//! # native_admob_flutter: ^1.5.0+1 deprecated
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   if (AppConfig.googleBannerOn) {
  //     controller.load(keywords: ['valorant', 'games', 'fortnite']);
  //     controller.onEvent.listen((event) {
  //       if (event.keys.first == NativeAdEvent.loaded) {
  //         setState(() {});
  //       }
  //     });
  //   }
  // }
//! # native_admob_flutter: ^1.5.0+1 deprecated
  Widget _getAdContainer() {
    // return AppConfig.googleBannerOn
    //     ? Container(
    //         child: controller.isLoaded
    //             ? AdManager.nativeAdsView()
    //             : Container(
    //                 child: Text("Banner"),
    //               ),
    //       )
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

  @override
  Widget build(BuildContext context) {
    final unescape = HtmlUnescape();
    return ListView.builder(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: (widget.productsList.length / 8).ceil(),
      itemBuilder: (_, index) {
        return Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: index == (widget.productsList.length / 8).ceil() - 1 &&
                      widget.productsList.length % 8 != 0
                  ? widget.productsList.length % 8
                  : 8,
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 3 / 5,
              ),
              itemBuilder: (ctx, i) {
                List<String> locations = [
                  widget.productsList[i + 8 * index]['location'],
                  widget.productsList[i + 8 * index]['cityid'],
                  widget.productsList[i + 8 * index]['state']
                ];
                locations
                    .removeWhere((element) => element == null || element == '');
                locations.join(',');
                print(
                    "GRID_PRODUCTS prduct item: ${widget.productsList[i + 8 * index]}");
                return ProductItem(
                  id: widget.productsList[i + 8 * index]['id'] == null
                      ? ''
                      : widget.productsList[i + 8 * index]['id'],
                  name:
                      widget.productsList[i + 8 * index]['product_name'] == null
                          ? widget.productsList[i + 8 * index]['title'] == null
                              ? ""
                              : widget.productsList[i + 8 * index]['title']
                          : widget.productsList[i + 8 * index]['product_name'],
                  imageUrl:
                      widget.productsList[i + 8 * index]['images'] == null ||
                              widget.productsList[i + 8 * index]['images'] == []
                          ? widget.productsList[i + 8 * index]['picture'] ?? ''
                          : widget.productsList[i + 8 * index]
                                  ['small_images_path'] +
                              widget.productsList[i + 8 * index]['images'][0],
                  price: double.parse(
                      widget.productsList[i + 8 * index]['price'] == null
                          ? '0'
                          : widget.productsList[i + 8 * index]['price']),
                  location: locations.join(', '),
                  isFeatured:
                      widget.productsList[i + 8 * index]['featured'] == '1'
                          ? true
                          : false,
                  isUrgent: widget.productsList[i + 8 * index]['urgent'] == '1'
                      ? true
                      : false,
                  currency: unescape.convert(
                      widget.productsList[i + 8 * index]['currency'] == null
                          ? ''
                          : widget.productsList[i + 8 * index]['currency']),
                  isOnMyAdsScreen: widget.isMyAds,
                  status: widget.productsList[i + 8 * index]['status'],
                );
              },
            ),
            if (index != (widget.productsList.length / 8).ceil() - 1 ||
                widget.productsList.length % 8 == 0)
              _getAdContainer(),
          ],
        );
      },
    );
  }
}
