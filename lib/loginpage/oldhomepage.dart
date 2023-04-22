import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wechatapp/read%20data/getuserdata.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  // document ids-------
  List<String> docIDs = [];
  // get docs ids-------
  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection('users')
        .orderBy('username', descending: false)
        .get()
        .then(
          (snapshot) => snapshot.docs.forEach(
            (document) {
              print(document.reference);
              docIDs.add(document.reference.id);
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          user.email!.toUpperCase(),
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              // FirebaseAuth.instance.signOut();
            },
            child: Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Text('Signed In as - ' + user.email!),
          //SizedBox(height: 10),
          // MaterialButton(
          //   child: Text('Sign out'),
          //   onPressed: () {
          //     FirebaseAuth.instance.signOut();
          //   },
          //   color: Colors.deepPurple[200],
          // ),
          Expanded(
            child: FutureBuilder(
                future: getDocId(),
                builder: (context, snapshot) {
                  return ListView.builder(
                    itemCount: docIDs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        tileColor: Colors.grey[200],
                        title: GetuserName(documentId: docIDs[index]),
                      );
                    },
                  );
                }),
          ),
        ],
      )),
    );
  }
}
