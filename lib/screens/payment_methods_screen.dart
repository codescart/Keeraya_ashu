import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:keeraya/helpers/api_helper.dart';
import 'package:keeraya/payment/PaypalPayment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../helpers/app_config.dart';
import '../helpers/current_user.dart';

class PaymentMethodsScreen extends StatefulWidget {
  static const routeName = '/payment-methods';

  @override
  _PaymentMethodsScreenState createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  static const platformChannel = const MethodChannel('myTestChannel');

  //! flutter payStack
  // final payStack = PaystackPlugin();
  // PayuMoneyFlutter payuMoneyFlutter = PayuMoneyFlutter();
  Razorpay razorpay;
  String txnID = DateTime.now().millisecondsSinceEpoch.toString();
  final String amount = "200";
  String price = "";
  String title = "";
  String id = "";
  String paymentMethod = "";
  bool isFeatured = false;
  bool isUrgent = false;
  bool isHighlighted = false;
  bool isSubscription = false;

  //Payumoney Credentials
  final String merchantKey = AppConfig.payUMoneyMerchantKey;
  final String merchantID = AppConfig.payUMoneyMerchantId;
  final String merchantSalt = AppConfig.payUMoneyMerchantSalt;

  //Payumoney Payment Details
  String phone = "8318045008";
  String email = CurrentUser.email;
  String firstName =
      CurrentUser.name.isNotEmpty ? CurrentUser.name : "UserName";

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

