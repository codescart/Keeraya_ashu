import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../widgets/transaction_item.dart';

class TransactionsScreen extends StatelessWidget {
  static const routeName = '/transactions';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions',
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
        future: Provider.of<APIHelper>(context, listen: false)
            .getUserTransactions(userId: CurrentUser.id),
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
          if (snapshot.data.length > 0) {
            return ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: snapshot.data.length,
              itemBuilder: (_, i) {
                return TransactionItem(
                  name: snapshot.data[i]['product_name'],
                  amount: snapshot.data[i]['amount'],
                  paymentMethod: snapshot.data[i]['payment_method'],
                  status: snapshot.data[i]['status'],
                  transactionTime: snapshot.data[i]['transaction_time'],
                );
              },
            );
          }
          return Center(
            child: Text('There are no transactions'),
          );
        },
      ),
    );
  }
}
