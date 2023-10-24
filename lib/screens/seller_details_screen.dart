import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/api_helper.dart';
import '../widgets/grid_products.dart';

class SellerDetailsScreen extends StatelessWidget {
  static const routeName = '/seller-details';

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> pushedMap =
        ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seller Details',
          style: TextStyle(
            color: Colors.grey[800],
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 3,
                child: Image.network(
                  pushedMap['seller_image'],
                  fit: BoxFit.fitWidth,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                pushedMap['seller_name'],
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'Joined: ${pushedMap['seller_createdat']}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              Divider(
                height: 20,
              ),
              Text(
                'Posted Products',
                style: TextStyle(
                  fontSize: 19,
                ),
              ),
              FutureBuilder(
                  future: Provider.of<APIHelper>(context).fetchProductsForUser(
                    userId: pushedMap['seller_id'],
                    limit: 100,
                    page: 1,
                  ),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.data.length > 0) {
                      return GridProducts(productsList: snapshot.data);
                    }
                    return Expanded(
                      child: Center(
                        child:
                            Text('There are no posted products from this user'),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
