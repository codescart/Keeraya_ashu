import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../providers/products.dart';

class NotificationsScreen extends StatefulWidget {
  static const routeName = '/notifications';

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List _notifications = [];
  bool firstBuild = true;

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<Products>(context);

    if (_notifications.length == 0) {
      _notifications = productsProvider.notificationItems;
      firstBuild = _notifications.length == 0 ? true : false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
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
      body: RefreshIndicator(
        onRefresh: () {
          setState(() {
            // productsProvider.clearProductsCache();
            // categories = <Category>[];
            // latestProducts = <Product>[];
            // featuredProducts = <Product>[];
            // _listLength = 1;
            // firstBuild = true;
            // page = 1;
            // allPagesAreFetched = false;
          });
          return Future.delayed(Duration(milliseconds: 400));
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (firstBuild)
                FutureBuilder(
                  future: Provider.of<APIHelper>(context, listen: false)
                      .getNotificationMessage(userId: CurrentUser.id),
                  builder: (ctx, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                            width: 100,
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.grey,
                              // color: Colors.black,
                            ),
                          ),
                        );
                        break;
                      default:
                        if (snapshot.hasError) {
                          return Container(
                              child: Text(snapshot.error.toString()));
                        }
                        if (snapshot.data.length > 0) {
                          _notifications = snapshot.data;
                          productsProvider.notifications = snapshot.data;
                          return ListView.builder(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              itemCount: snapshot.data.length,
                              itemBuilder: (ctx, i) {
                                return ListTile(
                                  title:
                                      Text(snapshot.data[i]['product_title']),
                                  subtitle: Text(snapshot.data[i]['message']),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                  ),
                                );
                              });
                        }
                        return Center(
                          child: Text('There are no notifications'),
                        );
                    }
                  },
                ),
              if (!firstBuild && _notifications.length > 0)
                // _notifications = snapshot.data;
                // productsProvider.notifications = snapshot.data;
                ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: _notifications.length,
                    itemBuilder: (ctx, i) {
                      return ListTile(
                        title: Text(_notifications[i]['product_title']),
                        subtitle: Text(_notifications[i]['message']),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 15,
                        ),
                      );
                    }),
              if (!firstBuild && _notifications.length == 0)
                Center(
                  child: Text('There are no notifications'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
