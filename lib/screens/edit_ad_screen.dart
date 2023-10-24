import 'dart:io';

import 'package:keeraya/screens/location_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

import './custom_fields_screen.dart';
import './tabs_screen.dart';
import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../models/location.dart';
import '../models/product_image.dart';
import '../pickers/user_image_picker.dart';
import '../providers/languages.dart';

class EditAdScreen extends StatefulWidget {
  static const routeName = '/edit-ad';

  @override
  _EditAdScreenState createState() => _EditAdScreenState();
}

class _EditAdScreenState extends State<EditAdScreen> {
  Map<String, dynamic> prodData;
  bool firstLaunch = true;
  List<File> imageFiles = [];
  List<ProductImage> productImages = [];
  final _formKey = GlobalKey<FormState>();
  bool _hidePhone = false;
  bool _negotiable = false;
  String _title = '';
  String _description = '';
  List<dynamic> _additionalInfo = [];
  double _price;
  String _phoneNumber = '';
  String _prodId = '';
  String _itemScreen = '';
  String _city = '';
  String _countryCode = '';
  String _latitude = '';
  String _longitute = '';
  String _location = '';
  String _state = '';

  void _pickedImage(List<File> images) {
    for (int i = 0; i < images.length; i++) {
      productImages.add(ProductImage(
        file: images[i],
        isLocal: true,
      ));
    }
  }

  void _removeImage(int index) {
    productImages.removeAt(index);
  }

  void togglePhoneSwitch(bool value) {
    if (_hidePhone == false) {
      setState(() {
        _hidePhone = true;
        //textValue = 'Switch Button is ON';
      });
      print('Switch Button is ON');
    } else {
      setState(() {
        _hidePhone = false;
        //textValue = 'Switch Button is OFF';
      });
      print('Switch Button is OFF');
    }
  }

  void toggleNegotiableSwitch(bool value) {
    if (_negotiable == false) {
      setState(() {
        _negotiable = true;
        //textValue = 'Switch Button is ON';
      });
      print('Switch Button is ON');
    } else {
      setState(() {
        _negotiable = false;
        //textValue = 'Switch Button is OFF';
      });
      print('Switch Button is OFF');
    }
  }

