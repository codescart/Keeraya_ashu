import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './message_bubble.dart';
import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';

class Messages extends StatelessWidget {
  final String fromUserId;

  Messages({this.fromUserId});

  String UNENCODED_PATH = 'api/v1/';
  String BASE_URL = "Mark_Classified.org";
  String FETCH_CHAT_URL = "get_all_msg";

  Future fetchChatMessage({
    @required sesUserId,
    @required clientId,
  }) async {
    final url = Uri.https(APIHelper.BASE_URL, APIHelper.UNENCODED_PATH, {
      'action': APIHelper.FETCH_CHAT_URL,
      'ses_userid': sesUserId,
      'client_id': clientId,
    });
    print(url);
    print("response");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      print(response.body);
      final decodedData = json.decode(response.body);
      return decodedData;
    } else {
      print(response.statusCode);
      throw Exception('Error');
    }
  }

  Stream fetchChatMessages({sesUserId, clientId}) async* {
    while (true) {
      yield await fetchChatMessage(clientId: clientId, sesUserId: sesUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            fetchChatMessages(clientId: fromUserId, sesUserId: CurrentUser.id),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                width: 100,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey,
                  // color: Colors.black,
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            return ListView.builder(
                reverse: true,
                itemCount: snapshot.data.length,
                itemBuilder: (ctx, i) {
                  return MessageBubble(
                    userName: snapshot.data[i]['sender_username'],
                    message: snapshot.data[i]['message'],
                    isMe: snapshot.data[i]['sender_id'] == CurrentUser.id
                        ? true
                        : false,
                    key: ValueKey(DateTime.now()),
                    chatImageUrl:
                        'https://${APIHelper.IMAGE_URL}${snapshot.data[i]['sender_pic']}',
                    seen: snapshot.data[i]['seen'] == '1' ? true : false,
                    time: snapshot.data[i]['time'],
                    isLast: i == 0 ? true : false,
                  );
                });
          }
          return Container();
        });
  }
}
