import 'dart:core';

import 'package:keeraya/helpers/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

import './paypal_services.dart';

class PaypalPayment2 extends StatefulWidget {
  final String itemName;
  final String itemPrice;

  PaypalPayment2(this.itemName, this.itemPrice);

  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentState2(itemName, itemPrice);
  }
}

class PaypalPaymentState2 extends State<PaypalPayment2> {
  final String itemName;
  final String itemPrice;

  PaypalPaymentState2(this.itemName, this.itemPrice);

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String checkoutUrl;
  String executeUrl;
  String accessToken;
  bool loading = false;
  PaypalServices services = PaypalServices();

  // you can change default currency according to your need
  Map<dynamic, dynamic> defaultCurrency = {
    "symbol": "USD",
    "decimalDigits": 2,
    "symbolBeforeTheNumber": true,
    "currency": "USD"
  };

  bool isEnableShipping = false;
  bool isEnableAddress = false;

  String returnURL =
      'https://junedr375.github.io/junedr375-payment/'; //you can add customize link
  String cancelURL =
      'https://junedr375.github.io/junedr375-payment/error.html'; //you can add customize link

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      try {
        accessToken = await services.getAccessToken();
        print("Access token");
        print(accessToken);
        final transactions = getOrderParams();
        final res =
            await services.createPaypalPayment(transactions, accessToken);
        if (res != null) {
          setState(() {
            checkoutUrl = res["approvalUrl"];
            loading = true;
            executeUrl = res["executeUrl"];
          });
        }
      } catch (e) {
        setState(() {
          loading = true;
        });
        print('exception: ' + e.toString());
        final snackBar = SnackBar(
          content: Text(e.toString()),
          duration: Duration(seconds: 10),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.of(context).pop();
      }
    });
  }

  int quantity = 1;

  Map<String, dynamic> getOrderParams() {
    List items = [
      {
        "name": itemName,
        "quantity": quantity,
        "price": itemPrice,
        "currency": defaultCurrency["currency"]
      }
    ];

    // checkout invoice details
    String totalAmount = itemPrice; //'10';
    String subTotalAmount = itemPrice; //'10';
    String shippingCost = '0';
    int shippingDiscountCost = 0;
    String userFirstName = 'Juned';
    String userLastName = 'Raza';
    String addressCity = 'Delhi';
    String addressStreet = 'Amu road';
    String addressZipCode = '110014';
    String addressCountry = AppConfig.adCountryName;
    String addressState = 'Delhi';
    String addressPhoneNumber = '+9199999999';

    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": totalAmount,
            "currency": defaultCurrency["currency"],
            "details": {
              "subtotal": subTotalAmount,
              "shipping": shippingCost,
              "shipping_discount": ((-1.0) * shippingDiscountCost).toString()
            }
          },
          "description": "The payment transaction description.",
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
          },
          "item_list": {
            "items": items,
            if (isEnableShipping && isEnableAddress)
              "shipping_address": {
                "recipient_name": userFirstName + " " + userLastName,
                "line1": addressStreet,
                "line2": "",
                "city": addressCity,
                "country_code": addressCountry,
                "postal_code": addressZipCode,
                "phone": addressPhoneNumber,
                "state": addressState
              },
          }
        }
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {"return_url": returnURL, "cancel_url": cancelURL}
    };
    return temp;
  }

  Widget build(BuildContext context) {
    print("checoutUrl");
    print(checkoutUrl);

    if (checkoutUrl != null) {
      print("Ici");
      _launchURL(context, checkoutUrl);
      Navigator.of(context).pop();
    } else if (checkoutUrl == null && loading == false) {
      print(loading);
      print("Icii checout  == null");
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          backgroundColor: Colors.black12,
          elevation: 0.0,
        ),
        body: Center(child: Container(child: CircularProgressIndicator())),
      );
    } else if (checkoutUrl == null && loading == true) {
      return Scaffold(
        body: Center(child: Container(child: CircularProgressIndicator())),
      );
    }
  }
}

void _launchURL(BuildContext context, String url) async {
  try {
    await launch(
      url,
      customTabsOption: new CustomTabsOption(
        toolbarColor: Theme.of(context).primaryColor,
        enableDefaultShare: true,
        enableUrlBarHiding: true,
        showPageTitle: true,
        // ToDO add animation manual
        // animation: new CustomTabsAnimation.slideIn(),
        extraCustomTabs: <String>[
          // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
          'org.mozilla.firefox',
          // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
          'com.microsoft.emmx',
        ],
      ),
    );
  } catch (e) {
    // An exception is thrown if browser app is not installed on Android device.
    debugPrint(e.toString());
  }
}
