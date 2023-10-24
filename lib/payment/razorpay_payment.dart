import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayServices {
  Razorpay razorpay;

  void handlerPaymentSuccess() {
    print(
        "Pament successssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss");
    // Toast.sow("Pament success", context);
  }

  void handlerErrorFailure() {
    print(
        "Pament errorssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss");
    //Toast.show("Pament error", context);
  }

  void handlerExternalWallet() {
    print(
        "External Walletsssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss");
    //Toast.show("External Wallet", context);
  }

  initPayment() {
    /// Test payment gateway
    razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);

    ///
  }

  void dispose() {
    razorpay.clear(); // Removes all listeners
  }

  openCheckout() {
    var options = {
      "key": "rzp_test_qENDyMgfHKkgqr",
      "amount": "100000",
      "name": "Sample App",
      "description": "Payment for the some random product",
      "prefill": {"contact": "61861183", "email": "savykevin100@gmail.com"},
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
}
