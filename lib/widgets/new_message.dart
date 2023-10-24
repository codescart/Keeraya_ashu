import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../providers/languages.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class NewMessage extends StatefulWidget {
  final String fromUserId;

  NewMessage({this.fromUserId});

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _enteredMessage = '';
  final _messageController = TextEditingController();

  void _sendMessage(BuildContext ctx) async {
    final apiHelper = Provider.of<APIHelper>(ctx, listen: false);

    // Closes the screen keyboard
    FocusScope.of(context).unfocus();
    // final _userId = FirebaseAuth.instance.currentUser.uid;
    // final _userData =
    //     await FirebaseFirestore.instance.collection('users').doc(_userId).get();
    _messageController.clear();
    // FirebaseFirestore.instance.collection('chat').add({
    //   'text': _enteredMessage,
    //   'createdAt': Timestamp.now(),
    //   'userId': _userId,
    //   // We are getting username and userImage to avoid sending a lot of requests
    //   // to Firebase
    //   'username': _userData['username'],
    //   'userImage': _userData['image_url'],
    // });
    print(_enteredMessage);
    await apiHelper.sendChatMessage(
      fromId: CurrentUser.id,
      message: _enteredMessage,
      toId: widget.fromUserId,
    );
  }

  // Future builder is like a simple builder, but it needs a future
  // And it's running its builder function after future function is executed

  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    return Container(
      margin: EdgeInsets.only(
        top: 0,
        left: 15,
        right: 15,
        bottom: 15,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 3), //(x,y)
            blurRadius: 2.0,
          ),
        ],
      ),
      //margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.only(
        top: 0,
        left: 15,
        right: 15,
        bottom: 0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              controller: _messageController,
              cursorColor: Colors.grey[800],
              textDirection: CurrentUser.textDirection,
              decoration: InputDecoration(
                hintTextDirection: CurrentUser.textDirection,
                labelText: langPack['Enter message'],
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            onPressed: _enteredMessage.trim().isEmpty
                ? null
                : () {
                    _sendMessage(context);
                  },
          ),
        ],
      ),
    );
  }
}
