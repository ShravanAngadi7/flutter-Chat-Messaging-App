import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:wechatapp/models/chatuser.dart';
import 'package:wechatapp/models/messageuser.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accesing cloud-- firestore databse

  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  //for accesing cloud-- firestore databse

  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;
  // for storing info--
  static late ChatUser me;

  //for checking if user exisst or not---
  static Future<bool> userExists() async {
    return (await firestore.collection('userss').doc(user.uid).get()).exists;
  }

  //for checking if user exisst or not---
  static Future<void> Getselfinfo() async {
    await firestore.collection('userss').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => Getselfinfo());
      }
    });
  }

  //for creating new user----
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey i am using your Chat app",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');

    return await firestore
        .collection('userss')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  ///for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    return APIs.firestore
        .collection('userss')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //for updating from profile info------
  static Future<void> updateUserInfo() async {
    await firestore.collection('userss').doc(user.uid).update({
      "name": me.name,
      "about": me.about,
    });
  }
  // update profiele pic of user

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    log('Extension: $ext');
    final ref = storage.ref().child('profile/pictures/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      // log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    me.image = await ref.getDownloadURL();
    await firestore.collection('userss').doc(user.uid).update({
      "image": me.image,
    });
  }

  //////*********************CHAT SCREEN RELATED APIS******************//////////
  ///
  //useful for getting converstion id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        //.orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: Type.text,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get pn;u last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }
}
