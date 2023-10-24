import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './tabs_screen.dart';
import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../providers/languages.dart';
import '../widgets/account_list_tile.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';
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

  Widget continueButton(BuildContext ctx) {
    return TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.grey[800]),
      ),
      child: Text(
        langPack['Log out'],
        textDirection: CurrentUser.textDirection,
      ),
      onPressed: () async {
        await Provider.of<APIHelper>(ctx, listen: false).logout();
        Navigator.pushNamedAndRemoveUntil(
            ctx, TabsScreen.routeName, (Route<dynamic> route) => false);
      },
    );
  }

  // set up the AlertDialog

  @override
  Widget build(BuildContext context) {
    langPack = Provider.of<Languages>(context).selected;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(color: Colors.grey[800]),
        ),
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
      ),
      body: Column(
        children: [
          // AccountListTile(
          //   title: 'Privacy',
          //   subtitle: 'Create password',
          //   onTapFunc: () {
          //     Navigator.of(context).pushNamed(PrivacyScreen.routeName);
          //   },
          //   trailing: Icon(
          //     Icons.arrow_right,
          //     color: Colors.grey[800],
          //   ),
          // ),
          // AccountListTile(
          //   title: 'Notifications',
          //   subtitle: 'Recommendations & Spcial communications',
          //   onTapFunc: () {},
          // ),
          AccountListTile(
            title: 'Logout',
            onTapFunc: () {
              showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  return AlertDialog(
                    title: Text(
                      langPack['Log out'],
                      textDirection: CurrentUser.textDirection,
                    ),
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
          ),
          // AccountListTile(
          //   title: 'Logout from all devices',
          //   onTapFunc: () {
          //     showDialog(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           title: Text("Logout from all devices"),
          //           content: Text(
          //               "Yoru will be logged out from all browsers and app sessions. Do you want to continue?"),
          //           actions: [
          //             cancelButton,
          //             continueButton,
          //           ],
          //         );
          //       },
          //     );
          //   },
          // ),
          // AccountListTile(
          //   title: 'Deactivate account and delete my data',
          //   onTapFunc: () {
          //     showDialog(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           content: Text(
          //               "Are you sure you want to deactivate your account? This action cannot be undone"),
          //           actions: [
          //             cancelButton,
          //             continueButton,
          //           ],
          //         );
          //       },
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