  @override
  void initState() {
    //! flutter payStack
    // payStack.initialize(
    //   publicKey: AppConfig.paystackPublicKey,
    // );
    razorpay = Razorpay();
    // setupPayment(); //Payumoney setup

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handlerExternalWallet);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    razorpay.clear(); // Removes all listeners
  }

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
      paymentMethod,
      "subscr",
      "Subscription",
    );
  }

  void onUpgradeAdPaymentSuccess() async {
    final apiHelper = APIHelper();
    final isSuccess = await apiHelper.postUpgradeAd(
        title,
        price,
        CurrentUser.id,
        id,
        isFeatured ? "1" : "0",
        isUrgent ? "1" : "0",
        isHighlighted ? "1" : "0",
        paymentMethod,
        "premium",
        "Premium Ad");
  }

  void onPaymentFailure() {
    ScaffoldMessenger.of(context).showSnackBar(snackBar("Payment Failed"));
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    paymentMethod = "razorpay";
    isSubscription
        ? onSubscriptionPaymentSuccess()
        : onUpgradeAdPaymentSuccess();
    ScaffoldMessenger.of(context).showSnackBar(snackBar("Payment Successful"));
  }

  void _handlerErrorFailure(PaymentFailureResponse response) {
    //var responseJson = json.decode(response.message);
    //ScaffoldMessenger.of(context).showSnackBar(snackBar("Payment Failed"));
    onPaymentFailure();
  }

  void _handlerExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar("External Wallet"));
  }

  void openCheckout(int price) async {
    var options = {
      "key": AppConfig.razorpayKey,
      "amount": price,
      "name": AppConfig.appName,
      "description": title,
      "currency": AppConfig.currencyCode,
      "prefill": {
        // "contact" : CurrentUser.,
        "email": CurrentUser.email
      },
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> showLoading(String message) {
    return showDialog(
      context: this.context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            margin: EdgeInsets.fromLTRB(30, 20, 30, 20),
            width: double.infinity,
            height: 50,
            child: Text(message),
          ),
        );
      },
    );
  }

  // Future<void> pay() async {
  //   log("===>>>>>>>> Generating hash locally");
  //   log("$merchantID ..... $merchantKey ..... $merchantSalt");
  //   PaymentParams _paymentParam = PaymentParams(
  //     merchantID: merchantID,
  //     merchantKey: merchantKey,
  //     salt: merchantSalt,
  //     amount: price,
  //     transactionID: txnID,
  //     firstName: CurrentUser.name,
  //     email: CurrentUser.email,
  //     productName: title,
  //     phone: "9876543210",
  //     fURL: "https://www.payumoney.com/mobileapp/payumoney/failure.php",
  //     sURL: "https://www.payumoney.com/mobileapp/payumoney/success.php",
  //     udf1: "udf1",
  //     udf2: "udf2",
  //     udf3: "udf3",
  //     udf4: "udf4",
  //     udf5: "udf5",
  //     udf6: "",
  //     udf7: "",
  //     udf8: "",
  //     udf9: "",
  //     udf10: "",
  //     hash:
  //         "", //Hash is required will initialise with empty string now to set actuall hash later
  //     isDebug: false, // true for Test Mode, false for Production
  //   );

  //   //Generating local hash
  //   var bytes = utf8.encode(
  //       "${_paymentParam.merchantKey}|${_paymentParam.transactionID}|${_paymentParam.amount}|${_paymentParam.productName}|${_paymentParam.firstName}|${_paymentParam.email}|udf1|udf2|udf3|udf4|udf5||||||${_paymentParam.salt}");
  //   String localHash = sha512.convert(bytes).toString();
  //   _paymentParam.hash = localHash;

  //   log("=>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$localHash");

  //   try {
  //     PayuPaymentResult _paymentResult =
  //         await FlutterPayuUnofficial.initiatePayment(
  //             paymentParams: _paymentParam, showCompletionScreen: true);

  //     //Checks for success and prints result

  //     if (_paymentResult != null) {
  //       //_paymentResult.status is String of course. Directly fetched from payU's Payment response. More statuses can be compared manually

  //       if (_paymentResult.status == PayuPaymentStatus.success) {
  //         print("Success: ${_paymentResult.response}");
  //       } else if (_paymentResult.status == PayuPaymentStatus.failed) {
  //         print("Failed: ${_paymentResult.response}");
  //       } else if (_paymentResult.status == PayuPaymentStatus.cancelled) {
  //         print("Cancelled by User: ${_paymentResult.response}");
  //       } else {
  //         print("Response: ${_paymentResult.response}");
  //         print("Status: ${_paymentResult.status}");
  //       }
  //     } else {
  //       print("Something's rotten here");
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  _handlePaymentInitialization(int price) async {
    final style = FlutterwaveStyle(
      appBarText: "My Standard Blue",
      buttonColor: Color(0xffd0ebff),
      appBarIcon: Icon(Icons.message, color: Color(0xffd0ebff)),
      buttonTextStyle: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      appBarColor: Color(0xffd0ebff),
      dialogCancelTextStyle: TextStyle(color: Colors.redAccent, fontSize: 18),
      dialogContinueTextStyle: TextStyle(
        color: Colors.blue,
        fontSize: 18,
      ),
    );
    final Customer customer = Customer(
      name: CurrentUser.name == "" ? "Customer" : CurrentUser.name,
      phoneNumber: "0123456789",
      email:
          CurrentUser.email == "" ? "customer@customer.com" : CurrentUser.email,
    );

    try {
      final Flutterwave flutterwave = Flutterwave(
        paymentOptions: "card, payattitude, barter",
        customer: customer,
        context: this.context,
        publicKey: AppConfig.flutterwavePublicKey,
        currency: AppConfig.currencyCode ?? "RWF",
        amount: price.toString(),
        txRef: txnID,
        customization: Customization(title: "Test Payment"),
        isTestMode: false,
        redirectUrl:
            "https://momentumacademy.net/wp-content/uploads/2020/05/Paymentsuccessful21.png",
      );
      final ChargeResponse response = await flutterwave.charge();
      if (response != null) {
        this.showLoading(response.status);
        print("${response.toJson()}");
        if (response.success) {
          paymentMethod = "FlutterWave";
          isSubscription
              ? onSubscriptionPaymentSuccess()
              : onUpgradeAdPaymentSuccess();
          ScaffoldMessenger.of(context)
              .showSnackBar(snackBar("Payment Successful"));
        } else if (!response.success)
          ScaffoldMessenger.of(context)
              .showSnackBar(snackBar("Payment Cancelled"));
        else
          onPaymentFailure();
      } else {
        this.showLoading("No Response!");
      }
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    platformChannel.setMethodCallHandler((call) {
      print("Hello from ${call.method}");
      return null;
    });

    final Map<String, dynamic> pushedMap =
        ModalRoute.of(context).settings.arguments;

    id = pushedMap['id'];
    title = pushedMap['title'];
    price = pushedMap['price'];
    isUrgent = pushedMap['isUrgent'];
    isFeatured = pushedMap['isFeatured'];
    isHighlighted = pushedMap['isHighlighted'];
    isSubscription = pushedMap['isSubscription'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Methods',
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
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (AppConfig.paypalOn)
              ListTile(
                key: ValueKey('PayPal'),
                title: Text('PayPal'),
                leading: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 3.5),
                  child: Image.asset(
                    'assets/images/paypal.png',
                    fit: BoxFit.fill,
                  ),
                ),
                onTap: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => PaypalPayment(
                        title,
                        price,
                        onFinish: (number) async {
                          print(number);
                        },
                      ),
                    ),
                  );

                  if (result == "SUCCESS") {
                    paymentMethod = "paypal";
                    isSubscription
                        ? onSubscriptionPaymentSuccess()
                        : onUpgradeAdPaymentSuccess();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(snackBar("Payment Successful"));
                  } else if (result == "CANCELLED")
                    ScaffoldMessenger.of(context)
                        .showSnackBar(snackBar("Payment Cancelled"));
                  else
                    onPaymentFailure();
                },
              ),
            // if (AppConfig.payUMoneyOn)
            //   ListTile(
            //     key: ValueKey('PayUMoney'),
            //     title: Text('PayUMoney'),
            //     leading: Container(
            //       constraints: BoxConstraints(
            //           maxWidth: MediaQuery.of(context).size.width / 3.5),
            //       child: Image.asset(
            //         'assets/images/pay_u1.png',
            //         fit: BoxFit.fill,
            //       ),
            //     ),
            //     onTap: null,
            //   ),
            // if (AppConfig.payStackOn)
            //   ListTile(
            //     key: ValueKey('PayStack'),
            //     title: Text('PayStack'),
            //     leading: Container(
            //       constraints: BoxConstraints(
            //           maxWidth: MediaQuery.of(context).size.width / 3.5),
            //       child: Image.asset(
            //         'assets/images/paystack.png',
            //         fit: BoxFit.fill,
            //       ),
            //     ),
            //     onTap: null,
            //     //! flutter payStack
            //     // onTap: () async {
            //     //   double dbAmount = double.parse(pushedMap['price']);
            //     //   String amount = dbAmount
            //     //       .toStringAsFixed(2)
            //     //       .toString()
            //     //       .replaceAll(".", "");

            //     //   Charge charge = Charge()
            //     //     ..amount = int.parse(amount)
            //     //     ..reference = _getReference()
            //     //     ..currency = AppConfig.currencyCode
            //     //     // or ..accessCode = _getAccessCodeFrmInitialization()
            //     //     // ..currency = 'MDL'
            //     //     ..email = 'customer@email.com';
            //     //   CheckoutResponse response = await payStack.checkout(
            //     //     context,
            //     //     method: CheckoutMethod
            //     //         .card, // Defaults to CheckoutMethod.selectable
            //     //     charge: charge,
            //     //   );

            //     //   if (response.message == "Success") {
            //     //     paymentMethod = "paystack";
            //     //     isSubscription
            //     //         ? onSubscriptionPaymentSuccess()
            //     //         : onUpgradeAdPaymentSuccess();
            //     //     ScaffoldMessenger.of(context)
            //     //         .showSnackBar(snackBar("Payment Successful"));
            //     //   } else
            //     //     onPaymentFailure();
            //     // },
            //   ),
            if (AppConfig.razorpayOn)
              ListTile(
                title: Text('Razorpay Payment'),
                leading: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 3.5),
                  child: Image.asset(
                    'assets/images/razorpay_image.jpg',
                    fit: BoxFit.fill,
                  ),
                ),
                onTap: () {
                  double dbAmount = double.parse(pushedMap['price']);
                  String amount = dbAmount
                      .toStringAsFixed(2)
                      .toString()
                      .replaceAll(".", "");
                  openCheckout(int.parse(amount));
                },
              ),
            if (AppConfig.flutterwaveOn)
              ListTile(
                title: Text('Flutter Wave Payment'),
                leading: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 3.5),
                  child: Image.asset(
                    'assets/images/flutter_wave_image.png',
                    fit: BoxFit.fill,
                  ),
                ),
                onTap: () {
                  _handlePaymentInitialization(
                      double.parse(pushedMap['price']).round());
                },
              )
          ],
        ),
      ),
    );
  }

