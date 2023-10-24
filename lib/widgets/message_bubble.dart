import 'package:flutter/material.dart';

import '../helpers/current_user.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool seen;
  final String userName;
  final bool isMe;
  final Key key;
  final String chatImageUrl;
  final bool isLast;

  MessageBubble({
    this.message,
    this.isMe,
    this.key,
    this.userName,
    this.chatImageUrl,
    this.seen,
    this.time,
    this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe)
          CircleAvatar(
            backgroundImage: NetworkImage(chatImageUrl),
          ),
        Container(
          decoration: BoxDecoration(
            color: !isMe ? Colors.grey[300] : Colors.grey[800],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: !isMe ? Radius.circular(0) : Radius.circular(12),
              bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
            ),
          ),
          //width: 140,
          constraints: BoxConstraints(maxWidth: 200),
          margin: EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 4,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Column(
            textDirection: CurrentUser.textDirection,
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                userName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: !isMe
                      ? Colors.black
                      : Theme.of(context).accentTextTheme.headline6.color,
                ),
              ),
              Text(
                message,
                textAlign: isMe ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                  color: !isMe
                      ? Colors.black
                      : Theme.of(context).accentTextTheme.headline6.color,
                ),
              ),
              Text(
                time,
                textAlign: isMe ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                  fontSize: 12,
                  color: !isMe ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
        if (isMe && isLast)
          Icon(
            seen ? Icons.check_circle : Icons.check_circle_outline,
            color: Colors.grey[600],
            size: 20,
          ),
        // if (isMe)
        //   CircleAvatar(
        //     backgroundImage: NetworkImage(chatImageUrl),
        //   ),
      ],
    );
  }
}
