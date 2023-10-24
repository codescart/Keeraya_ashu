import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './membership_plan_screen.dart';
import '../helpers/api_helper.dart';
import '../providers/languages.dart';
import '../widgets/account_list_tile.dart';

class InvoicesAndBillingScreen extends StatelessWidget {
  static const routeName = '/invoices-billing-settings';

  @override
  Widget build(BuildContext context) {
    final apiHelper = Provider.of<APIHelper>(context);
    final langPack = Provider.of<Languages>(context).selected;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Invoices & Billing',
          style: TextStyle(color: Colors.grey[800]),
        ),
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
      ),
      body: Column(
        children: [
          AccountListTile(
            title: langPack['Upgrade To Premium'],

            // subtitle: 'Sell faster, more & at higher margins with packages',
            onTapFunc: () async {
              Navigator.of(context).pushNamed(MembershipPlanScreen.routeName);
            },
            trailing: Icon(
              Icons.arrow_right,
              color: Colors.grey[800],
            ),
          ),
          AccountListTile(
            title: langPack['My Ads'],
            // subtitle: 'Active, scheduled and expired orders',
            onTapFunc: () {
              // Navigator.of(context).pushNamed(MyOrdersScreen.routeName);
            },
            trailing: Icon(
              Icons.arrow_right,
              color: Colors.grey[800],
            ),
          ),
          // AccountListTile(
          //   title: 'Invoices',
          //   subtitle: 'See and download your invoices',
          //   onTapFunc: () {
          //     Navigator.of(context).pushNamed(InvoicesScreen.routeName);
          //   },
          //   trailing: Icon(
          //     Icons.arrow_right,
          //     color: Colors.grey[800],
          //   ),
          // ),
          // AccountListTile(
          //   title: 'Billing Information',
          //   subtitle: 'Edit your billing name, address, etc.',
          //   onTapFunc: () {},
          //   trailing: Icon(
          //     Icons.arrow_right,
          //     color: Colors.grey[800],
          //   ),
          // ),
        ],
      ),
    );
  }
}
