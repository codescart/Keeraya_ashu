import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/current_user.dart';
import '../providers/languages.dart';

class SelectLanguageScreen extends StatelessWidget {
  static const routeName = '/select-language';

  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey[800],
        iconTheme: IconThemeData(
          color: Colors.grey[800],
        ),
        title: Text(
          langPack['Choose your language'],
          textDirection: CurrentUser.textDirection,
          style: TextStyle(
            color: Colors.grey[800],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          children: [
            TextButton.icon(
              label: Text('English'),
              icon: Image.asset(
                'assets/images/american_flag.png',
                height: 25,
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey[800]),
                foregroundColor: MaterialStateProperty.all<Color>(
                  Colors.white,
                ),
              ),
              onPressed: () {
                CurrentUser.language = 'English';
                Navigator.of(context).pop();
              },
            ),
            TextButton.icon(
              label: Text('French'),
              icon: Image.asset(
                'assets/images/french_flag.png',
                height: 25,
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey[800]),
                foregroundColor: MaterialStateProperty.all<Color>(
                  Colors.white,
                ),
              ),
              onPressed: () {
                CurrentUser.language = 'French';
                Navigator.of(context).pop();
              },
            ),
            TextButton.icon(
              label: Text('Arabic'),
              icon: Image.asset(
                'assets/images/arabic_flag.png',
                height: 25,
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey[800]),
                foregroundColor: MaterialStateProperty.all<Color>(
                  Colors.white,
                ),
              ),
              onPressed: () {
                CurrentUser.language = 'Arabic';
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
