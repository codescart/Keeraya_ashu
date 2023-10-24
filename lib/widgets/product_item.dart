import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/ad_manager.dart';
import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../helpers/db_helper.dart';
import '../providers/languages.dart';
import '../screens/edit_ad_screen.dart';
import '../screens/product_details_screen.dart';

class ProductItem extends StatefulWidget {
  final bool isUrgent;
  final bool isFeatured;
  final bool isHighlighted;
  final String imageUrl;
  final String name;
  final double price;
  final String location;
  final String currency;
  final String id;
  final String status;
  final bool isOnMyAdsScreen;
  final double padding;

  ProductItem({
    this.status,
    this.isFeatured = false,
    this.isUrgent = false,
    this.isHighlighted = false,
    this.isOnMyAdsScreen = false,
    @required this.imageUrl,
    @required this.name,
    @required this.price,
    @required this.location,
    @required this.currency,
    @required this.id,
    this.padding = 20,
  });

  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  bool isFavorite = false;

  var langPack;

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
      child: Text('Delete'),
      onPressed: () async {
        await Provider.of<APIHelper>(ctx, listen: false)
            .deleteProducts(userId: CurrentUser.id, itemId: widget.id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    langPack = Provider.of<Languages>(context, listen: false).selected;
    return AspectRatio(
      aspectRatio: 3 / 5,
      child: GestureDetector(
        onTap: () {
          print("item id ::: ${widget.id}");
          AdManager.showInterstitialAd();
          Navigator.of(context)
              .pushNamed(ProductDetailsScreen.routeName, arguments: {
            'productId': widget.id,
            'productName': widget.name,
            'imageUrl': widget.imageUrl,
            'myAd': widget.isOnMyAdsScreen,
          });
        },
        child: Card(
          elevation: 8,
          color: widget.isHighlighted ? Colors.yellow.shade600 : Colors.white,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey[100], width: 1),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    width: 1,
                    color: Colors.grey[300],
                  ),
                ),
                child: Column(
                  textDirection: CurrentUser.textDirection,
                  crossAxisAlignment: CurrentUser.language == 'Arabic'
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 -
                              widget.padding * 2,
                          child: Image.network(
                            widget.imageUrl,
                            key: ValueKey(widget.imageUrl),
                            alignment: Alignment.center,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          textDirection: CurrentUser.textDirection,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              '${widget.currency}${widget.price}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.red[700],
                              ),
                            ),
                            if (widget.isOnMyAdsScreen)
                              PopupMenuButton(
                                itemBuilder: (ctx) {
                                  final popUpItems = [
                                    PopupMenuItem(
                                      child: Text('Edit Ad'),
                                      value: 0,
                                    ),
                                    PopupMenuItem(
                                      child: Text('Delete Ad'),
                                      value: 1,
                                    ),
                                  ];
                                  return popUpItems;
                                },
                                onSelected: (value) async {
                                  if (value == 0) {
                                    // Push edit screen
                                    Navigator.of(context).pushNamed(
                                        EditAdScreen.routeName,
                                        arguments: {
                                          'productData':
                                              await Provider.of<APIHelper>(
                                            context,
                                            listen: false,
                                          ).fetchProductsDetails(
                                                  itemId: widget.id),
                                        });
                                  } else if (value == 1) {
                                    // Delete the Ad
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext ctx) {
                                        return AlertDialog(
                                          title: Text('Delete Ad'),
                                          content: Text(
                                              'Are you sure you want to delete this Ad ?'),
                                          actions: [
                                            cancelButton(ctx),
                                            continueButton(ctx),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      textDirection: CurrentUser.textDirection,
                      children: [
                        Expanded(
                          child: Text(
                            widget.name,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        FutureBuilder(
                          future: DBHelper.queryFavProduct(
                              DBHelper.favTableName, widget.id),
                          builder: (ctx, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {}
                            if (snapshot.data != null &&
                                snapshot.data.length > 0) {
                              isFavorite = true;
                            }
                            return IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    isFavorite ? Colors.red : Colors.grey[800],
                              ),
                              onPressed: () async {
                                if (!isFavorite) {
                                  await DBHelper.insertFavProduct(
                                      DBHelper.favTableName, {
                                    'id': widget.id,
                                    'prodId': widget.id,
                                  });
                                } else {
                                  await DBHelper.deleteFavProduct(
                                      DBHelper.favTableName, widget.id);
                                }
                                setState(() {
                                  isFavorite = !isFavorite;
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        textDirection: CurrentUser.textDirection,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey[500],
                          ),
                          Expanded(
                            child: Text(
                              widget.location,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isUrgent)
                    ClipRRect(
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(7)),
                      child: Container(
                        padding: EdgeInsets.all(3),
                        color: Colors.red,
                        child: Text('Urgent',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  if (widget.isFeatured)
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(!widget.isUrgent ? 7 : 0)),
                      child: Container(
                        padding: EdgeInsets.all(3),
                        color: Colors.yellow.shade600,
                        child: Text('Featured',
                            style: TextStyle(color: Colors.grey[800])),
                      ),
                    ),
                ],
              ),
              if (widget.isOnMyAdsScreen)
                Positioned(
                  right: 0,
                  top: 0,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(7)),
                    child: Container(
                      padding: EdgeInsets.all(3),
                      color: widget.status == 'active'
                          ? Colors.lightGreen[400]
                          : Colors.red[600],
                      child: Text(widget.status.toUpperCase(),
                          style: TextStyle(color: Colors.grey[800])),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
