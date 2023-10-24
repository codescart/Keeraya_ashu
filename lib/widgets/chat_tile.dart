import 'package:flutter/material.dart';

import '../helpers/current_user.dart';
import '../models/location.dart';
import '../screens/chat_screen.dart';

class ChatTile extends StatelessWidget {
  final String sellerId;
  final String sellerName;
  final String pictureUrl;
  final String status;

  ChatTile({
    this.sellerId,
    this.sellerName,
    this.pictureUrl,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    print('Picuuuuureee' + pictureUrl);
    return ListTile(
      trailing: CurrentUser.language == 'Arabic'
          ? CircleAvatar(
              foregroundImage: NetworkImage(pictureUrl),
            )
          : Text(
              status,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
      leading: CurrentUser.language == 'Arabic'
          ? Text(
              status,
              style: TextStyle(
                color: Colors.grey,
              ),
            )
          : CircleAvatar(
              foregroundImage: NetworkImage(pictureUrl),
            ),
      title: Text(
        sellerName,
        textAlign:
            CurrentUser.language == 'Arabic' ? TextAlign.end : TextAlign.start,
      ),
      //subtitle: Text('Name of ad'),
      isThreeLine: false,
      onTap: () {
        CurrentUser.prodLocation = Location();
        Navigator.of(context).pushNamed(ChatScreen.routeName, arguments: {
          'from_user_id': "$sellerId",
          'from_user_fullname': sellerName,
          'from_user_picture': pictureUrl,
          'status': status,
        });
      },
      // trailing: null,
    );
  }
}
