import 'dart:io';

import 'package:keeraya/screens/color_helper.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

import './custom_fields_screen.dart';
import './location_search_screen.dart';
import './tabs_screen.dart';
import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../models/location.dart';
import '../models/product_image.dart';
import '../pickers/user_image_picker.dart';
import '../providers/languages.dart';

class NewAdScreen extends StatefulWidget {
  static const routeName = '/new-ad';

  @override
  _NewAdScreenState createState() => _NewAdScreenState();
}

class _NewAdScreenState extends State<NewAdScreen> {
  File _userImageFile;
  final _formKey = GlobalKey<FormState>();
  bool _hidePhone = false;
  bool _negotiable = false;
  String _title = '';
  String _description = '';
  List<dynamic> _additionalInfo = [];
  double _price;
  String _phoneNumber = '';
  String _prodId = '';
  List<String> _itemScreen = [];
  String _city = '';
  String _countryCode = '';
  String _latitude = '';
  String _longitute = '';
  String _location = '';
  String _state = '';
  List<ProductImage> productImages = [];
  List<File> imagesList = [];

  void _pickedImage(List<File> images) {
    // _userImageFile = image;
    //
    for (int i = 0; i < images.length; i++) {
      productImages.add(ProductImage(
        file: images[i],
        isLocal: true,
      ));
    }
  }

  void _removeImage(int index) {
    try {
      print("current $index");
      productImages.removeAt(index);
      imagesList.removeAt(index);
    } catch (e) {
      print(e);
    }
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

      final response = await apiHelper.postUserProduct(
        userId: CurrentUser.id,
        title: _title,
        description: _description,
        price: _price.toString(),
        categoryId: cat.id,
        subCategoryId: subCat.id,
        additionalInfo: _additionalInfo,
        city: CurrentUser.prodLocation.cityId,
        countryCode: CurrentUser.prodLocation.countryCode,
        hidePhone: _hidePhone ? '1' : '0',
        latitude: CurrentUser.prodLocation.latitude,
        longitude: CurrentUser.prodLocation.longitude,
        location: CurrentUser.prodLocation.name,
        negotiable: _negotiable ? '1' : '0',
        phone: _phoneNumber,
        state: CurrentUser.prodLocation.stateId,
        productImages: productImages,
      );
      return response;

      //Navigator.of(context).pop();
    }
    return {
      'status': 'error',
      'message': 'Form is not valid',
    };
  }

  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    final Map pushedMap = ModalRoute.of(context).settings.arguments;
    return LoaderOverlay(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          foregroundColor: Colors.grey[800],
          backgroundColor: HexColor(),
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            langPack['Place an Ad'],
            textDirection: CurrentUser.textDirection,
            style: TextStyle(
              color: Colors.white,
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
                child: Text(
                  langPack['Cancel'],
                  textDirection: CurrentUser.textDirection,
                ),
                onPressed: () async {
                  Navigator.pushNamedAndRemoveUntil(context,
                      TabsScreen.routeName, (Route<dynamic> route) => false);
                },
              ),
              TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<ContinuousRectangleBorder>(
                      ContinuousRectangleBorder()),
                  backgroundColor: MaterialStateProperty.all<Color>(HexColor()),
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
                      pushedMap['chosenCat'],
                      pushedMap['chosenSubCat'],
                    );
                    context.loaderOverlay.hide();
                    if (message != null && message['status'] == 'success') {
                      Navigator.pushNamedAndRemoveUntil(
                          context,
                          TabsScreen.routeName,
                          (Route<dynamic> route) => false);
                      CurrentUser.prodLocation = Location();
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Success')));
                    } else {
                      print(message);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Something went wrong')));
                    }
                  }
                },
              ),
            ],
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 0,
                bottom: 15,
                left: 15,
                right: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    color: Colors.grey[100],
                    child: Column(
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
                          '${pushedMap['chosenCat'].name} > ${pushedMap['chosenSubCat'].name}',
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
                          cursorColor: Colors.grey[800],
                          textDirection: CurrentUser.textDirection,
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
                          imagesList: productImages,
                          deleteImageFn: _removeImage,
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
                          onPressed: () async {
                            CurrentUser.uploadingAd = true;
                            CurrentUser.fromSearchScreen = false;
                            await Navigator.of(context)
                                .pushNamed(LocationSearchScreen.routeName);
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          key: ValueKey('price'),
                          cursorColor: Colors.grey[800],
                          textDirection: CurrentUser.textDirection,
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
                            cursorColor: Colors.grey[800],
                            textDirection: CurrentUser.textDirection,
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
                              textDirection: CurrentUser.textDirection,
                              style: TextStyle(color: Colors.grey[800]),
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
                              textDirection: CurrentUser.textDirection,
                              style: TextStyle(color: Colors.grey[800]),
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
                                MaterialStateProperty.all(HexColor()),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                          ),
                          onPressed: () async {
                            final result = await Navigator.of(context)
                                .pushNamed(CustomFieldsScreen.routeName,
                                    arguments: {
                                  'chosenCatId': pushedMap['chosenCat'].id,
                                  'chosenSubCatId':
                                      pushedMap['chosenSubCat'].id,
                                  'customData': _additionalInfo,
                                });
                            _additionalInfo = result;
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
      ),
    );
  }
}
