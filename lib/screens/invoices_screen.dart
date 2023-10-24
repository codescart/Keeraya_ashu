import 'package:flutter/material.dart';

class InvoicesScreen extends StatelessWidget {
  static const routeName = '/invoices';

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
