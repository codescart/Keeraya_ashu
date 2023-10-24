import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../providers/languages.dart';

class FilterScreen extends StatefulWidget {
  static const routeName = '/filter';

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  var langPack;
  List<Map<String, String>> customData = [];
  bool firstLoad = true;

  @override
  Widget build(BuildContext context) {
    langPack = Provider.of<Languages>(context, listen: false).selected;
    final Map<String, dynamic> pushedMap =
        ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          langPack['Filter by'],
          textDirection: CurrentUser.textDirection,
          style: TextStyle(
            color: Colors.grey[800],
          ),
        ),
        actions: [
          IconButton(
            color: Colors.grey[800],
            onPressed: () {
              customData.removeWhere((element) => element['value'] == '');
              Navigator.of(context).pop(customData);
            },
            icon: Icon(Icons.check),
          ),
        ],
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: Provider.of<APIHelper>(context, listen: false)
            .getCustomDataByCategory(
                categoryId: pushedMap['chosenCat'].id,
                subCategoryId: pushedMap['chosenSubCat'] == ''
                    ? ''
                    : pushedMap['chosenSubCat'].id),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              firstLoad) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data != null && snapshot.data.length > 0) {
            if (firstLoad) {
              for (var i = 0; i < snapshot.data.length; i++) {
                customData.add({
                  'id': snapshot.data[i]['id'],
                  'type': snapshot.data[i]['type'],
                  'value': '',
                });
              }
              firstLoad = false;
            }
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount: snapshot.data.length,
                      itemBuilder: (ctx, ind) {
                        switch (snapshot.data[ind]['type']) {
                          case 'text-field':
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      snapshot.data[ind]['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: StatefulBuilder(
                                        builder: (ctx, setS) {
                                          return TextFormField(
                                            initialValue: customData.firstWhere(
                                                            (element) =>
                                                                element['id'] ==
                                                                snapshot.data[
                                                                    ind]['id'])[
                                                        'value'] ==
                                                    ''
                                                ? null
                                                : customData.firstWhere(
                                                    (element) =>
                                                        element['id'] ==
                                                        snapshot.data[ind]
                                                            ['id'])['value'],
                                            decoration: InputDecoration(
                                              labelText: snapshot.data[ind]
                                                  ['title'],
                                            ),
                                            onChanged: (value) {
                                              final thisIndex = customData
                                                  .indexWhere((element) =>
                                                      element['id'] ==
                                                      snapshot.data[ind]['id']);

                                              setS(() {
                                                customData[thisIndex]['value'] =
                                                    value;
                                              });
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                              ],
                            );
                            break;
                          case 'textarea':
                            return Text('textarea');
                            break;
                          case 'radio-buttons':
                            RegExp exp = RegExp(
                                '\<div class\=\"(.*?)\"\>\<input class\=\"(.*?)\" type\=\"[a-z]+\" name\=\"(.*?)\" id\=\"[0-9]+\" value\=\"[0-9]+\"  \/\>\<label for\=\"[0-9]+\"\>');
                            RegExp exp2 = RegExp('\<\/label\>\<\/div\>');
                            String radioString =
                                snapshot.data[ind]['radio'].replaceAll(exp, '');
                            radioString = radioString.replaceAll(exp2, ', ');
                            radioString = radioString.substring(
                                0, radioString.length - 2);
                            final radioList = radioString.split(',');
                            print(radioList);
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  snapshot.data[ind]['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                StatefulBuilder(
                                  builder: (ctx, setSt) {
                                    return GridView.builder(
                                      itemCount: radioList.length,
                                      shrinkWrap: true,
                                      physics: ScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        childAspectRatio: 22 / 9,
                                      ),
                                      itemBuilder: (ctx, i) {
                                        return TextButton.icon(
                                          style: ButtonStyle(
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.grey[800]),
                                          ),
                                          onPressed: () {
                                            final thisIndex = customData
                                                .indexWhere((element) =>
                                                    element['id'] ==
                                                    snapshot.data[ind]['id']);
                                            setSt(() {
                                              customData[thisIndex]['value'] =
                                                  radioList[i];
                                            });
                                          },
                                          icon: Icon(
                                            customData.firstWhere((element) =>
                                                        element['id'] ==
                                                        snapshot.data[ind]
                                                            ['id'])['value'] ==
                                                    radioList[i]
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_unchecked,
                                          ),
                                          label: Text(radioList[i]),
                                        );
                                      },
                                    );
                                  },
                                ),
                                Divider(),
                              ],
                            );
                            break;
                          case 'checkboxes':
                            return Text('checkboxes');
                            break;
                          case 'drop-down':
                            RegExp exp = RegExp('\<option value=\"[0-9]+\"\>');
                            RegExp exp2 = RegExp('\<\/option\>');
                            String dropDownString = snapshot.data[ind]
                                    ['selectbox']
                                .replaceAll(exp, '');
                            dropDownString =
                                dropDownString.replaceAll(exp2, ', ');
                            dropDownString = dropDownString.substring(
                                0, dropDownString.length - 2);
                            // dropDownString = '[' + dropDownString + ']';

                            final dropDownList = dropDownString.split(',');
                            // print(dropDownString);
                            print(dropDownList);
                            return Column(
                              children: [
                                StatefulBuilder(
                                  builder: (ctx, setSta) {
                                    return SizedBox(
                                      width: MediaQuery.of(context).size.width -
                                          40,
                                      child: Row(
                                        children: [
                                          Text(
                                            snapshot.data[ind]['title'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: DropdownButton<String>(
                                              value: customData.firstWhere(
                                                              (element) =>
                                                                  element[
                                                                      'id'] ==
                                                                  snapshot.data[
                                                                          ind]
                                                                      ['id'])[
                                                          'value'] ==
                                                      ''
                                                  ? null
                                                  : customData.firstWhere(
                                                      (element) =>
                                                          element['id'] ==
                                                          snapshot.data[ind]
                                                              ['id'])['value'],
                                              onChanged: (value) {
                                                final thisIndex = customData
                                                    .indexWhere((element) =>
                                                        element['id'] ==
                                                        snapshot.data[ind]
                                                            ['id']);
                                                setSta(() {
                                                  customData[thisIndex]
                                                      ['value'] = value;
                                                });
                                              },
                                              hint: Text(
                                                'Select ${snapshot.data[ind]['title']}',
                                                softWrap: true,
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              // value: 'Select ${snapshot.data[ind]['title']}',
                                              items: dropDownList.map<
                                                  DropdownMenuItem<String>>(
                                                (String element) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    child: Text(element),
                                                    value: element,
                                                  );
                                                },
                                              ).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Divider(),
                              ],
                            );
                            break;
                          default:
                            return Text('Default case');
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return Center(
            child: Text(''),
          );
        },
      ),
    );
  }
}
