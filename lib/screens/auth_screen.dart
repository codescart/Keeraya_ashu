import 'package:keeraya/screens/color_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import './tabs_screen.dart';
import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../providers/languages.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/signup';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Creating a key for form, it helps us to submit it
  final _formKey = GlobalKey<FormState>();

  // bool _isLogin = false;
  String _userEmail = '';
  String _userName = '';
  String _name = '';
  String _userPassword = '';

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn googleSignIn = GoogleSignIn();
  bool _isLoading = false;
  bool _isLogin;
  bool firstLoad = true;
  bool isLoggedIn = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (firstLoad) {
      _isLogin = ModalRoute.of(context).settings.arguments;
      firstLoad = false;
    }
  }

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

  // A function that runs when we press ~Submit~ button
  void _trySubmit() {
    // The method "validate()" checks if all the text fields
    // are valid and returns "true" or "false"
    final isValid = _formKey.currentState.validate();

    // Remove the keyboard from the screen after submitting
    FocusScope.of(context).unfocus();

    // if (_userImageFile == null && !_isLogin) {
    //   Scaffold.of(context).showSnackBar(SnackBar(
    //     content: Text('Please pick an image'),
    //     backgroundColor: Theme.of(context).errorColor,
    //   ));
    //   return;
    // }

    // We are checking if our form is valid, and
    // are submitting our data to AuthScreen
    if (isValid) {
      // The method "save()" calls all the "onSaved" methods
      // from each TextFormField
      _formKey.currentState.save();

      // Submitting all the data to AuthScreen
      // And sending it to Firebase
      _submitAuthForm(
        // The "trim()" method removes any white spaces
        // from the beginning/end of the _userEmail
        // to avoid errors from Firebase
        _userEmail.trim(),
        _userPassword,
        _name,
        _userName,
        _isLogin,
        // Thid context is for SnackBar, to work properly
        context,
        //_userImageFile,
      );
      //Navigator.of(context).pop();
    }
  }

  void onLoginStatusChanged(bool isLoggedIn) {
    // setState(() {
    //   this.isLoggedIn = isLoggedIn;
    // });
  }

  void _submitAuthForm(
    String email,
    String password,
    String name,
    String userName,
    bool isLogin,
    BuildContext ctx,
    //File image,
  ) async {
    final apiHelper = Provider.of<APIHelper>(ctx, listen: false);
    //UserCredential userCredential;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        // Login the user in
        //userCredential = await _auth.signInWithEmailAndPassword(
        // email: email,
        // password: password,
        // );

        if (email.contains('@')) {
          await apiHelper.loginUserUsingEmail(email: email, password: password);
        } else {
          await apiHelper.loginUserUsingUsername(
              username: email, password: password);
        }
        Phoenix.rebirth(context);
        Navigator.pushNamedAndRemoveUntil(
            context, TabsScreen.routeName, (Route<dynamic> route) => false);
      } else {
        // Register new user
        //userCredential = await _auth.createUserWithEmailAndPassword(
        //   email: email,
        //   password: password,
        // );

        await apiHelper.registerUser(
            name: name, email: email, username: userName, password: password);
        await apiHelper.loginUserUsingUsername(
            username: userName, password: password);

        // First we upload the image, because we will need to provide its path
        // to the "users" collection
        // "ref()" gives us access to the storage root "bucket (folder tipa)"
        // ref is just an "address" to the future image
        // final ref = FirebaseStorage.instance
        //     .ref()
        //     .child('user_image')
        //     .child(userCredential.user.uid + 'jpg');

        // // Uploading the image to Firebase Storage
        // // putFile() does not return a future, so we use "whenComplete()" method
        // await ref.putFile(image).whenComplete(() => null);

        // // getDownloadURL return a Future which will return a URL to the image
        // final url = await ref.getDownloadURL();

        // We are creating a new Firestore document
        // with the USER ID (that's very important)
        // And we are setting new data in this document
        // The "username", "email", and "image" (path to the profile image)
        // await FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(userCredential.user.uid)
        //     .set({
        //   'username': userName,
        //   'email': email,
        //   //'image_url': url,
        // });
        // await _auth.signInWithEmailAndPassword(
        //   email: email,
        //   password: password,
        // );
        //Navigator.pushNamedAndRemoveUntil(
        //   context, TabsScreen.routeName, (Route<dynamic> route) => false);
        //Navigator.push(
        //  context, TabsScreen.routeName, (Route<dynamic> route) => false);
        Navigator.of(context)
            .pushReplacementNamed(AuthScreen.routeName, arguments: true);
      }
    } on PlatformException catch (error) {
      var message = 'An error occured, please check your credentials';

      if (error.message != null) {
        message = error.message;
      }

      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      if (error.message != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Theme.of(ctx).errorColor,
          ),
        );
      } else {
        print(error);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height;
    final langPack = Provider.of<Languages>(context).selected;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                "assets/images/logocander_dev.png",
                height: maxHeight * 0.15,
              ),
              Container(
                child: Text(
                  "${langPack['Welcome']},",
                  textDirection: CurrentUser.textDirection,
                  style: TextStyle(
                      color: HexColor(),
                      fontSize: 48,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 5),
              Container(
                child: Text(
                  "${langPack['Welcome log title']}.",
                  textDirection: CurrentUser.textDirection,
                  style: TextStyle(
                    color: HexColor(),
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_isLogin)
                      TextFormField(
                        cursorColor: Colors.grey[800],
                        // The key allows us to prevent
                        // the completion of other TextFormField
                        // when we switch the _isLogin
                        key: ValueKey('name'),
                        autocorrect: true,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value.isEmpty || value.length < 6) {
                            return 'Username must be at least 3 characters long';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          _name = value;
                        },

                        textDirection: CurrentUser.textDirection,
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.account_circle_rounded,
                            size: 20,
                          ),
                          labelText: langPack['First name'],
                          hintTextDirection: CurrentUser.textDirection,
                        ),
                      ),
                    SizedBox(
                      height: 15,
                    ),
                    if (!_isLogin)
                      TextFormField(
                        cursorColor: Colors.grey[800],
                        // The key allows us to prevent
                        // the completion of other TextFormField
                        // when we switch the _isLogin
                        key: ValueKey('username'),
                        autocorrect: true,
                        textCapitalization: TextCapitalization.words,
                        textDirection: CurrentUser.textDirection,
                        validator: (value) {
                          if (value.isEmpty || value.length < 6) {
                            return langPack[
                                'Please enter minimum 6 characters of Username'];
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          _userName = value;
                        },
                        decoration: InputDecoration(
                          suffixIcon: Icon(
                            Icons.account_circle_rounded,
                            size: 20,
                          ),
                          labelText: langPack['Username'],
                          hintTextDirection: CurrentUser.textDirection,
                        ),
                      ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      // The key allows us to prevent
                      // the completion of other TextFormField
                      // when we switch the _isLogin
                      key: ValueKey('email'),
                      cursorColor: Colors.grey[800],
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      enableSuggestions: false,
                      keyboardType: TextInputType.emailAddress,

                      style: TextStyle(
                        color: Colors.grey[800],
                      ),

                      textDirection: CurrentUser.textDirection,
                      decoration: InputDecoration(
                        labelText: langPack['Email/Username'],
                        suffixIcon: Icon(
                          Icons.account_circle_rounded,
                          size: 20,
                        ),
                        hintTextDirection: CurrentUser.textDirection,
                        fillColor: Colors.grey[800],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: HexColor(),
                          ),
                        ),
                      ),
                      validator: (value) {
                        // if (value.isEmpty || !value.contains('@')) {
                        //   return 'Please enter a valid email address';
                        // } else {
                        //   return null;
                        // }
                        return null;
                      },
                      onSaved: (value) {
                        _userEmail = value;
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      cursorColor: Colors.grey[800],

                      // The key allows us to prevent
                      // the completion of other TextFormField
                      // when we switch the _isLogin
                      key: ValueKey('password'),
                      validator: (value) {
                        // if (value.isEmpty || value.length < 7) {
                        //   return 'Password must be at least 7 characters long';
                        // } else {
                        //   return null;
                        // }
                        return null;
                      },
                      onSaved: (value) {
                        _userPassword = value;
                      },

                      textDirection: CurrentUser.textDirection,
                      decoration: InputDecoration(
                        suffixIcon: Icon(
                          Icons.lock_rounded,
                          size: 20,
                        ),
                        labelText: langPack['Password'],
                        hintTextDirection: CurrentUser.textDirection,
                      ),
                      // Hides the password
                      obscureText: true,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    /*TextButton(
                      // minWidth: 300,
                      // color: Colors.blue,
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(HexColor()),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(HexColor()),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 10),
                        child: Text(
                          _isLogin ? langPack['LOG IN'] : langPack['SIGN UP'],
                          textDirection: CurrentUser.textDirection,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onPressed: () {
                        _trySubmit();
                      },
                    ),*/
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        _trySubmit();
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: HexColor(),
                        ),
                        child: Center(
                          child: Text(
                            _isLogin ? langPack['LOG IN'] : langPack['SIGN UP'],
                            textDirection: CurrentUser.textDirection,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Text(
                    //       "OR",
                    //       style: TextStyle(fontSize: 20),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: 20,
                    // ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     (AppConfig.disableAdSocial)
                    //         ? InkWell(
                    //             onTap: () async {
                    //               print("start Login gmail");
                    //               GoogleSignInAccount response =
                    //                   await signInWithGoogle();
                    //               print(response);

                    //               await Provider.of<APIHelper>(context,
                    //                       listen: false)
                    //                   .autoLoginUser(
                    //                       name: response.displayName,
                    //                       email: response.email,
                    //                       fbLogin: true,
                    //                       username: response.displayName
                    //                           .split(' ')[0],
                    //                       fbPicture: response.photoUrl,
                    //                       password: response.id);

                    //               Phoenix.rebirth(context);
                    //               Navigator.pushNamedAndRemoveUntil(
                    //                   context,
                    //                   TabsScreen.routeName,
                    //                   (Route<dynamic> route) => false);
                    //             },
                    //             child: CircleAvatar(
                    //               backgroundColor: HexColor(),
                    //               child: Image.asset(
                    //                 'assets/images/google_icon.png',
                    //                 fit: BoxFit.fitHeight,
                    //                 color: Colors.white,
                    //                 height: 25,
                    //               ),
                    //             ),
                    //           )
                    //         : Container(),
                    //     SizedBox(
                    //       width: 20,
                    //     ),
                    //     (AppConfig.disableFbSocial)
                    //         ? InkWell(
                    //             onTap: () async {
                    //               final userData =
                    //                   await initiateFacebookLogin();
                    //               print(userData['email']);
                    //               print(userData['id']);
                    //               await Provider.of<APIHelper>(context,
                    //                       listen: false)
                    //                   .autoLoginUser(
                    //                 name: userData['name'],
                    //                 email: userData['email'],
                    //                 fbLogin: true,
                    //                 username: userData['id'].toString(),
                    //                 password: userData['id'].toString(),
                    //                 fbPicture: userData['picture']['data']
                    //                     ['url'],
                    //               );

                    //               Phoenix.rebirth(context);
                    //               Navigator.pushNamedAndRemoveUntil(
                    //                   context,
                    //                   TabsScreen.routeName,
                    //                   (Route<dynamic> route) => false);
                    //             },
                    //             child: CircleAvatar(
                    //               backgroundColor: HexColor(),
                    //               child: Image.asset(
                    //                 'assets/images/fb_icon.png',
                    //                 fit: BoxFit.fitHeight,
                    //                 color: Colors.white,
                    //                 height: 25,
                    //               ),
                    //             ),
                    //           )
                    //         : Container()
                    //   ],
                    // ),
                    /* Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Text(
                        //   _isLogin
                        //       ? 'Don\'t have an account ?'
                        //       : 'Already have an account ?',
                        //   style: TextStyle(
                        //     color: Colors.grey,
                        //   ),
                        // ),
                        TextButton(
                          child: Text(
                            _isLogin
                                ? langPack['SIGN UP']
                                : langPack['Sign In'],
                            textDirection: CurrentUser.textDirection,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                        ),
                      ],
                    ),*/
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin
                              ? 'Don\'t have an account ?'
                              : 'Already have an account ?',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin ? langPack['SIGN UP'] : langPack['LOG IN'],
                            textDirection: CurrentUser.textDirection,
                            style: TextStyle(
                                color: HexColor(),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: TextDecoration.underline),
                          ),
                        )
                      ],
                    )
                    // _signInButton(),
                    // _facebookSignInButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
