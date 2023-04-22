// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechatapp/api/apis.dart';
import 'package:wechatapp/Login_page.dart';
import 'package:wechatapp/pages/chatScreen.dart';
import 'package:wechatapp/pages/registerpage.dart';

import '../models/chatuser.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        //-----------------------appbar
        appBar: AppBar(
          backgroundColor: Colors.purple,
          centerTitle: true,
          title: const Text(
            'Profile edit',
            style: TextStyle(
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        //----------------------- floatingActionButton
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.black87,
            icon: const Icon(Icons.logout_outlined, size: 16),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) =>
                    Center(child: CircularProgressIndicator()),
              );
              Navigator.of(context).pop();
              // Navigator.of(context).pushReplacement(
              //     MaterialPageRoute(builder: (_) => ChatScreen()));
              //Navigator.of(context).pop();
              await FirebaseAuth.instance.signOut().then((value) {
                Navigator.of(context).pop();
              });
            },
            label: const Text(
              'SignOut',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),

        body: Form(
          key: _formkey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.file(
                                File(_image!),
                                fit: BoxFit.cover,
                                width: 170,
                                height: 170,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                width: 170,
                                height: 170,
                                imageUrl: widget.user.image,
                                //placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                  child: Icon(CupertinoIcons.person,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            _showBottomSheet();
                          },
                          color: Colors.white,
                          shape: CircleBorder(),
                          child: Icon(
                            Icons.edit_outlined,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SingleChildScrollView(
                    child: TextFormField(
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      initialValue: widget.user.name,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'eg: elon musk',
                          label: const Text('Name')),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'eg: Feeling Good!',
                        label: const Text('About')),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        minimumSize: const Size(40, 55),
                      ),
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          _formkey.currentState!.save();
                          APIs.updateUserInfo().then((value) =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Profile updated Succesfully!'))));
                        }
                      },
                      icon: const Icon(
                        Icons.edit,
                        size: 25,
                      ),
                      label: const Text(
                        'Update And Save',
                        style: TextStyle(fontSize: 15),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        )),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 30, bottom: 40),
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  )),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black45,
                          shape: const CircleBorder(),
                          fixedSize: Size(75, 75)),
                      onPressed: () async {
                        //pick an image---

                        final ImagePicker picker = ImagePicker();
                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          // log('Image Path: ${image.path} --MimeType: ${image.mimeType}');
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                          Navigator.of(context).pop();
                        }
                      },
                      child: Icon(Icons.add_photo_alternate_outlined)
                      //Image.asset('lib/assests/image.png'),
                      ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black45,
                          shape: const CircleBorder(),
                          fixedSize: Size(75, 75)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          //log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));
                          Navigator.of(context).pop();
                        }
                      },
                      child: Icon(Icons.photo_camera_outlined)
                      //Image.asset('lib/assests/image.png'),
                      ),
                ],
              )
            ],
          );
        });
  }
}
