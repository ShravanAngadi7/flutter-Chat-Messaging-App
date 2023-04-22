import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:wechatapp/pages/profilescreeen.dart';

import '../models/chatuser.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wechatapp/api/apis.dart';

import '../widgets/chatusercard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.Getselfinfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Focus.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          //-----------------------appbar
          appBar: AppBar(
              backgroundColor: Colors.blue.shade800,
              centerTitle: true,
              title: _isSearching
                  ? TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Name Or Email....'),
                      autofocus: true,
                      style: const TextStyle(fontSize: 16, letterSpacing: 0.5),
                      onChanged: (value) {
                        _searchList.clear();
                        for (var i in _list) {
                          if (i.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(value.toLowerCase())) {
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      },
                    )
                  : const Text(
                      'Chats',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(_isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search)),
                // GestureDetector(
                //   onTap: () {
                //     FirebaseAuth.instance.signOut();
                //   },
                //   child: const Icon(
                //     Icons.logout_outlined,
                //     semanticLabel: 'signout',
                //     color: Colors.black,
                //   ),
                // ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ProfileScreen(user: APIs.me)));
                    },
                    icon: const Icon(Icons.more_vert_outlined,
                        color: Colors.black)),
              ]),
          //----------------------- floatingActionButton
          floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.chat),
              onPressed: () {
                // FirebaseAuth.instance.signOut();
              }),
          body: StreamBuilder(
            stream: APIs.getAllUser(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              switch (snapshot.connectionState) {
                //if data is loading-----------
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  _list = data
                          ?.map((e) => ChatUser.fromJson(
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
                      itemCount:
                          _isSearching ? _searchList.length : _list.length,
                      padding: const EdgeInsets.only(top: 5),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ChatUserCard(
                          user:
                              _isSearching ? _searchList[index] : _list[index],
                        );
                        // return Text('Name: ${list[index]}');
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'No connections Found!',
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }
                // return ListView.builder(
                //   itemCount: list.length,
                //   padding: EdgeInsets.only(top: 5),
                //   physics: BouncingScrollPhysics(),
                //   itemBuilder: (context, index) {
                //     return ChatUserCard(
                //       user: list[index],
                //     );
                //     // return Text('Name: ${list[index]}');
                //   },
                // );
              }
            },
          ),
        ),
      ),
    );
  }
}
