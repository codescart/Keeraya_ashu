import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/api_helper.dart';
import '../helpers/app_config.dart';
import '../helpers/current_user.dart';
import '../providers/languages.dart';
import '../screens/payment_methods_screen.dart';

class MembershipPlanWidget extends StatelessWidget {
  final String id;
  final String title;
  final String price;
  final String term;
  final String postLimit;
  final String adDuration;
  final String featuredFee;
  final String urgentFee;
  final String highlightFee;
  final String featuredDuration;
  final String urgentDuration;
  final String highlightDuration;
  final bool topInSearchAndCategory;
  final bool showOnHome;
  final bool showInHomeSearch;

  MembershipPlanWidget({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.term,
    @required this.postLimit,
    @required this.adDuration,
    @required this.featuredFee,
    @required this.urgentFee,
    @required this.highlightFee,
    @required this.featuredDuration,
    @required this.urgentDuration,
    @required this.highlightDuration,
    @required this.topInSearchAndCategory,
    @required this.showOnHome,
    @required this.showInHomeSearch,
  });

  void onSubscriptionPaymentSuccess() async {
    final apiHelper = APIHelper();
    final isSuccess = await apiHelper.postPremiumTransactionDetail(
      title,
      price,
      CurrentUser.id,
      id,
      "0",
      "0",
      "0",
      'in app purchase',
      "subscr",
      "Subscription",
    );
  }

  void onPaymentFailure(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar("Payment Failed"));
  }

  Future<void> launchURL(BuildContext context, String title) async {
    var termsOfUse = Uri.parse(AppConfig.termsOfUseURL);
    var privacyPolicy = Uri.parse(AppConfig.privacyPolicyURL);
    if (title == AppConfig.termsOfUse) {
      if (await canLaunchUrl(termsOfUse)) {
        await launchUrl(
          termsOfUse,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(snackBar("error lunch"));
      }
    } else {
      if (await canLaunchUrl(privacyPolicy)) {
        await launchUrl(
          privacyPolicy,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(snackBar("error lunch"));
      }
    }
  }

  Widget snackBar(String text) {
    return SnackBar(
      content: Text(text),
      duration: Duration(seconds: 10),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
  }

  Widget _customListTileBuilder({
    BuildContext ctx,
    String simpleText = '',
    String boldText = '',
    double fontSize = 16.0,
    Icon icon = const Icon(
      Icons.check_circle,
      color: Colors.green,
    ),
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 7),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(ctx).size.width - 70,
            ),
            child: RichText(
              maxLines: null,
              softWrap: true,
              textDirection: CurrentUser.textDirection,
              text: TextSpan(
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.grey[800],
                ),
                children: [
                  TextSpan(
                    text: simpleText,
                  ),
                  TextSpan(
                    text: boldText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool isSubscription = false;

  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(
        top: 10,
        bottom: 10,
        left: 20,
        right: 20,
      ),
      width: size.width - 40,
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 8,
        child: Container(
          padding: EdgeInsets.all(
            10,
          ),
          constraints: BoxConstraints(
            maxHeight: size.height,
            maxWidth: size.width,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                        color: Colors.grey[800],
                      ),
                    ),
                    _customListTileBuilder(
                      ctx: context,
                      simpleText: '',
                      boldText: '${AppConfig.currencySign}$price / $term',
                      fontSize: 20,
                    ),
                    _customListTileBuilder(
                      ctx: context,
                      simpleText: langPack['Ad Post Limit'],
                      boldText: postLimit,
                    ),
                    _customListTileBuilder(
                      ctx: context,
                      simpleText: langPack['Ad Expiry in'],
                      boldText: ' $postLimit ${langPack['days']}',
                    ),
                    _customListTileBuilder(
                      ctx: context,
                      simpleText: langPack['Featured Ad fee'],
                      boldText:
                          ' $featuredFee ${langPack['for']} $featuredDuration ${langPack['days']}',
                    ),
                    _customListTileBuilder(
                      ctx: context,
                      simpleText: langPack['Urgent Ad fee'],
                      boldText:
                          ' $urgentFee ${langPack['for']} $urgentDuration ${langPack['days']}',
                    ),
                    _customListTileBuilder(
                      ctx: context,
                      simpleText: langPack['Highlight Ad fee'],
                      boldText:
                          ' $highlightFee ${langPack['for']} $highlightDuration ${langPack['days']}',
                    ),
                    _customListTileBuilder(
                      ctx: context,
                      simpleText:
                          langPack['Top in search results and category'],
                      boldText: '',
                      icon: topInSearchAndCategory
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                    ),
                    _customListTileBuilder(
                      ctx: context,
                      simpleText:
                          langPack['Show ad on home page premium ad section'],
                      boldText: '',
                      icon: showOnHome
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                    ),
                    _customListTileBuilder(
                      ctx: context,
                      simpleText:
                          langPack['Show ad on home page search result'],
                      boldText: '',
                      icon: showInHomeSearch
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () =>
                              launchURL(context, AppConfig.termsOfUse),
                          child: Text(AppConfig.termsOfUse)),
                      TextButton(
                          onPressed: () =>
                              launchURL(context, AppConfig.privacyPolicy),
                          child: Text(AppConfig.privacyPolicy)),
                    ],
                  ),
                ],
              ),
              TextButton(
                child: Text(
                  langPack['Upgrade To Premium'],
                  textDirection: CurrentUser.textDirection,
                ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  )),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey[800]),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () async {
                  if (Platform.isIOS) {
                    if (title == 'Basic') {
                      try {
                        await Purchases.purchaseProduct(
                          AppConfig.upgradeToBasicPlan,
                        ).then((value) {
                          //* check if payment is Successfully or not
                          final entitlements = value.entitlements
                              .active[AppConfig.upgradeToBasicPlan];
                          if (entitlements != null) {
                            onSubscriptionPaymentSuccess();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar("Payment Successful"));
                          } else if (entitlements == null) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar("Payment Cancelled"));
                          } else {
                            onPaymentFailure(context);
                          }
                        });
                      } catch (e) {
                        log(e);
                        print(e);
                      }
                    } else {
                      try {
                        await Purchases.purchaseProduct(
                          AppConfig.upgradeToPremiumPlan,
                        ).then((value) {
                          //* check if payment Success or not
                          final entitlements = value.entitlements
                              .active[AppConfig.upgradeToPremiumPlan];
                          if (entitlements != null) {
                            onSubscriptionPaymentSuccess();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar("Payment Successful"));
                          } else if (entitlements == null) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar("Payment Cancelled"));
                          } else {
                            onPaymentFailure(context);
                          }
                        });
                      } catch (e) {
                        log(e);
                      }
                    }
                  } else {
                    Navigator.of(context)
                        .pushNamed(PaymentMethodsScreen.routeName, arguments: {
                      'id': id,
                      'title': title,
                      'price': price,
                      'isFeatured': false,
                      'isUrgent': false,
                      'isHighlighted': false,
                      'isSubscription': true,
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
