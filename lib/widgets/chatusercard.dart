import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:wechatapp/api/apis.dart';
import 'package:wechatapp/auth/my%20dateutil.dart';
import 'package:wechatapp/main.dart';
import 'package:wechatapp/models/chatuser.dart';
import 'package:wechatapp/models/messageuser.dart';

import '../pages/chatinsidescreen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChatScreen(
                      user: widget.user,
                    )));
          },
          child: StreamBuilder(
            stream: APIs.getAllMessages(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list = data
                      ?.map((e) =>
                          Message.fromJson(e.data() as Map<String, dynamic>))
                      .toList() ??
                  [];
              if (list.isNotEmpty) {
                _message = list[0];
              }

              // if (data != null && data.first.exists) {
              //   _message = Message.fromJson(data.first.data());
              // }

              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                tileColor: Colors.blue.shade100,
                // leading: const CircleAvatar(
                //   child: Icon(CupertinoIcons.person),
                // ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: 55,
                    height: 55,
                    imageUrl: widget.user.image,
                    //placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => CircleAvatar(
                      child: Icon(CupertinoIcons.person, color: Colors.black),
                    ),
                  ),
                ),
                title: Text(widget.user.name),
                subtitle: Text(
                    _message != null ? _message!.msg : widget.user.about,
                    maxLines: 1),

                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty &&
                            _message!.fromId != APIs.user.uid
                        ? Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                color: Colors.greenAccent.shade400,
                                borderRadius: BorderRadius.circular(10)),
                          )
                        : Text(
                            MyDateutil.getLastMessageTime(
                                context: context, time: _message!.sent),
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
              );
            },
          )),
    );
  }
}
