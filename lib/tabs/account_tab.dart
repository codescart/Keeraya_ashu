import 'dart:io';

import 'package:keeraya/screens/auth_screen.dart';
import 'package:keeraya/screens/color_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:image_picker/image_picker.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

import '../helpers/api_helper.dart';
import '../helpers/app_config.dart';
import '../helpers/current_user.dart';
import '../helpers/db_helper.dart';
import '../providers/languages.dart';
import '../screens/expire_ads_screen.dart';
import '../screens/membership_plan_screen.dart';
import '../screens/select_language_screen.dart';
import '../screens/start_screen.dart';
import '../screens/tabs_screen.dart';
import '../screens/transactions_screen.dart';
import '../widgets/account_list_tile.dart';

class AccountTab extends StatefulWidget {
  // Widget _customSelectableTileBuilder(String title, IconData icon) {
  //   return Column(
  //     children: [
  //       ListTile(
  //         horizontalTitleGap: 0,
  //         leading: Icon(
  //           icon,
  //           color: Colors.grey[800],
  //         ),
  //         title: Text(
  //           title,
  //           textAlign: TextAlign.start,
  //         ),
  //       ),
  //       DropdownButton(items: [
  //         DropdownMenuItem(child: Text('Selectable Item')),
  //       ],
  //       ),
  //     ],
  //   );
  // }

  @override
  _AccountTabState createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  var _selection;
  final _formKey = GlobalKey<FormState>();
  Map<String, String> langPack;

  // set up the buttons
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

