import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:http_auth/http_auth.dart';

import '../helpers/app_config.dart';

class PaypalServices {
  //String domain = "https://api.sandbox.paypal.com";
  String domain = "api-m.sandbox.paypal.com"; // for sandbox mode
  //String domain = "api-m.paypal.com"; // for production mode

  // change clientId and secret with your own, provided by paypal
  String clientId = AppConfig.paystackPublicKey;
  String secret = AppConfig.paystackSecretKey;
  String username = AppConfig.paypalUsername;
  String password = AppConfig.paypalPassword;

  /*Future makePostPayPal() async {
    var bytes = utf8.encode("$username:$password");
    var credentials = base64.encode(bytes);
    String usermanePassword = "$username:$password";
    Map token = {
      'grant_type': 'client_credentials'
    };

    var headers = {
      "Accept": "application/json",
      'Accept-Language': 'en_US',
      "Authorization": "Basic $usermanePassword"
    };

    var url = "https://api.sandbox.paypal.com/v1/oauth2/token";
    var requestBody = token;
    http.Response response = await http.post(Uri.parse(url), body: requestBody, headers: headers);
    var responseJson = json.decode(response.body);
    print("--------------- Response ------------------------");
    print(responseJson);
    return responseJson;
  }*/

  /*Future<String> getAccessToken() async {
    try {
      var client = BasicAuthClient(clientId, secret);
      var response = await client.post(Uri.parse('$domain/v1/oauth2/token?grant_type=client_credentials'));
      if (response.statusCode == 200) {
        final body = convert.jsonDecode(response.body);
        return body["access_token"];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }*/

  // for getting the access token from Paypal
  Future<String> getAccessToken() async {
    try {
      var client = BasicAuthClient(clientId, secret);
      final uri = Uri.https(domain, 'v1/oauth2/token', {
        'grant_type': 'client_credentials',
      });
      print(uri);
      print(clientId);
      print(secret);
      var response = await client
          // .post('$domain/v1/oauth2/token?grant_type=client_credentials');
          .post(uri);
      print("--------------- Response ------------------------");
      print(response.body);
      if (response.statusCode == 200) {
        print("Body access-token");
        final body = convert.jsonDecode(response.body);
        print(body["access-token"]);
        return body["access_token"];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // for creating the payment request with Paypal
  Future<Map<String, String>> createPaypalPayment(
      transactions, accessToken) async {
    try {
      final uri = Uri.https(domain, 'v1/payments/payment');
      // var response = await http.post("$domain/v1/payments/payment",
      var response = await http.post(uri,
          body: convert.jsonEncode(transactions),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + accessToken
          });
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 201) {
        print(body);
        if (body["links"] != null && body["links"].length > 0) {
          List links = body["links"];

          String executeUrl = "";
          String approvalUrl = "";
          final item = links.firstWhere((o) => o["rel"] == "approval_url",
              orElse: () => null);
          if (item != null) {
            approvalUrl = item["href"];
          }
          final item1 = links.firstWhere((o) => o["rel"] == "execute",
              orElse: () => null);
          if (item1 != null) {
            executeUrl = item1["href"];
          }
          return {"executeUrl": executeUrl, "approvalUrl": approvalUrl};
        }
        return null;
      } else {
        throw Exception(body["message"]);
      }
    } catch (e) {
      rethrow;
    }
  }

  // for executing the payment transaction
  Future<String> executePayment(url, payerId, accessToken) async {
    try {
      var response = await http.post(url,
          body: convert.jsonEncode({"payer_id": payerId}),
          headers: {
            "content-type": "application/json",
            'Authorization': 'Bearer ' + accessToken
          });

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body["id"];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
