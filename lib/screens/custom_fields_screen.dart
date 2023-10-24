import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../providers/languages.dart';

class CustomFieldsScreen extends StatefulWidget {
  static const routeName = '/custom-fields';

  @override
  _CustomFieldsScreenState createState() => _CustomFieldsScreenState();
}

class _CustomFieldsScreenState extends State<CustomFieldsScreen> {
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
          langPack['Additional Info'],
          textDirection: CurrentUser.textDirection,
          style: TextStyle(
            color: Colors.grey[800],
          ),
        ),
        actions: [
          IconButton(
            color: Colors.grey[800],
            onPressed: () {
              setState(() {});
              bool allFieldsAreFilled = true;
              customData.forEach((element) {
                if (element["value"] == "") allFieldsAreFilled = false;
              });
              if (allFieldsAreFilled) Navigator.of(context).pop(customData);
            },
            icon: Icon(Icons.check),
          ),
        ],
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {});
            bool allFieldsAreFilled = true;
            customData.forEach((element) {
              if (element["value"] == "") allFieldsAreFilled = false;
            });
            if (allFieldsAreFilled) Navigator.of(context).pop(customData);
          },
        ),
      ),
      body: FutureBuilder(
        future: Provider.of<APIHelper>(context, listen: false)
            .getCustomDataByCategory(
                categoryId: pushedMap['chosenCatId'],
                subCategoryId: pushedMap['chosenSubCatId'] == ''
                    ? ''
                    : pushedMap['chosenSubCatId']),
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
                final matchingField = pushedMap['customData']?.firstWhere(
                  (element) {
                    return element['title'].toLowerCase() ==
                        snapshot.data[i]['title'].toLowerCase();
                  },
                  orElse: () => null,
                );
                customData.add({
                  'id': snapshot.data[i]['id'],
                  'type': snapshot.data[i]['type'],
                  'title': snapshot.data[i]['title'],
                  'value': matchingField != null ? matchingField['value'] : '',
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
                            return buildTextField(snapshot, ind);
                            break;
                          case 'textarea':
                            return Text('textarea');
                            break;
                          case 'radio-buttons':
                            return buildRadioButtons(snapshot, ind);
                            break;
                          case 'checkboxes':
                            return buildCheckBox(snapshot, ind);
                            break;
                          case 'drop-down':
                            return buildDropDwonList(snapshot, ind);
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
          return Center(child: Text('Has no additional data'));
        },
      ),
    );
  }

  Widget buildDropDwonList(AsyncSnapshot<dynamic> snapshot, int ind) {
    RegExp exp = RegExp('\<option value=\"[0-9]+\"\>');
    RegExp exp2 = RegExp('\<\/option\>');
    String dropDownString = snapshot.data[ind]['selectbox'].replaceAll(exp, '');
    dropDownString = dropDownString.replaceAll(exp2, ',');
    dropDownString = dropDownString.substring(0, dropDownString.length - 1);
    //saving each item value to send it back to the server
    List<String> value = snapshot.data[ind]['selectbox']
        .toString()
        .replaceAll(RegExp("[^0-9|]"), " ")
        .split(" ")
      ..removeWhere((element) => element == "");
    final dropDownList = dropDownString.split(',');

    final thisIndex = customData
        .indexWhere((element) => element['id'] == snapshot.data[ind]['id']);
    String title = "";
    if (value.indexOf(customData[thisIndex]['value']) != -1) {
      title = dropDownList[value.indexOf(customData[thisIndex]['value'])];
    } else {
      title = "";
    }
    return Column(
      children: [
        StatefulBuilder(
          builder: (ctx, setSta) {
            return SizedBox(
              width: MediaQuery.of(context).size.width - 40,
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
                      onChanged: (value) {
                        setState(() {
                          customData[thisIndex]['value'] = value;
                        });
                      },
                      hint: Text(
                        title,
                        softWrap: true,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      items: dropDownList.map<DropdownMenuItem<String>>(
                        (String dropDwonListItem) {
                          return DropdownMenuItem<String>(
                            child: Text(dropDwonListItem),
                            //the value for the server
                            value: value[
                                //getting the value index by the item
                                dropDownList.indexWhere(
                                    (element) => element == dropDwonListItem)],
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
  }

  Widget buildRadioButtons(AsyncSnapshot<dynamic> snapshot, int ind) {
    RegExp exp = RegExp(
        '\<div class\=\"(.*?)\"\>\<input class\=\"(.*?)\" type\=\"[a-z]+\" name\=\"(.*?)\" id\=\"[0-9]+\" value\=\"[0-9]+\"  \/\>\<label for\=\"[0-9]+\"\>');
    RegExp exp2 = RegExp('\<\/label\>\<\/div\>');

    //saving each item value to send it back to the server
    List<String> value = getValues(snapshot.data[ind]['radio'].toString());

    String radioString = snapshot.data[ind]['radio'].replaceAll(exp, '');
    radioString = radioString.replaceAll(exp2, ',');
    radioString = radioString.substring(0, radioString.length - 1);

    final radioList = radioString.split(',');
    final matchingRadio = customData.firstWhere(
      (element) => element['id'] == snapshot.data[ind]['id'],
      orElse: () => null,
    );
    final thisIndex = customData
        .indexWhere((element) => element['id'] == snapshot.data[ind]['id']);

    print("CustomFieldScreen build radio value: $value");
    print(
        "CustomFieldScreen build radio customData: ${customData[thisIndex]['value']}");
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
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
                childAspectRatio: 22 / 9,
              ),
              itemBuilder: (ctx, i) {
                return TextButton.icon(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all(Colors.grey[800]),
                  ), //
                  onPressed: () {
                    setState(() {
                      //setting the value for the server
                      customData[thisIndex]['value'] = value[i];
                    });
                  },
                  icon: Icon(
                    matchingRadio != null &&
                                matchingRadio['value'] == value[i] ||
                            matchingRadio['value'] == radioList[i]
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
  }

  Widget buildTextField(AsyncSnapshot<dynamic> snapshot, int ind) {
    final matchingTextField = customData.firstWhere(
      (element) => element['title'] == snapshot.data[ind]['title'],
      orElse: () => null,
    );
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
                    key: ValueKey(matchingTextField['value']),
                    initialValue: matchingTextField != null
                        ? matchingTextField['value']
                        : null,
                    decoration: InputDecoration(
                      labelText: snapshot.data[ind]['title'],
                    ),
                    onChanged: (value) {
                      final thisIndex = customData.indexWhere((element) =>
                          element['id'] == snapshot.data[ind]['id']);

                      customData[thisIndex]['value'] = value;
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
  }

  Widget buildCheckBox(AsyncSnapshot<dynamic> snapshot, int ind) {
    RegExp exp = RegExp(
        '\<div class\=\"(.*?)\"\>\<input class\=\"(.*?)\" type\=\"[a-z]+\" name\=\"(.*?)\" id\=\"[0-9]+\" value\=\"[0-9]+\"  \/\>\<label for\=\"[0-9]+\"\>');
    RegExp exp2 = RegExp('\<\/label\>\<\/div\>');

    //saving each item value to send it back to the server
    String value = getValues(snapshot.data[ind]['checkbox'].toString()).first;
    String checkboxString = snapshot.data[ind]['checkbox'].replaceAll(exp, '');
    checkboxString = checkboxString.replaceAll(exp2, ',');
    checkboxString = checkboxString.substring(0, checkboxString.length - 1);
    //checking if the snapshot data is valid or no
    if (!snapshot.data[ind]['checkbox'].toString().contains(exp)) {
      checkboxString = "";
    }
    final thisIndex = customData
        .indexWhere((element) => element['id'] == snapshot.data[ind]['id']);
    if (checkboxString.isNotEmpty)
      return Expanded(
        child: CheckboxListTile(
          value: customData[thisIndex]['value'] != "" &&
              customData[thisIndex]['value'] == value,
          onChanged: (checked) {
            setState(() {
              customData[thisIndex]['value'] = checked ? value : "";
            });
          },
          title: Text(checkboxString),
          tristate: customData[thisIndex]['value'] == "" &&
              customData[thisIndex]['value'] == value,
        ),
      );
    return Container();
  }

  List<String> getValues(String snapShotData) {
    final result = snapShotData.split(" ")
      ..removeWhere((element) => !element.startsWith("value"));

    for (int i = 0; i < result.length; i++) {
      result[i] = result[i].replaceAll(RegExp("[^0-9]"), '');
    }
    return result;
  }
}