  //! this don't delete user it reset password do it until apple approving app
  Widget continueButton(BuildContext ctx) {
    return TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.red[800]),
      ),
      child: Text(
        'delete',
        textDirection: CurrentUser.textDirection,
      ),
      onPressed: () async {
        await Provider.of<APIHelper>(ctx, listen: false).logout();
        await FacebookAuth.instance.logOut();
        Phoenix.rebirth(context);
        Navigator.pushNamedAndRemoveUntil(
            ctx, TabsScreen.routeName, (Route<dynamic> route) => false);
      },
    );
  }

  // reset password
  Widget restButton(BuildContext ctx) {
    return TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.grey[800]),
      ),
      child: Text(
        langPack['Log out'],
        textDirection: CurrentUser.textDirection,
      ),
      onPressed: () async {
        await Provider.of<APIHelper>(ctx, listen: false).forgetPassword(
          email: CurrentUser.email,
        );
        await Provider.of<APIHelper>(ctx, listen: false).logout();
        await FacebookAuth.instance.logOut();
        Phoenix.rebirth(context);
        Navigator.pushNamedAndRemoveUntil(
            ctx, TabsScreen.routeName, (Route<dynamic> route) => false);
      },
    );
  }

  Widget _customSelectableWidgetBuilder(
      {String title, String placeholderText}) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            //_showSearch();
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Stack(children: <Widget>[
                      Positioned(
                        right: -40.0,
                        top: -40.0,
                        child: InkResponse(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: CircleAvatar(
                            child: Icon(Icons.close),
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(title),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey[500],
                                )),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.grey[600],
                                ),
                                Text(langPack['Search…'],
                                    textDirection: CurrentUser.textDirection,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ]),
                  );
                });
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 0,
            ),
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[400],
              ),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Text(
                  placeholderText,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.grey[800],
                  ),
                ),
                Spacer(),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        SizedBox(height: 15),
        Divider(
          height: 0,
        ),
      ],
    );
  }

  // Future<void> _showSearch() async {
  //   await showSearch(
  //     context: context,
  //     delegate: TheSearch(),
  //     query: "any query",
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    langPack = Provider.of<Languages>(context).selected;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        shape: AppBarBottomShape(),
        elevation: 0,
        backgroundColor: HexColor(),
        title: Text(
          langPack['My Account'],
          textDirection: CurrentUser.textDirection,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(
            top: 0,
            left: 0,
            right: 0,
            bottom: 15,
          ),
          width: screenWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  textDirection: CurrentUser.textDirection,
                  children: [
                    //* commented
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () async {
                          if (CurrentUser.isLoggedIn) {
                            final picker = ImagePicker();
                            final imageFile = await picker.pickImage(
                                source: ImageSource.gallery);
                            final response = await Provider.of<APIHelper>(
                                    context,
                                    listen: false)
                                .updateProfilePic(
                                    userId: CurrentUser.id,
                                    imageFile: imageFile);
                            CurrentUser.picture = response != null
                                ? response['url']
                                : CurrentUser.picture;
                            await DBHelper.insert('user_info', {
                              'picture': CurrentUser.picture,
                            });
                            final picSnackBar = SnackBar(
                              content: Text(response['status'] == 'success'
                                  ? 'Image updated successfully'
                                  : 'Some error occurred'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(picSnackBar);
                            if (response != null &&
                                response['status'] == 'success') {
                              setState(() {});
                            }
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: CurrentUser.picture == ''
                              ? Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 70,
                                )
                              : null,
                          minRadius: 50,
                          foregroundImage: CurrentUser.picture != ''
                              ? NetworkImage(CurrentUser.picture)
                              : null,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        textDirection: CurrentUser.textDirection,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CurrentUser.isLoggedIn
                                ? CurrentUser.name
                                : 'Log in',
                            textDirection: CurrentUser.textDirection,
                            style: TextStyle(
                              fontSize: 27,
                              color: Colors.grey[800],
                            ),
                          ),
                          // if (CurrentUser.isLoggedIn)
                          //   Row(
                          //     children: [
                          //       Expanded(
                          //           child:
                          //               Text('delete my account all my data')),
                          //       Padding(
                          //         padding: const EdgeInsets.symmetric(
                          //             horizontal: 10),
                          //         child: IconButton(
                          //           onPressed: () => showDialog(
                          //             context: context,
                          //             builder: (BuildContext ctx) {
                          //               return AlertDialog(
                          //                 title: Text('ara u sure'),
                          //                 content: Text(
                          //                   'your account and all it\'s will be deleted \nyou will lose your subscription and you can\'t revert it back ',
                          //                   textDirection:
                          //                       CurrentUser.textDirection,
                          //                 ),
                          //                 actions: [
                          //                   cancelButton(ctx),
                          //                   continueButton(ctx),
                          //                 ],
                          //               );
                          //             },
                          //           ),
                          //           icon: Icon(
                          //             Icons.delete,
                          //             color: Theme.of(context).errorColor,
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   )
                          // ToDo commented to before apple review
                          // TextButton(
                          //   onPressed: () {
                          //     if (CurrentUser.isLoggedIn) {
                          //     } else if (!CurrentUser.isLoggedIn) {
                          //       Navigator.of(context).pushNamed(
                          //           AuthScreen.routeName,
                          //           arguments: true);
                          //     }
                          //   },
                          //   child: Text(
                          //     CurrentUser.isLoggedIn
                          //         ? ''
                          //         : langPack['Log in or sign up to continue'],
                          //     textDirection: CurrentUser.textDirection,
                          //     style: TextStyle(
                          //       color: Colors.grey[800],
                          //       decoration: TextDecoration.underline,
                          //     ),
                          //     maxLines: null,
                          //     softWrap: true,
                          //     overflow: TextOverflow.ellipsis,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (CurrentUser.isLoggedIn)
                AccountListTile(
                  title: langPack['Upgrade To Premium'],
                  // subtitle: 'Packages, orders, billing and invoices',
                  icon: Icons.star,
                  onTapFunc: () {
                    Navigator.of(context)
                        .pushNamed(MembershipPlanScreen.routeName);
                  },
                  trailing: Icon(
                    CurrentUser.language == 'Arabic'
                        ? Icons.arrow_left
                        : Icons.arrow_right,
                    color: Colors.grey[800],
                  ),
                ),
              // if (CurrentUser.isLoggedIn)
              //   AccountListTile(
              //     title: 'Settings',
              //     subtitle: 'Privacy and logout',
              //     icon: Icons.settings,
              //     onTapFunc: () {
              //       Navigator.of(context).pushNamed(SettingsScreen.routeName);
              //     },
              //     trailing: Icon(
              //       Icons.arrow_right,
              //       color: Colors.grey[800],
              //     ),
              //   ),
              if (CurrentUser.isLoggedIn)
                AccountListTile(
                  icon: Icons.timer,
                  title: 'Expire Ads',
                  // subtitle: 'Active, scheduled and expired orders',
                  onTapFunc: () {
                    Navigator.of(context).pushNamed(ExpireAdsScreen.routeName);
                  },
                  trailing: Icon(
                    CurrentUser.language == 'Arabic'
                        ? Icons.arrow_left
                        : Icons.arrow_right,
                    color: Colors.grey[800],
                  ),
                ),
              if (CurrentUser.isLoggedIn)
                AccountListTile(
                  title: 'Transaction',
                  // subtitle: 'Packages, orders, billing and invoices',
                  icon: Icons.credit_card_outlined,
                  onTapFunc: () {
                    Navigator.of(context)
                        .pushNamed(TransactionsScreen.routeName);
                  },
                  trailing: Icon(
                    CurrentUser.language == 'Arabic'
                        ? Icons.arrow_left
                        : Icons.arrow_right,
                    color: Colors.grey[800],
                  ),
                ),
              AccountListTile(
                title: langPack['Choose your language'],
                subtitle: CurrentUser.language,
                icon: Icons.language_outlined,
                onTapFunc: () {
                  Navigator.of(context)
                      .pushNamed(SelectLanguageScreen.routeName)
                      .then((value) {
                    setState(() {});
                  });
                },
                trailing: Icon(
                  CurrentUser.language == 'Arabic'
                      ? Icons.arrow_left
                      : Icons.arrow_right,
                  color: Colors.grey[800],
                ),
              ),
              AccountListTile(
                title: 'Rate Us',
                // subtitle: 'Help center and legal terms',
                icon: Icons.favorite_outline,
                onTapFunc: () async {
                  await LaunchReview.launch();
                },
                // trailing: Icon(
                //   Icons.arrow_right,
                //   color: Colors.grey[800],
                // ),
              ),
              AccountListTile(
                title: 'Share',
                // subtitle: 'Help center and legal terms',
                icon: Icons.share,
                onTapFunc: () async {
                  await Share.share(
                      'Download this Amazing application: https://play.google.com/store/apps/details?id=com.foundercodes.keeraya'); // Put Your App Url here.
                },
                // trailing: Icon(
                //   Icons.arrow_right,
                //   color: Colors.grey[800],
                // ),
              ),
              AccountListTile(
                title: langPack['Support'],
                // subtitle: 'Help center and legal terms',
                icon: Icons.phone,
                onTapFunc: () async {
                  final Uri _emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path:
                        'support@canders.in', // Put your Support Email Here
                    queryParameters: {'subject': 'Support'},
                  );
                  await urlLauncher.canLaunch(_emailLaunchUri.toString())
                      ? await urlLauncher.launch(_emailLaunchUri.toString())
                      : throw 'Could not launch ${_emailLaunchUri.toString()}';
                },
                // trailing: Icon(
                //   Icons.arrow_right,
                //   color: Colors.grey[800],
                // ),
              ),
              AccountListTile(
                title: langPack['Terms & Condition'],
                // subtitle: 'Help center and legal terms',
                icon: Icons.check_box_outlined,
                onTapFunc: () async {
                  await urlLauncher.canLaunch(AppConfig.termsPageLink)
                      ? await urlLauncher.launch(AppConfig.termsPageLink)
                      : throw 'Could not launch ${AppConfig.termsPageLink}';
                },
                // trailing: Icon(
                //   Icons.arrow_right,
                //   color: Colors.grey[800],
                // ),
              ),
              if (CurrentUser.isLoggedIn)
                AccountListTile(
                  title: langPack['Log out'],
                  icon: Icons.logout,
                  onTapFunc: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          title: Text(langPack['Log out']),
                          content: Text(
                            langPack['Are you sure you want to log out'],
                            textDirection: CurrentUser.textDirection,
                          ),
                          actions: [
                            cancelButton(ctx),
                            continueButton(ctx),
                          ],
                        );
                      },
                    );
                  },
                  // trailing: Icon(
                  //   Icons.arrow_right,
                  //   color: Colors.grey[800],
                  // ),
                ),
              SizedBox(
                height: 15,
              ),
              if (!CurrentUser.isLoggedIn)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextButton(
                    onPressed: () {
                      //* hid login with facebook on ios */
                      if (Platform.isIOS) {
                        Navigator.of(context)
                            .pushNamed(AuthScreen.routeName, arguments: true);
                      } else {
                        Navigator.of(context)
                            .pushNamed(StartScreen.routeName, arguments: true);
                      }
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all<Size>(Size(0, 50)),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(HexColor()),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: Text(
                      langPack['Log in or sign up to continue'],
                      textDirection: CurrentUser.textDirection,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              // Text(
              //   'Settings',
              //   style: TextStyle(
              //     fontSize: 16,
              //   ),
              //   textAlign: TextAlign.start,
              // ),
              // AccountListTile(
              //   title: 'Country',
              //   icon: Icons.blur_circular,
              //   onTapFunc: null,
              //   enableDivider: false,
              // ),
              // _customSelectableWidgetBuilder(
              //   title: 'Country',
              //   placeholderText: 'Select country',
              // ),
              // AccountListTile(
              //   title: 'State',
              //   icon: Icons.blur_circular,
              //   onTapFunc: null,
              //   enableDivider: false,
              // ),
              // _customSelectableWidgetBuilder(
              //   title: 'State',
              //   placeholderText: 'Select state',
              // ),
              // AccountListTile(
              //   title: 'City',
              //   icon: Icons.apartment,
              //   onTapFunc: null,
              //   enableDivider: false,
              // ),
              // _customSelectableWidgetBuilder(
              //   title: 'City',
              //   placeholderText: 'Select city',
              // ),
              // AccountListTile(
              //   title: 'Language',
              //   icon: Icons.language,
              //   onTapFunc: null,
              //   enableDivider: false,
              // ),
              // _customSelectableWidgetBuilder(
              //   title: 'Language',
              //   placeholderText: 'Select language',
              // ),
              // AccountListTile(
              //   title: 'Support',
              //   icon: Icons.help_outline,
              //   onTapFunc: () {},
              //   enableDivider: true,
              // ),
              // AccountListTile(
              //   title: 'Terms & Conditions',
              //   icon: Icons.check_box_outlined,
              //   onTapFunc: () {},
              //   enableDivider: false,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

enum WhyFarther { harder, smarter, selfStarter, tradingCharter }
