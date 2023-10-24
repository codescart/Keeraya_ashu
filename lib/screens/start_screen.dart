import 'package:keeraya/screens/color_helper.dart';
import 'package:keeraya/screens/tabs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import './auth_screen.dart';
import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../providers/languages.dart';

class StartScreen extends StatelessWidget {
  static const routeName = '/start';
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
    'email',
    'profile',
  ]);
  Map<String, String> langPack;

  Future signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    print(googleUser);
    print(googleUser.displayName);
    print(googleUser.email);
    return googleUser;

    // // Create a new credential
    // final GoogleAuthCredential credential = GoogleAuthProvider.credential(
    //   loginResult: googleAuth.loginResult,
    //   idToken: googleAuth.idToken,
    // );

    // // Once signed in, return the UserCredential
    // final UserCredential authResult =
    //     await FirebaseAuth.instance.signInWithCredential(credential);
    // final User user = authResult.user;
    // if (user != null) {
    //   assert(!user.isAnonymous);
    //   assert(await user.getIdToken() != null);
    //   final User currentUser = _auth.currentUser;
    //   assert(user.uid == currentUser.uid);

    //   print('signInWithGoogle succeeded: $user');
    //   return '$user';
    // }
    // return null;
  }

  Future initiateFacebookLogin() async {
    await FacebookAuth.instance.logOut();
    try {
      final loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
        //   loginBehavior: LoginBehavior.WEB_ONLY,
      );

      if (loginResult.status == LoginStatus.success) {
        // you are logged
        final AccessToken accessToken = loginResult.accessToken;
        print('Pre-cred authToken' + accessToken.toString());

        print(loginResult);

        // get the user data
        final userData = await FacebookAuth.instance.getUserData();
        print(userData);

        return userData;
      }

      // // Create a credential from the access token
      // final FacebookAuthCredential credential = FacebookAuthProvider.credential(
      //   loginResult.token,
      // );
      // print(loginResult.token);
      // print('credentials >>>' + credential.toString());
      // // Once signed in, return the UserCredential
      // return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      // handle the FacebookAuthException
      // switch (e.errorCode) {
      //   case FacebookAuthErrorCode.OPERATION_IN_PROGRESS:
      //     print("You have a previous login operation in progress");
      //     break;
      //   case FacebookAuthErrorCode.CANCELLED:
      //     print("login cancelled");
      //     break;
      //   case FacebookAuthErrorCode.FAILED:
      //     print("login failed");
      //     break;
      // }
    } finally {}
    return null;
    // final facebookLogin = FacebookLogin();
    // facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
    // final result = await facebookLogin.logIn(['email']);

    // // Create a credential from the access token
    // final FacebookAuthCredential facebookAuthCredential =
    //     FacebookAuthProvider.credential(result.loginResult.token);

    // // Once signed in, return the UserCredential
    // await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

    // switch (result.status) {
    //   case FacebookLoginStatus.loggedIn:
    //     // _sendTokenToServer(result.loginResult.token);
    //     // _showLoggedInUI();
    //     print('Logged in with facebook successfuly');
    //     break;
    //   case FacebookLoginStatus.cancelledByUser:
    //     // _showCancelledMessage();
    //     print('Facebook login canceled by user');
    //     break;
    //   case FacebookLoginStatus.error:
    //     // _showErrorOnUI(result.errorMessage);
    //     print('Facebook login throwed some error');
    //     break;
    // }
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Signed Out");
  }

  @override
  Widget build(BuildContext context) {
    langPack = Provider.of<Languages>(context).selected;
    final screenWidth = MediaQuery.of(context).size.width;
    //final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: HexColor(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            icon: Image.asset(
              'assets/images/google_icon.png',
              fit: BoxFit.fitHeight,
              color: Colors.grey[800],
              height: 25,
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.grey[800]),
              minimumSize: MaterialStateProperty.all<Size>(
                Size(
                  screenWidth - 70,
                  50,
                ),
              ),
            ),
            label: Text(
              'Google ' + langPack['Login'],
              textDirection: CurrentUser.textDirection,
            ),
            onPressed: () async {
              print("start Login gmail");
              GoogleSignInAccount response = await signInWithGoogle();
              print(response);

              await Provider.of<APIHelper>(context, listen: false)
                  .autoLoginUser(
                      name: response.displayName,
                      email: response.email,
                      fbLogin: true,
                      username: response.displayName.split(' ')[0],
                      fbPicture: response.photoUrl,
                      password: response.id);

              Phoenix.rebirth(context);
              Navigator.pushNamedAndRemoveUntil(context, TabsScreen.routeName,
                  (Route<dynamic> route) => false);
            },
          ),
          SizedBox(
            height: 10,
          ),
          TextButton.icon(
            icon: Image.asset(
              'assets/images/fb_icon.png',
              fit: BoxFit.fitHeight,
              color: Colors.grey[800],
              height: 30,
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.grey[800]),
              minimumSize: MaterialStateProperty.all<Size>(
                Size(
                  screenWidth - 70,
                  50,
                ),
              ),
            ),
            label: Text(
              'Facebook ' + langPack['Login'],
              textDirection: CurrentUser.textDirection,
            ),
            onPressed: () async {
              final userData = await initiateFacebookLogin();
              print(userData['email']);
              print(userData['id']);
              await Provider.of<APIHelper>(context, listen: false)
                  .autoLoginUser(
                name: userData['name'],
                email: userData['email'],
                fbLogin: true,
                username: userData['id'].toString(),
                password: userData['id'].toString(),
                fbPicture: userData['picture']['data']['url'],
              );

              Phoenix.rebirth(context);
              Navigator.pushNamedAndRemoveUntil(context, TabsScreen.routeName,
                  (Route<dynamic> route) => false);
            },
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'OR',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                child: Text(
                  langPack['Log in with email'],
                  textDirection: CurrentUser.textDirection,
                ),
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(AuthScreen.routeName, arguments: true);
                },
              ),
              TextButton(
                child: Text(
                  langPack['Sign up to'],
                  textDirection: CurrentUser.textDirection,
                ),
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(AuthScreen.routeName, arguments: false);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
