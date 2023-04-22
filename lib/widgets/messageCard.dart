import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wechatapp/api/apis.dart';
import 'package:wechatapp/models/messageuser.dart';

import '../auth/my dateutil.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId
        ? _greenMessage()
        : _blueMessage();
  }

// sender or another message-----
  Widget _blueMessage() {
    //update last read message if sender and revicer are diffrnt
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(13),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 199, 227, 249),
              border: Border.all(color: Colors.lightBlue),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            MyDateutil.getFormattedTimme(
                context: context, time: widget.message.sent),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(221, 33, 33, 33),
              letterSpacing: 0.1,
            ),
          ),
        ),
        //SizedBox(width: 1),
      ],
    );
  }

// my msg or user or ypur message or our ------
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            //for adding some space
            const SizedBox(width: 10),
            //double tick blueicon for message read
            if (widget.message.read.isEmpty)
              const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),
            // for adding some space--
            const SizedBox(width: 5),
            //read time
            Text(
              MyDateutil.getFormattedTimme(
                  context: context, time: widget.message.sent),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(221, 33, 33, 33),
              ),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(13),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 174, 255, 198),
              border: Border.all(color: Colors.lightGreen),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
        //SizedBox(width: 1),
      ],
    );
  }
}