// // Function for setting up the payment details
// setupPayment() async {
//   bool response = await payuMoneyFlutter.setupPaymentKeys(
//     merchantKey: merchantKey,
//     merchantID: merchantID,
//     isProduction: AppConfig.payUMoneySandboxMode,
//     activityTitle: AppConfig.appName,
//     disableExitConfirmation: false,
//   );
// }

// Function for start payment with given merchant id and merchant key
// Future<Map<String, dynamic>> startPayment() async {
//   // Generating hash from php server
//   log("===>>>>>>>> Generating hash from php server ${APIHelper.BASE_URL}");
//   var res = await post(
//       Uri.parse("https://" +
//           APIHelper.BASE_URL +
//           "/includes/payments/payumoney/hashgenerator.php"),
//       body: {
//         "key": merchantKey,
//         "salt": merchantSalt,
//         "txnid": txnID,
//         "phone": phone,
//         "email": email,
//         "amount": price,
//         "productInfo": title,
//         "firstName": firstName,
//       });

//   var data = jsonDecode(res.body);
//   print(data);
//   String hash = data['result'];
//   log("=>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$hash");
//   var myResponse = await payuMoneyFlutter.startPayment(
//       txnid: txnID,
//       amount: price,
//       name: firstName,
//       email: email,
//       phone: phone,
//       productName: title,
//       hash: hash);

//   if (myResponse['status'] == 'success') {
//     paymentMethod = "payumoney";
//     isSubscription
//         ? onSubscriptionPaymentSuccess()
//         : onUpgradeAdPaymentSuccess();
//     ScaffoldMessenger.of(context)
//         .showSnackBar(snackBar("Payment Successful"));
//   } else
//     onPaymentFailure();
// }
}

String _getReference() {
  String platform;
  if (Platform.isIOS) {
    platform = 'iOS';
  } else {
    platform = 'Android';
  }

  return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
}
