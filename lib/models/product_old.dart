import 'package:flutter/cupertino.dart';
import 'package:html_unescape/html_unescape.dart';

class ProductOld {
  String id;
  String name;
  bool isFeatured = false;
  bool isUrgent = false;
  bool isHighlighted = false;
  String location;
  String city;
  String state;
  String country;
  String cityId;
  String stateId;
  String countryId;
  String latLong;
  String createdAt;
  String expireDate;
  String categoryId;
  String subCategoryId;
  String category;
  String subCategory;
  String description;
  String phoneNumber;
  bool isFavourite;
  List<String> tags = [];
  bool showTag;
  int pictureCount;
  String picture;
  double price;
  String currency;
  bool currencyInLeft;
  String userName;
  String userId;
  String subcriptionTitle;
  String subcriptionImage;
  String status; // "active" or "inactive"
  bool isHidden = false;
  double featured;
  double urgent;
  double highlight;

  ProductOld(
      {@required this.id,
      @required this.name,
      this.isFeatured = false,
      this.isUrgent = false,
      this.isHighlighted = false,
      @required this.location,
      @required this.city,
      @required this.state,
      @required this.country,
      @required this.cityId,
      @required this.stateId,
      @required this.countryId,
      @required this.latLong,
      @required this.createdAt,
      @required this.expireDate,
      @required this.categoryId,
      @required this.subCategoryId,
      @required this.category,
      @required this.subCategory,
      this.description = '',
      this.phoneNumber = '',
      this.isFavourite = false,
      this.tags,
      this.showTag = false,
      this.pictureCount,
      this.picture = '',
      @required this.price,
      @required this.currency,
      this.currencyInLeft, // ?????????
      @required this.userName,
      @required this.userId,
      this.subcriptionTitle, // ???????????
      this.subcriptionImage, // ???????????
      @required this.status, // "active" or "inactive"
      this.isHidden = false,
      this.featured,
      this.highlight,
      this.urgent});

  factory ProductOld.fromJson(Map<String, dynamic> json) {
    final unescape = HtmlUnescape();
    final fetchedCurrency = unescape.convert(json['currency']);
    return ProductOld(
      id: json['id'] == null ? '' : json['id'],
      name: json['product_name'] == null ? '' : json['product_name'],
      isFeatured: json['featured'] == '1' ? true : false,
      isUrgent: json['urgent'] == '1' ? true : false,
      isHighlighted: json['highlight'] == '1' ? true : false,
      location: json['location'] == null ? '' : json['location'],
      city: json['city'] == null ? '' : json['city'],
      state: json['state'] == null ? '' : json['state'],
      country: json['country'] == null ? '' : json['country'],
      cityId: json['cityid'] == null ? '' : json['cityid'],
      stateId: json['stateid'] == null ? '' : json['stateid'],
      countryId: json['countryid'] == null ? '' : json['countryid'],
      latLong: json['latlong'] == null ? '' : json['latlong'],
      createdAt: json['created_at'],
      expireDate: json['expire_date'],
      // createdAt: DateTime.now(),
      // expireDate: DateTime.now(),
      categoryId: json['cat_id'] == null ? '' : json['cat_id'],
      subCategoryId: json['sub_cat_id'] == null ? '' : json['sub_cat_id'],
      category: json['category'] == null ? '' : json['category'],
      subCategory: json['sub_category'] == null ? '' : json['sub_category'],
      description: json['description'] == null ? '' : json['description'],
      phoneNumber: json['phone'] == null ? '' : json['phone'],
      isFavourite:
          json['favorite'] == '1' || json['favorite'] == true ? true : false,
      tags: [],
      showTag: json['showtag'] == '1' ? true : false,
      // pictureCount: json['pic_count'],
      picture: json['picture'] == null ? '' : json['picture'],
      price: double.parse(json['price']),
      currency: fetchedCurrency,
      currencyInLeft: json['currency_in_left'] == '1' ? true : false,
      userName: json['username'] == null ? '' : json['username'],
      userId: json['user_id'] == null ? '' : json['user_id'],
      subcriptionTitle:
          json['subcription_title'] == null ? '' : json['subcription_title'],
      subcriptionImage:
          json['subcription_image'] == null ? '' : json['subcription_image'],
      status: json['status'] == null ? '' : json['status'],
      // "active" or "inactive"
      isHidden: json['hide'] == '1' ? true : false,
      featured: double.tryParse(json["featured"].toString()),
      urgent: double.tryParse(json["urgent"].toString()),
      highlight: double.tryParse(json["highlight"].toString()),
    );
  }
}
