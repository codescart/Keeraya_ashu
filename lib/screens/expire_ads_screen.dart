import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../widgets/grid_products.dart';

class ExpireAdsScreen extends StatelessWidget {
  static const routeName = '/expire-ads';

  @override
  Widget build(BuildContext context) {
    final apiHelper = Provider.of<APIHelper>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expire Ads',
          style: TextStyle(
            color: Colors.grey[800],
          ),
        ),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: apiHelper.fetchExpireProductsForUser(userId: CurrentUser.id),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                width: 100,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  // color: Colors.black,
                ),
              ),
            );
          }
          if (snapshot.hasError)
            return Center(
              child: Text("An error occured"),
            );
          if (snapshot.data.length > 0)
            return GridProducts(
              productsList: snapshot.data,
              isMyAds: true,
            );
          return Center(
            child: Text("No expired products found"),
          );
        },
      ),
    );
  }
}
