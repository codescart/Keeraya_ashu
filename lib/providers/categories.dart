import 'package:flutter/cupertino.dart';

class Categories with ChangeNotifier {
  Map<String, List<String>> _items = {
    'Real Estate': [
      'Land & Plot',
      'Office & Shop',
      'Houses-Apartments for Sale'
    ],
    'Cars': ['Land & Plot', 'Office & Shop', 'Houses-Apartments for Sale'],
    'Bikes & Scooty': [
      'Land & Plot',
      'Office & Shop',
      'Houses-Apartments for Sale'
    ],
  };
}
