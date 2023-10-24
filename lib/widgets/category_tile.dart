import 'package:flutter/material.dart';

import '../models/category.dart';
import '../screens/sub_categories_screen.dart';

class CategoryTile extends StatelessWidget {
  // final String id;
  // final String name;
  // final List<SubCategory> subCategories;
  final Category category;
  Widget catIcon;

  CategoryTile({
    this.category,
    // this.id,
    // this.name,
    // this.subCategories,
  });

  Widget catImageBuilder(String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.network(
        category.picture,
        fit: BoxFit.fill,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (category.id) {
      case '4':
        catIcon = catImageBuilder('assets/images/house.png');
        break;
      case '1':
        catIcon = catImageBuilder('assets/images/suv.png');
        break;
      case '9':
        catIcon = catImageBuilder('assets/images/bycicle.png');
        break;
      case '14':
        catIcon = catImageBuilder('assets/images/sofa.png');
        break;
      case '2':
        catIcon = catImageBuilder('assets/images/phone-camera.png');
        break;
      case '3':
        catIcon = catImageBuilder('assets/images/tv.png');
        break;
      case '11':
        catIcon = catImageBuilder('assets/images/football.png');
        break;
      case '6':
        catIcon = catImageBuilder('assets/images/agreement.png');
        break;
      case '10':
        catIcon = catImageBuilder('assets/images/dog.png');
        break;
      case '7':
        catIcon = catImageBuilder('assets/images/consult.png');
        break;
      case '12':
        catIcon = catImageBuilder('assets/images/book.png');
        break;
      case '5':
        catIcon = catImageBuilder('assets/images/dress.png');
        break;
      default:
        catIcon = catImageBuilder('assets/images/category.png');
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          SubCategoriesScreen.routeName,
          arguments: {
            'chosenCat': category,
            'newAd': false,
            'editAd': false,
          },
        );
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          child: Column(
            children: [
              // FractionallySizedBox(
              //   widthFactor: 0.6,
              //   heightFactor: 0.6,
              //   child: catIcon,
              // ),
              Flexible(flex: 4, child: catIcon),
              Flexible(
                flex: 3,
                child: Text(
                  category.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
