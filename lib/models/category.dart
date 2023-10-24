import './sub_category.dart';

class Category {
  String id;
  String icon;
  String name;
  String picture;
  List<SubCategory> subCategory;

  Category({
    this.id,
    this.icon,
    this.name,
    this.picture,
    this.subCategory,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    //print('started json f');

    List<SubCategory> subCat = [];
    for (int i = 0; i < json['sub_category'].length; i++) {
      subCat.add(SubCategory(
        id: json['sub_category'][i]['id'],
        picture: json['sub_category'][i]['picture'],
        name: json['sub_category'][i]['name'],
      ));
      //print('added subcategory to list');
    }
    return Category(
      id: json['id'],
      icon: json['icon'],
      name: json['name'],
      picture: json['picture'],
      subCategory: subCat,
    );
  }
}
