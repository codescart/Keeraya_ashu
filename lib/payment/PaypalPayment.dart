import 'dart:core';

import 'package:keeraya/helpers/app_config.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'PaypalServices.dart';

class PaypalPayment extends StatefulWidget {
  final Function onFinish;
  final String title;
  final String price;

  PaypalPayment(this.title, this.price, {this.onFinish});

  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentState(title, price);
  }
}

class PaypalPaymentState extends State<PaypalPayment> {
  final String title;
  final String price;

  PaypalPaymentState(this.title, this.price);

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String checkoutUrl;
  String executeUrl;
  String accessToken;
  PaypalServices services = PaypalServices();

  // you can change default currency according to your need
  Map<dynamic, dynamic> defaultCurrency = {
    "symbol": AppConfig.currencyCode,
    "decimalDigits": 2,
    "symbolBeforeTheNumber": true,
    "currency": AppConfig.currencyCode
  };

  bool isEnableShipping = false;
  bool isEnableAddress = false;

  String returnURL = 'return.example.com';
  String cancelURL = 'cancel.example.com';

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      try {
        accessToken = await services.getAccessToken();

        final transactions = getOrderParams();
        final res =
            await services.createPaypalPayment(transactions, accessToken);
        if (res != null) {
          setState(() {
            checkoutUrl = res["approvalUrl"];
            executeUrl = res["executeUrl"];
          });
        }
      } catch (e) {
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

        //! Deprecated use ScaffoldMessenger.of(context)
        // _scaffoldKey.currentState.showSnackBar(snackBar);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  int quantity = 1;

  Map<String, dynamic> getOrderParams() {
    List items = [
      {
        "name": title,
        "quantity": quantity,
        "price": price,
        "currency": AppConfig.currencyCode
      }
    ];

    // checkout invoice details
    String totalAmount = price;
    String subTotalAmount = price;
    String shippingCost = '0';
    int shippingDiscountCost = 0;
    String userFirstName = 'Gulshan';
    String userLastName = 'Yadav';
    String addressCity = 'Delhi';
    String addressStreet = 'Mathura Road';
    String addressZipCode = '110014';
    String addressCountry = 'India';
    String addressState = 'Delhi';
    String addressPhoneNumber = '+919990119091';

    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": totalAmount,
            "currency": AppConfig.currencyCode,
          },
          "description": title,
        }
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {"return_url": returnURL, "cancel_url": cancelURL}
    };
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    print(checkoutUrl);

    if (checkoutUrl != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: WebView(
          initialUrl: checkoutUrl,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (NavigationRequest request) {
            if (request.url.contains(returnURL)) {
              print(request.toString());
              final uri = Uri.parse(request.url);
              final String payerID = uri.queryParameters['PayerID'].toString();
              if (payerID != null) {
                services
                    .executePayment(Uri.parse(executeUrl), payerID, accessToken)
                    .then((id) {
                  widget.onFinish(id);
                  Navigator.of(context).pop('SUCCESS');
                });
              } else {
                Navigator.of(context).pop('FAILED');
              }
            }
            if (request.url.contains(cancelURL)) {
              Navigator.of(context).pop('CANCELLED');
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    } else {
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
    }
  }
}
