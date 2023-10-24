import 'package:flutter/material.dart';

import '../widgets/account_list_tile.dart';

class PrivacyScreen extends StatelessWidget {
  static const routeName = '/privacy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Privacy',
          style: TextStyle(color: Colors.grey[800]),
        ),
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
      ),
      body: Column(
        children: [
          AccountListTile(
            title: 'Create password',
            onTapFunc: () {},
            trailing: Icon(
              Icons.arrow_right,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
