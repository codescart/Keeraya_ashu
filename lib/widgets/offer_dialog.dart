import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../providers/languages.dart';

class Constants {
  Constants._();

  static const double padding = 20;
  static const double avatarRadius = 45;
}

class OfferDialogBox extends StatefulWidget {
  final String title,
      descriptions,
      text,
      ownerId,
      ownerName,
      productId,
      productTitle;

  // final Image img;

  const OfferDialogBox({
    Key key,
    this.title,
    this.descriptions,
    this.text,
    this.ownerId,
    this.ownerName,
    this.productId,
    this.productTitle,
    // this.img,
  }) : super(key: key);

  @override
  _OfferDialogBoxState createState() => _OfferDialogBoxState();
}

class _OfferDialogBoxState extends State<OfferDialogBox> {
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    final langPack = Provider.of<Languages>(context).selected;
    return Container(
      padding: EdgeInsets.only(
          left: Constants.padding,
          top: Constants.padding,
          right: Constants.padding,
          bottom: Constants.padding),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(Constants.padding),
          boxShadow: [
            BoxShadow(
                color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            widget.title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            widget.descriptions,
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 15,
          ),
          TextField(
            cursorColor: Colors.grey[800],
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.grey[200],
            ),
            onChanged: (value) {
              _message = value;
            },
          ),
          SizedBox(
            height: 22,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.white,
                  ),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey[800]),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  langPack['Cancel'],
                  textDirection: CurrentUser.textDirection,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.grey[800],
                  ),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () async {
                  await Provider.of<APIHelper>(context, listen: false)
                      .makeAnOffer(
                    email: '',
                    message: _message,
                    ownerId: widget.ownerId,
                    ownerName: widget.ownerName,
                    productId: widget.productId,
                    productTitle: widget.productTitle,
                    senderId: CurrentUser.id,
                    senderName: CurrentUser.name,
                    subject: 'Offer',
                    type: '',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Offer sent'),
                  ));
                  Navigator.of(context).pop();
                },
                child: Text(
                  langPack['Confirm'],
                  textDirection: CurrentUser.textDirection,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
