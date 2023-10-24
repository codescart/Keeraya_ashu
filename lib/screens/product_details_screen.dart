import 'dart:async';

import 'package:keeraya/screens/color_helper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import './chat_screen.dart';
import './payment_methods_screen.dart';
import './seller_details_screen.dart';
import './start_screen.dart';
import '../helpers/ad_manager.dart';
import '../helpers/api_helper.dart';
import '../helpers/app_config.dart';
import '../helpers/current_user.dart';
import '../helpers/db_helper.dart';
import '../providers/languages.dart';
import '../widgets/offer_dialog.dart';
import '../widgets/product_item.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const routeName = '/item-details';

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final unescape = HtmlUnescape();

  StreamSubscription _subscription;
  double _height = 0;

  // final _adUnitId = 'ca-app-pub-9259101471660565/8555196884';
  final _adUnitId = 'ca-app-pub-3940256099942544/8135179316';
  int _pickedImageIndex = 0;
  Completer<GoogleMapController> _controller = Completer();
  final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  bool isLoaded = false;
  bool hidePhone = true;
  String phoneNumber = '';

  String adUserId = '';

  String adUserFullName = '';
  bool isFavorite = false;

  List<String> imagesList = [];

  bool myAd = false;
  String id = '';
  String title = '';

  var langPack;

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }

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

  Widget _premiumDialog(BuildContext ctx) {
    bool isFeatured = false;
    bool isUrgent = false;
    bool isHighlighted = false;
    int price = 0;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: StatefulBuilder(
        builder: (ctx, setState) => Container(
          padding: EdgeInsets.only(
              left: Constants.padding,
              top: Constants.padding,
              right: Constants.padding,
              bottom: Constants.padding),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                langPack['Awesome!! You are just one step away from Premium'],
                textDirection: CurrentUser.textDirection,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              if (isFeatured || isUrgent || isHighlighted)
                Text(
                  '${langPack['Total price']} ${AppConfig.currencySign}$price',
                  textDirection: CurrentUser.textDirection,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.lightGreen,
                  ),
                ),
              Divider(
                height: 20,
                color: Colors.grey[800],
              ),
              Column(
                children: [
                  ListTile(
                    leading: Icon(
                      isFeatured
                          ? Icons.check_circle_outline
                          : Icons.add_circle_outline,
                      size: 35,
                      color: isFeatured ? Colors.lightGreen : Colors.amber,
                    ),
                    title: Text(
                      langPack['Featured'],
                      textDirection: CurrentUser.textDirection,
                    ),
                    onTap: () {
                      setState(() {
                        isFeatured = !isFeatured;
                        if (isFeatured) {
                          price += 5;
                        } else {
                          price -= 5;
                        }
                      });
                    },
                    subtitle: Text(
                      langPack[
                          'Featured ads attract higher-quality viewer and are displayed prominently in the Featured ads section home page'],
                      textDirection: CurrentUser.textDirection,
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      isUrgent
                          ? Icons.check_circle_outline
                          : Icons.add_circle_outline,
                      size: 35,
                      color: isUrgent ? Colors.lightGreen : Colors.amber,
                    ),
                    title: Text(
                      langPack['Urgent'],
                      textDirection: CurrentUser.textDirection,
                    ),
                    onTap: () {
                      setState(() {
                        isUrgent = !isUrgent;
                        if (isUrgent) {
                          price += 5;
                        } else {
                          price -= 5;
                        }
                      });
                    },
                    subtitle: Text(
                      langPack[
                          'Make your ad stand out and let viewer know that your advertise is time sensitive'],
                      textDirection: CurrentUser.textDirection,
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      isHighlighted
                          ? Icons.check_circle_outline
                          : Icons.add_circle_outline,
                      size: 35,
                      color: isHighlighted ? Colors.lightGreen : Colors.amber,
                    ),
                    title: Text(
                      langPack['Highlighted'],
                      textDirection: CurrentUser.textDirection,
                    ),
                    onTap: () {
                      setState(() {
                        isHighlighted = !isHighlighted;
                        if (isHighlighted) {
                          price += 5;
                        } else {
                          price -= 5;
                        }
                      });
                    },
                    subtitle: Text(
                      langPack[
                          'Make your ad highlighted with border in listing search result page. Easy to focus'],
                      textDirection: CurrentUser.textDirection,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 22,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.white,
                      ),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.grey[800]),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      langPack['Cancel'],
                      textDirection: CurrentUser.textDirection,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        HexColor(),
                      ),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pushNamed(
                          PaymentMethodsScreen.routeName,
                          arguments: {
                            'id': id,
                            'title': title,
                            'price': price.toString(),
                            'isFeatured': isFeatured,
                            'isUrgent': isUrgent,
                            'isHighlighted': isHighlighted,
                            'isSubscription': false,
                          });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        langPack['Confirm'],
                        textDirection: CurrentUser.textDirection,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // set up the buttons
  Widget cancelButton(BuildContext ctx) {
    return TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.grey[800]),
      ),
      child: Text(
        langPack['Cancel'],
        textDirection: CurrentUser.textDirection,
      ),
      onPressed: () {
        Navigator.of(ctx).pop();
      },
    );
  }

  Widget continueButton(BuildContext ctx) {
    return TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.grey[800]),
      ),
      child: Text(
        langPack['Login'],
        textDirection: CurrentUser.textDirection,
      ),
      onPressed: () async {
        Navigator.of(context).pushNamed(StartScreen.routeName);
      },
    );
  }

  //! # native_admob_flutter: ^1.5.0+1 deprecated
  // final controller = NativeAdController();

  // @override
  // void dispose() {
  //   if (AppConfig.googleBannerOn) controller.dispose();
  //   super.dispose();
  // }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   if (AppConfig.googleBannerOn) {
  //     controller.load(keywords: ['valorant', 'games', 'fortnite']);
  //     controller.onEvent.listen((event) {
  //       // if (event.keys.first == NativeAdEvent.loaded) {
  //       //   setState(() {});
  //       // }

  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    langPack = Provider.of<Languages>(context).selected;
    final Map<String, dynamic> pushedMap =
        ModalRoute.of(context).settings.arguments;
    myAd = pushedMap['myAd'] == true ? true : false;

    id = pushedMap['productId'];
    title = pushedMap['productName'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pushedMap['productName'],
          style: TextStyle(
            color: Colors.grey[800],
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
      ),
      bottomNavigationBar: !myAd
          ? Row(
              children: [
                SizedBox(
                  width: 5,
                ),
                TextButton.icon(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                        Size(MediaQuery.of(context).size.width / 2 - 7.5, 0)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(HexColor()),
                  ),
                  label: Text('Chat'),
                  icon: Icon(Icons.chat_bubble_outline),
                  onPressed: () {
                    if (isLoaded && CurrentUser.isLoggedIn) {
                      if (adUserId != CurrentUser.id) {
                        Navigator.of(context)
                            .pushNamed(ChatScreen.routeName, arguments: {
                          'from_user_id': adUserId,
                          'from_user_fullname': adUserFullName,
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('This is your ad'),
                          ),
                        );
                      }
                    } else if (!CurrentUser.isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            langPack[
                                'You must be logged in to use this feature'],
                            textDirection: CurrentUser.textDirection,
                          ),
                          action: SnackBarAction(
                            label: langPack['LOG IN'],
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(StartScreen.routeName);
                            },
                          ),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(
                  width: 5,
                ),
                TextButton.icon(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(
                        Size(MediaQuery.of(context).size.width / 2 - 7.5, 0)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor: MaterialStateProperty.all(HexColor()),
                  ),
                  label: Text('Call'),
                  icon: Icon(Icons.phone_enabled_outlined),
                  onPressed: () async {
                    if (isLoaded && !hidePhone) {
                      if (adUserId != CurrentUser.id) {
                        final Uri _emailLaunchUri = Uri(
                          scheme: 'tel',
                          path: phoneNumber,
                        );
                        await urlLauncher.canLaunch(_emailLaunchUri.toString())
                            ? await urlLauncher
                                .launch(_emailLaunchUri.toString())
                            : throw 'Could not launch ${_emailLaunchUri.toString()}';
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('This is your ad'),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('The phone number is hidden'),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(
                  width: 5,
                ),
              ],
            )
          : null,
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.grey[800],
      //   foregroundColor: Colors.white,
      //   child: Icon(Icons.chat_bubble),
      //   onPressed: () {
      //     if (isLoaded && CurrentUser.isLoggedIn) {
      //       Navigator.of(context).pushNamed(ChatScreen.routeName, arguments: {
      //         'from_user_id': adUserId,
      //         'from_user_fullname': adUserFullName,
      //       });
      //     } else if (!CurrentUser.isLoggedIn) {
      //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //         content:
      //             Text(langPack['You must be logged in to use this feature']),
      //         action: SnackBarAction(
      //           label: langPack['LOG IN'],
      //           onPressed: () {
      //             Navigator.of(context).pushNamed(StartScreen.routeName);
      //           },
      //         ),
      //       ));
      //     }
      //   },
      // ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: Provider.of<APIHelper>(context).fetchProductsDetails(
            itemId: pushedMap['productId'],
          ),
          builder: (ctx, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
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
                    child: Center(
                      child: Text(snapshot.error.toString()),
                    ),
                  );
                }
                if (snapshot.data.length > 0) {
                  print("ProductDetails snapshot: ${snapshot.data}");
                  myAd = snapshot.data['seller_id'] == CurrentUser.id;
                  adUserFullName = snapshot.data['seller_name'];
                  adUserId = snapshot.data['seller_id'];
                  isLoaded = true;
                  hidePhone =
                      snapshot.data['hide_phone'] == 'yes' ? true : false;
                  phoneNumber = snapshot.data['phone'];
                  print(snapshot.data);
                  print(snapshot.data['images'].runtimeType);
                  print(snapshot.data['original_images_path'].runtimeType);
                  return Column(
                    children: [
                      CarouselSlider(
                        items: snapshot.data['images']
                            .toList()
                            .map<Widget>((imageUrl) {
                          imagesList.add(
                              snapshot.data['original_images_path'].toString() +
                                  imageUrl.toString());
                          return GestureDetector(
                            onTap: () {
                              final _pageController = PageController(
                                  initialPage: imagesList.indexOf(snapshot
                                          .data['original_images_path']
                                          .toString() +
                                      imageUrl.toString()));
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => Scaffold(
                                    body: Container(
                                      child: PhotoViewGallery.builder(
                                        scrollPhysics:
                                            const BouncingScrollPhysics(),
                                        builder:
                                            (BuildContext context, int index) {
                                          _pickedImageIndex = index;
                                          return PhotoViewGalleryPageOptions(
                                            imageProvider:
                                                NetworkImage(imagesList[index]),
                                            initialScale: PhotoViewComputedScale
                                                    .contained *
                                                0.8,
                                            heroAttributes:
                                                PhotoViewHeroAttributes(
                                                    tag: index),
                                          );
                                        },
                                        itemCount: imagesList.length,
                                        loadingBuilder: (_, event) => Center(
                                          child: Container(
                                            width: 20.0,
                                            height: 20.0,
                                            child: Container(
                                              width: 100,
                                              child: LinearProgressIndicator(
                                                backgroundColor: Colors.grey,
                                                // color: Colors.black,
                                                value: event == null
                                                    ? 0
                                                    : event.cumulativeBytesLoaded /
                                                        event
                                                            .expectedTotalBytes,
                                              ),
                                            ),
                                          ),
                                        ),
                                        backgroundDecoration: BoxDecoration(
                                          color: Colors.black,
                                        ),
                                        pageController: _pageController,
                                        onPageChanged: (index) {},
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 10),
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(
                                  snapshot.data['original_images_path']
                                          .toString() +
                                      imageUrl.toString(),
                                  fit: BoxFit.fitWidth),
                            ),
                          );
                        }).toList(),
                        options: CarouselOptions(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                if (!myAd)
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        HexColor(),
                                      ),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                    ),
                                    child: Text(
                                      langPack['MAKE AN OFFER'],
                                      textDirection: CurrentUser.textDirection,
                                    ),
                                    onPressed: () {
                                      if (!CurrentUser.isLoggedIn) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext ctx) {
                                            return AlertDialog(
                                              title: Text(
                                                langPack['Login'],
                                                textDirection:
                                                    CurrentUser.textDirection,
                                              ),
                                              content: Text(
                                                langPack[
                                                    'You must be logged in to use this feature'],
                                                textDirection:
                                                    CurrentUser.textDirection,
                                              ),
                                              actions: [
                                                cancelButton(ctx),
                                                continueButton(ctx),
                                              ],
                                            );
                                          },
                                        );
                                      } else if (CurrentUser.isLoggedIn) {
                                        showDialog(
                                            context: context,
                                            builder: (ctx) {
                                              return OfferDialogBox(
                                                title:
                                                    langPack['Make an Offer'],
                                                descriptions: langPack[
                                                        'Seller asking price is'] +
                                                    ' \"${snapshot.data['price'] + unescape.convert(snapshot.data['currency'] ?? "₹")}\"',
                                              );
                                            });
                                      }
                                    },
                                  ),
                                if (!myAd) Spacer(),
                                if (!myAd)
                                  FutureBuilder(
                                    future: DBHelper.queryFavProduct(
                                        'favourite_products',
                                        pushedMap['productId']),
                                    builder: (ctx, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {}
                                      if (snapshot.data != null &&
                                          snapshot.data.length > 0) {
                                        isFavorite = true;
                                      }
                                      return StatefulBuilder(
                                          builder: (_, setSt) {
                                        return IconButton(
                                          icon: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isFavorite
                                                ? Colors.red
                                                : Colors.grey[800],
                                            size: 40,
                                          ),
                                          onPressed: () async {
                                            if (!isFavorite) {
                                              await DBHelper.insertFavProduct(
                                                  DBHelper.favTableName, {
                                                'id': pushedMap['productId'],
                                                'prodId':
                                                    pushedMap['productId'],
                                              });
                                            } else {
                                              await DBHelper.deleteFavProduct(
                                                  'favourite_products',
                                                  pushedMap['productId']);
                                            }
                                            setSt(() {
                                              isFavorite = !isFavorite;
                                            });
                                          },
                                        );
                                      });
                                    },
                                  ),
                                if (myAd)
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        HexColor(),
                                      ),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                    ),
                                    child: Text(
                                      langPack['Upgrade To Premium'],
                                      textDirection: CurrentUser.textDirection,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (ctx) {
                                            return _premiumDialog(ctx);
                                          });
                                    },
                                  ),
                              ],
                            ),
                            Divider(),
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      snapshot.data['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      snapshot.data['price'] +
                                          unescape.convert(
                                            snapshot.data['currency'] ?? "₹",
                                          ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      'Ad Views - ' + snapshot.data['view'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Text(
                                  snapshot.data['created_at'],
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            // Divider(
                            //   height: 20,
                            // ),
                            // Row(
                            //   children: [
                            //     Text(
                            //       langPack['Posted By'],
                            //       style: TextStyle(
                            //         fontSize: 18,
                            //       ),
                            //     ),
                            //     Spacer(),
                            //     TextButton(
                            //         style: ButtonStyle(
                            //             foregroundColor:
                            //                 MaterialStateProperty.all<Color>(
                            //                     Colors.grey[800])),
                            //         onPressed: () {
                            //           Navigator.of(context).pushNamed(
                            //               SellerDetailsScreen.routeName,
                            //               arguments: {
                            //                 'seller_name':
                            //                     snapshot.data['seller_name'],
                            //                 'seller_image':
                            //                     'https://https://keeraya.com//storage/profile/' +
                            //                         snapshot.data['seller_image'],
                            //                 'seller_createdat':
                            //                     snapshot.data['seller_createdat'],
                            //               });
                            //         },
                            //         child: Text(snapshot.data['seller_name'])),
                            //   ],
                            // ),
                            Divider(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Text(
                                  langPack['Phone number'],
                                  textDirection: CurrentUser.textDirection,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Spacer(),
                                if (snapshot.data['hide_phone'] != 'yes')
                                  Text("${snapshot.data['phone']}"),
                              ],
                            ),
                            Divider(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Text(
                                  langPack['Email'],
                                  textDirection: CurrentUser.textDirection,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Spacer(),
                                Text("${snapshot.data['seller_email']}"),
                              ],
                            ),
                            Divider(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Text(
                                  langPack['Property status'],
                                  textDirection: CurrentUser.textDirection,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                Spacer(),
                                Text("${snapshot.data['status']}"),
                              ],
                            ),
                            Divider(
                              height: 20,
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              itemCount: snapshot.data['custom_data'].length,
                              itemBuilder: (ctx, i) {
                                final exp = RegExp('\\*');
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          snapshot.data['custom_data'][i]
                                                  ['title']
                                              .replaceAll(exp, ''),
                                          textDirection:
                                              CurrentUser.textDirection,
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                        Spacer(),
                                        Text(snapshot.data['custom_data'][i]
                                                ['value'] ??
                                            'Has no value'),
                                      ],
                                    ),
                                    Divider(
                                      height: 20,
                                    ),
                                  ],
                                );
                              },
                            ),

                            Text(
                              langPack['Description'],
                              textDirection: CurrentUser.textDirection,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                                _parseHtmlString(snapshot.data['description'])),
                            Divider(),
                            ListTile(
                              minLeadingWidth: 70,
                              leading: CircleAvatar(
                                radius: 35,
                                foregroundImage: NetworkImage(
                                    'https://keeraya.com//storage/profile/' +
                                        snapshot.data['seller_image']),
                              ),
                              title: Text(
                                snapshot.data['seller_name'],
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              subtitle: Text('Member since: ' +
                                  "${snapshot.data['seller_createdat']}"),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 15,
                                color: Colors.grey[800],
                              ),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    SellerDetailsScreen.routeName,
                                    arguments: {
                                      'seller_id': snapshot.data['seller_id'],
                                      'seller_name':
                                          snapshot.data['seller_name'],
                                      'seller_image':
                                          'https://keeraya.com//storage/profile/' +
                                              snapshot.data['seller_image'],
                                      'seller_createdat':
                                          snapshot.data['seller_createdat'],
                                    });
                              },
                            ),
                            Divider(
                              height: 15,
                            ),
                            _getAdContainer(),
                            Divider(
                              height: 15,
                            ),
                            Text(
                              langPack['Location'],
                              textDirection: CurrentUser.textDirection,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(snapshot.data['location']),
                            SizedBox(
                              height: 15,
                            ),
                            AspectRatio(
                              aspectRatio: 3 / 2,
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  // bearing: 192.8334901395799,
                                  // tilt: 59.440717697143555,
                                  zoom: 15,
                                  target: LatLng(
                                    double.parse(
                                        snapshot.data['map_latitude'] != ''
                                            ? snapshot.data['map_latitude']
                                            : '0'),
                                    double.parse(
                                        snapshot.data['map_longitude'] != ''
                                            ? snapshot.data['map_longitude']
                                            : '0'),
                                  ),
                                ),
                                onMapCreated: (GoogleMapController controller) {
                                  if (!_controller.isCompleted)
                                    _controller.complete(controller);
                                },
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Recommended Ads for You',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder(
                        future: Provider.of<APIHelper>(context, listen: false)
                            .fetchRelatedProducts(
                          categoryId: snapshot.data['category_id'],
                          subCategoryId: snapshot.data['sub_category_id'],
                        ),
                        builder: (ctx, relatedSnapshot) {
                          if (relatedSnapshot.connectionState ==
                              ConnectionState.waiting) {
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
                          if (relatedSnapshot.hasData &&
                              relatedSnapshot.data.length > 0) {
                            return Container(
                              padding: const EdgeInsets.only(
                                top: 0,
                                bottom: 15,
                                left: 15,
                                right: 0,
                              ),
                              height:
                                  MediaQuery.of(context).size.width * 3.3 / 5,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: relatedSnapshot.data.length,
                                  itemBuilder: (ctx, i) {
                                    return Row(
                                      children: [
                                        ProductItem(
                                          id: relatedSnapshot.data[i].id,
                                          isFeatured: relatedSnapshot
                                              .data[i].isFeatured,
                                          isUrgent:
                                              relatedSnapshot.data[i].isUrgent,
                                          name: relatedSnapshot.data[i].name,
                                          imageUrl:
                                              relatedSnapshot.data[i].picture,
                                          price: relatedSnapshot.data[i].price,
                                          location:
                                              relatedSnapshot.data[i].location,
                                          currency:
                                              relatedSnapshot.data[i].currency,
                                        ),
                                        SizedBox(width: 20),
                                      ],
                                    );
                                  }),
                            );
                          }
                          return Center(
                            child: Text('There are not related Ads'),
                          );
                        },
                      ),
                    ],
                  );
                }
            }
            return Center(
              child: Text('There is no data about this product'),
            );
          },
        ),
      ),
    );
  }
}
