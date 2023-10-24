// import 'dart:async';
// import 'dart:convert';

// import 'package:keeraya/helpers/app_config.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart';
// import 'package:payu_money_flutter/payu_money_flutter.dart';

// void main() {
//   runApp(PayUMoney());
// }

// class PayUMoney extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<PayUMoney> {
//   // Creating PayuMoneyFlutter Instance
//   PayuMoneyFlutter payuMoneyFlutter = PayuMoneyFlutter();

//   static const platform = const MethodChannel('com.startActivity/testChannel');

//   // Payment Details
//   String phone = "8318045008";
//   String email = "gmail@gmail.com";
//   String productName = "My Product Name";
//   String firstName = "Vaibhav";
//   String txnID = DateTime.now().millisecondsSinceEpoch.toString();
//   String amount = "555";

//   @override
//   void initState() {
//     super.initState();
//     // Setting up the payment details
//     setupPayment();
//   }

//   // Function for setting up the payment details
//   setupPayment() async {
//     bool response = await payuMoneyFlutter.setupPaymentKeys(
//         merchantKey: AppConfig.payUMoneyMerchantKey,
//         merchantID: AppConfig.payUMoneyMerchantId,
//         isProduction: false,
//         activityTitle: "App Title",
//         disableExitConfirmation: false);
//   }

//   // Function for start payment with given merchant id and merchant key
//   Future<Map<String, dynamic>> startPayment() async {
//     // Generating hash from php server
//     Response res = await post(
//         Uri.parse(
//             "https://https://keeraya.com//includes/payments/payumoney/hashgenerator.php"),
//         body: {
//           "key": AppConfig.payUMoneyMerchantKey,
//           "salt": AppConfig.payUMoneyMerchantSalt,
//           "txnid": txnID,
//           "phone": phone,
//           "email": email,
//           "amount": amount,
//           "productInfo": productName,
//           "firstName": firstName,
//         });
//     var data = jsonDecode(res.body);
//     print(data);
//     String hash = data['result'];
//     print(hash);
//     var myResponse = await payuMoneyFlutter.startPayment(
//         txnid: txnID,
//         amount: amount,
//         name: firstName,
//         email: email,
//         phone: phone,
//         productName: productName,
//         hash: hash);
//     print("Message $myResponse");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Payu Money Flutter'),
//         ),
//         body: Center(
//           child: Text("Pay Us 10"),
//         ),
//         floatingActionButton: FloatingActionButton(
//           // Starting up the payment
//           onPressed: startPayment,
//           child: Icon(Icons.attach_money),
//         ),
//       ),
//     );
//   }
// }
