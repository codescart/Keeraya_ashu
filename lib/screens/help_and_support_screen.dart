import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/current_user.dart';
import '../providers/languages.dart';
import '../widgets/account_list_tile.dart';

class HelpAndSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          langPack['Support'],
          textDirection: CurrentUser.textDirection,
          style: TextStyle(color: Colors.grey[800]),
        ),
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
      ),
      body: Column(
        children: [
          AccountListTile(
            title: 'Help Center',
            subtitle: 'See FAQ and contact support',
            onTapFunc: () {},
            trailing: Icon(
              Icons.arrow_right,
              color: Colors.grey[800],
            ),
          ),
          AccountListTile(
            title: 'Rate Us',
            subtitle: 'If you love our app, please take a moment to rate it',
            onTapFunc: () {},
            trailing: Icon(
              Icons.arrow_right,
              color: Colors.grey[800],
            ),
          ),
          AccountListTile(
            title: 'Invite friends to Classified',
            subtitle: 'Invite your friends to buy and sell',
            onTapFunc: () {},
          ),
          AccountListTile(
            title: 'Become a beta tester',
            subtitle: 'Test new features in advance',
            onTapFunc: () {},
            trailing: Icon(
              Icons.arrow_right,
              color: Colors.grey[800],
            ),
          ),
          AccountListTile(
            title: 'Version',
            subtitle: '1.0.0',
            onTapFunc: null,
          ),
        ],
      ),
    );
  }
}
