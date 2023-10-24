import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final String name;
  final String amount;
  final String paymentMethod;
  final String status;
  final String transactionTime;

  TransactionItem({
    this.name,
    this.amount,
    this.paymentMethod,
    this.status,
    this.transactionTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 0,
        left: 0,
        right: 0,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(7),
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(
              //   height: 10,
              // ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  name.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              Text('Amount: $amount'),
              Row(
                children: [
                  Text('Status: '),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      '$status'.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: status == 'success' ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ],
              ),
              Text('Transaction Time: $transactionTime'),
              // SizedBox(
              //   height: 10,
              // ),
              // Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