  Future<Map> _trySubmit(BuildContext ctx, cat, subCat) async {
    final isValid = _formKey.currentState.validate();

    final apiHelper = Provider.of<APIHelper>(ctx, listen: false);

    if (isValid) {
      // The method "save()" calls all the "onSaved" methods
      // from each TextFormField
      _formKey.currentState.save();

      final response = await apiHelper.updateUserProduct(
        productId: prodData['id'],
        userId: prodData['seller_id'],
        title: _title,
        description: _description,
        price: _price.toString(),
        categoryId: prodData['category_id'],
        subCategoryId: prodData['sub_category_id'],
        additionalInfo: _additionalInfo,
        city: _city,
        countryCode: CurrentUser.location.countryCode != null &&
                CurrentUser.location.countryCode != ''
            ? CurrentUser.location.countryCode
            : 'IN',
        hidePhone: _hidePhone ? '1' : '0',
        latitude: CurrentUser.prodLocation.latitude,
        longitude: CurrentUser.prodLocation.longitude,
        location: _location,
        negotiable: _negotiable ? '1' : '0',
        phone: _phoneNumber,
        state: _state,
        productImages: productImages,
        // serverImg: prodData['images'],
        // memoryImg: imageFiles,
        // itemScreen: prodData['images'][0],
      );
      return response;
      //   .then((value) {
      // final Map res = value;
      // if (res['status'] == 'success') {
      //   Navigator.pushNamedAndRemoveUntil(
      //       context, TabsScreen.routeName, (Route<dynamic> route) => false);
      // } else {
      //   ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      //     content: Text(res['message']),
      //   ));
      //     }
      //   });
      // }).then((value) {});
      // print(_itemScreen);

    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> fetchedMap =
        ModalRoute.of(context).settings.arguments;
    prodData = fetchedMap['productData'];
    final langPack = Provider.of<Languages>(context, listen: false).selected;
    // final Map pushedMap = ModalRoute.of(context).settings.arguments;
    //
    if (firstLaunch) {
      for (int i = 0; i < prodData['images'].length; i++) {
        productImages.add(ProductImage(
          isLocal: false,
          urlPrefix: prodData['original_images_path'],
          url: prodData['images'][i],
        ));
      }

      _title = prodData['title'];
      _description = prodData['description'];
      _price = double.parse(prodData['price']);
      _phoneNumber = prodData['phone'];
      _prodId = prodData['id'];
      _itemScreen = prodData['images'][0];
      _city = fetchedMap['cityId'];
      CurrentUser.prodLocation.cityId = fetchedMap['cityId'];
      _latitude = prodData['map_latitude'];
      CurrentUser.prodLocation.latitude = prodData['map_latitude'];
      _longitute = prodData['map_longitude'];
      CurrentUser.prodLocation.longitude = prodData['map_longitude'];
      _location = prodData['location'];
      _state = fetchedMap['stateId'];
      CurrentUser.prodLocation.stateId = fetchedMap['stateId'];
      _negotiable = prodData['negotiable'] == '1' ? true : false;
      CurrentUser.prodLocation.name = _location;
      firstLaunch = false;
    }

    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          foregroundColor: Colors.grey[800],
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.grey[800]),
          title: Text(
            'Edit Ad',
            style: TextStyle(
              color: Colors.grey[800],
            ),
          ),
        ),
        bottomNavigationBar: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            textDirection: CurrentUser.textDirection,
            children: [
              TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<ContinuousRectangleBorder>(
                      ContinuousRectangleBorder()),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey[200]),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey[800]),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: MaterialStateProperty.all<Size>(Size(
                      MediaQuery.of(context).size.width / 2,
                      Platform.isIOS ? 60 : 40)),
                ),
                child: Text(langPack['Cancel']),
                onPressed: () async {
                  Navigator.pushNamedAndRemoveUntil(context,
                      TabsScreen.routeName, (Route<dynamic> route) => false);
                  CurrentUser.prodLocation = Location();
                  // await Provider.of<APIHelper>(context, listen: false)
                  //     .uploadProductImage(_userImageFile, _prodId);
                  // await Provider.of<APIHelper>(context, listen: false)
                  //     .deleteProducts(userId: CurrentUser.id, itemId: '87');
                },
              ),
              TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<ContinuousRectangleBorder>(
                      ContinuousRectangleBorder()),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey[800]),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: MaterialStateProperty.all<Size>(Size(
                      MediaQuery.of(context).size.width / 2,
                      Platform.isIOS ? 60 : 40)),
                ),
                child: Text(
                  langPack['Post'],
                  textDirection: CurrentUser.textDirection,
                ),
                onPressed: () async {
                  if (_additionalInfo.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill the additional info'),
                      ),
                    );
                  } else if (CurrentUser.prodLocation.cityId == '' ||
                      CurrentUser.prodLocation.stateId == '') {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Please select state and city'),
                    ));
                  } else {
                    context.loaderOverlay.show();
                    final message = await _trySubmit(
                      context,
                      prodData['category_name'],
                      prodData['sub_category_name'],
                    );
                    context.loaderOverlay.hide();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message['message'])));
                    if (message['status'] == 'success') {
                      Navigator.of(context).pop();
                      CurrentUser.prodLocation = Location();
                    }
                  }
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 0,
              bottom: 15,
              left: 15,
              right: 15,
            ),
            child: Column(
              textDirection: CurrentUser.textDirection,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.grey[100],
                  child: Column(
                    textDirection: CurrentUser.textDirection,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        langPack['This will be listed in'],
                        textDirection: CurrentUser.textDirection,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Text(
                        '${prodData['category_name']} > ${prodData['sub_category_name']}',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    textDirection: CurrentUser.textDirection,
                    children: [
                      TextFormField(
                        key: ValueKey('title'),
                        textDirection: CurrentUser.textDirection,
                        cursorColor: Colors.grey[800],
                        initialValue: _title,
                        decoration: InputDecoration(
                            hintTextDirection: CurrentUser.textDirection,
                            labelText: langPack[
                                'First, enter a short title to describe your listing']),
                        maxLength: 50,
                        validator: (value) {
                          if (value.isEmpty || value.length < 10) {
                            return 'Title must be at least 10 characters long';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          _title = value;
                        },
                      ),
                      SizedBox(
                        height: 9,
                      ),
                      TextFormField(
                        key: ValueKey('description'),
                        textDirection: CurrentUser.textDirection,
                        initialValue: _description,
                        cursorColor: Colors.grey[800],
                        decoration: InputDecoration(
                          labelText: langPack['Description'],
                          hintTextDirection: CurrentUser.textDirection,
                        ),
                        maxLines: null,
                        maxLength: 1000,
                        validator: (value) {
                          if (value.isEmpty || value.length < 10) {
                            return 'Description must be at least 10 characters long';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          _description = value;
                        },
                      ),
                      SizedBox(
                        height: 9,
                      ),
                      UserImagePicker(
                        imagePickFn: _pickedImage,
                        deleteImageFn: _removeImage,
                        imagesList: productImages,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextButton.icon(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.grey[800]),
                        ),
                        icon: Icon(Icons.location_on),
                        label: Consumer<CurrentUser>(
                            child: Text(
                              langPack['Location'],
                              textDirection: CurrentUser.textDirection,
                            ),
                            builder: (ctx, data, child) {
                              if (data.prodLocationGetter.name == '') {
                                return child;
                              }
                              return Text(data.prodLocationGetter.name);
                            }),
                        onPressed: () {
                          CurrentUser.uploadingAd = true;
                          Navigator.of(context)
                              .pushNamed(LocationSearchScreen.routeName)
                              .then((value) {
                            setState(() {
                              if (CurrentUser.prodLocation.stateId != '') {
                                _state = CurrentUser.prodLocation.stateId;
                                _city = CurrentUser.prodLocation.cityId;
                              }
                            });
                          });
                        },
                      ),
                      // TextFormField(
                      //   textDirection: CurrentUser.textDirection,
                      //   key: ValueKey('additionalInfo'),
                      //   cursorColor: Colors.grey[800],
                      //   decoration: InputDecoration(
                      //       hintTextDirection: CurrentUser.textDirection,
                      //       labelText: langPack['Additional Info']),
                      //   validator: (value) {
                      //     // if (value.isEmpty || value.length < 10) {
                      //     //   return 'Title must be at least 10 characters long';
                      //     // } else {
                      //     //   return null;
                      //     // }
                      //     return null;
                      //   },
                      //   onSaved: (value) {
                      //     _additionalInfo = value;
                      //   },
                      // ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        key: ValueKey('price'),
                        initialValue: _price.toString(),
                        textDirection: CurrentUser.textDirection,
                        cursorColor: Colors.grey[800],
                        decoration: InputDecoration(
                          labelText: langPack['Price'],
                          hintTextDirection: CurrentUser.textDirection,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a price';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          _price = double.parse(value);
                        },
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      if (!_hidePhone)
                        TextFormField(
                          key: ValueKey('phoneNumber'),
                          textDirection: CurrentUser.textDirection,
                          initialValue: _phoneNumber,
                          cursorColor: Colors.grey[800],
                          decoration: InputDecoration(
                            labelText: langPack['Phone number'],
                            hintTextDirection: CurrentUser.textDirection,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            // if (value.isEmpty || value.length < 10) {
                            //   return 'Title must be at least 10 characters long';
                            // } else {
                            //   return null;
                            // }
                            return null;
                          },
                          onSaved: (value) {
                            _phoneNumber = value;
                          },
                        ),
                      Row(
                        textDirection: CurrentUser.textDirection,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            langPack['Hide phone number'],
                            style: TextStyle(color: Colors.grey[800]),
                            textDirection: CurrentUser.textDirection,
                          ),
                          Switch(
                            value: _hidePhone,
                            onChanged: togglePhoneSwitch,
                            activeColor: Colors.grey[800],
                          ),
                        ],
                      ),
                      Row(
                        textDirection: CurrentUser.textDirection,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            langPack['Negotiable'],
                            style: TextStyle(color: Colors.grey[800]),
                            textDirection: CurrentUser.textDirection,
                          ),
                          Switch(
                            value: _negotiable,
                            onChanged: toggleNegotiableSwitch,
                            activeColor: Colors.grey[800],
                          ),
                        ],
                      ),
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.grey[800]),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                        ),
                        onPressed: () async {
                          print('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' +
                              _additionalInfo.toString());
                          final result = await Navigator.of(context).pushNamed(
                              CustomFieldsScreen.routeName,
                              arguments: {
                                'chosenCatId': prodData['category_id'],
                                'chosenSubCatId': prodData['sub_category_id'],
                                'customData': _additionalInfo,
                              });
                          _additionalInfo = result;
                          // _additionalInfo = _mappedAdditionalInfo.toString();
                        },
                        child: Text('+ ${langPack['Additional Info']}'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//       'user_id': userId,
//       'title': title,
//       'category_id': categoryId,
//       'subcategory_id': subCategoryId,
//       'country_code': 'IN',
//       'state': '',
//       'city': 'Hinoo Ranchi',
//       'description': description,
//       'location': 'Hinoo Ranchi',
//       'hide_phone': hidePhone,
//       'negotiable': '0',
//       'price': price,
//       'phone': phone,
//       'latitude': '',
//       'longitude': '',
//       'item_screen': '',
//       'additionalInfo': '',
