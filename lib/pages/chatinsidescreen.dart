import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wechatapp/models/chatuser.dart';
import 'package:wechatapp/models/messageuser.dart';
import 'package:wechatapp/widgets/messageCard.dart';

import '../api/apis.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // for storing all message
  List<Message> _list = [];
  //for handling messg text change
  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 158, 198, 231),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    switch (snapshot.connectionState) {
                      //if data is loading-----------
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();

                      //if some or all data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;

                        _list = data
                                ?.map((e) => Message.fromJson(
                                    e.data() as Map<String, dynamic>))
                                .toList() ??
                            [];
                        //   for (var i in data!) {
                        //     print('Data:${jsonEncode(i.data())}');
                        //     //log(${i.data()}.toString());
                        //     list.add(i.data()['name']);
                        // }

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                              // reverse: true,
                              itemCount: _list.length,
                              padding: const EdgeInsets.only(top: 5),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(message: _list[index]);
                              });
                        } else {
                          return const Center(
                            child: Text(
                              'Say Hi! 👋',
                              style: TextStyle(fontSize: 20),
                            ),
                          );
                        }
                    }
                  },
                ),
              ),
              _chatInput(),
            ],
          ),
        ),
      ),
    );
  }

  // appbar widget----
  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          // back button
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back, color: Colors.black54)),
          // user profile picture----------------------
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              imageUrl: widget.user.image,
              //placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => const CircleAvatar(
                child: Icon(CupertinoIcons.person, color: Colors.black),
              ),
            ),
          ),
          // for adding some space------------
          const SizedBox(width: 10),
          // user name and last seen time-----------
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.user.name.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: 1),
              // const Text('last Seen not available!',
              //     style: const TextStyle(
              //       fontSize: 13,
              //       color: Colors.black54,
              //     )),
            ],
          ),
        ],
      ),
    );
  }
  // bottom chat input field-----------

  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      child: Row(
        children: [
          // input field and button---------
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  // emoji button
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                        size: 25,
                      )),
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Type something....',
                      hintStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                    ),
                  )),
                  // pick image from gallery------------

                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                        size: 22,
                      )),
                  // take image from camera button=------
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blueAccent,
                        size: 22,
                      )),
                  // adding some space
                  SizedBox(width: 0.1),
                ],
              ),
            ),
          ),
          //send msg button------------
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text.trim());
                _textController.text = '';
              }
            },
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: CircleBorder(),
            minWidth: 20,
            color: Colors.green,
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
