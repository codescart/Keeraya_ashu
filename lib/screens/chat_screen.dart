import 'package:flutter/material.dart';

// import 'package:intl/intl.dart' as intl;

import '../widgets/messages.dart';
import '../widgets/new_message.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String fromUserId;

  @override
  Widget build(BuildContext context) {
    final Map pushedMap = ModalRoute.of(context).settings.arguments;
    fromUserId = pushedMap['from_user_id'];
    final fromUserName = pushedMap['from_user_fullname'];
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.grey[800], //change your color here
        ),
        title: ListTile(
          leading: CircleAvatar(
            foregroundImage: NetworkImage(
              pushedMap['from_user_picture'] ??
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRWmwCfIZexKkZuFni_fnWvm8mkOTzoRtlqgQ&usqp=CAU",
            ),
          ),
          title: Text(
            fromUserName,
            style: TextStyle(
              color: Colors.grey[800],
            ),
            // textDirection: CurrentUser.textDirection,
          ),
          subtitle: Text(pushedMap['status'] ?? ""),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Messages(
                fromUserId: fromUserId,
              ),
            ),
          ),
          NewMessage(fromUserId: fromUserId),
        ],
      ),
    );
  }
}
