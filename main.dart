// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:totem/feed2.dart';
import 'package:totem/post.dart';
import 'package:totem/signin.dart';
import './collection.dart';
import './feed.dart';
import './totem.dart';
import './addpost.dart';
import 'package:firebase_core/firebase_core.dart';
import './feed2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

var _totemCollection = <Totem>[];
var postlist = <Post>[];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Totem',
      home: MyHomePage(
        title: 'Profile',
        content: SignIn(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.content})
      : super(key: key);

  final String title;
  Widget content;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final _auth = FirebaseAuth.instance;

  void setScreen(currentScreen) {
    setState(() {});
  }

  String getScreen() {
    return widget.title;
  }

  var collectionLength = 0;
  void getCollection() async {
    if (_totemCollection.length < 1) {
      await users
          .doc(_auth.currentUser?.uid)
          .get()
          .then((DocumentSnapshot docSnapshot) {
        Map<String, dynamic> data = docSnapshot.data()! as Map<String, dynamic>;
        collectionLength = data['Collection'].length;
        for (var i = 0; i < data['Collection'].length; i++) {
          if (_totemCollection.length < collectionLength) {
            _totemCollection.add(Totem(
              totemName: data['Collection'][i],
            ));
          }
        }
        setState(() {
          _totemCollection;
        });
      });
      print('COllection Updating..');
      return;
    }
  }

  void updateCollection() async {
    await users
        .doc(_auth.currentUser?.uid)
        .get()
        .then((DocumentSnapshot docSnapshot) {
      Map<String, dynamic> data = docSnapshot.data()! as Map<String, dynamic>;
      for (var i = _totemCollection.length;
          i < data['Collection'].length;
          i++) {
        print('collection length: ${i}');
        print('data length: ${data['Collection'].length}');
        if (_totemCollection.length < data['Collection'].length) {
          print("got here");
          _totemCollection.add(Totem(
            totemName: data['Collection'][i],
          ));
        }
      }
      setState(() {
        _totemCollection;
      });
    });
    print('COllection Updating.....');
    return;
  }

  @override
  Widget build(BuildContext context) {
    getCollection();
    return Scaffold(
      backgroundColor: Colors.brown[700],
      appBar: AppBar(
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: () {
                if (getScreen() != 'Profile') {
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: MyHomePage(
                        title: 'Profile',
                        content: SignIn(),
                      ),
                    ),
                  );
                }
              },
              child: Image(
                image: AssetImage('graphics/profile icon.png'),
              ))
        ],
        backgroundColor: Colors.green[900],
        title: Image(
          image: ResizeImage(
            AssetImage('graphics/Totem Logo.png'),
            width: 150,
            height: 50,
          ),
        ),
      ),
      body: widget.content,
      bottomNavigationBar: BottomAppBar(
        color: Colors.green[900],
        child: Row(
          children: <Widget>[
            TextButton(
              child: Row(
                children: [
                  Image(
                    image: AssetImage('graphics/Collection Icon.png'),
                    width: 40,
                    height: 40,
                  ),
                ],
              ),
              onPressed: () {
                if (getScreen() != 'Collection' &&
                    (_auth.currentUser != null)) {
                  updateCollection();
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType.leftToRight,
                      child: MyHomePage(
                        title: 'Collection',
                        content: Collection(
                          totemcollection: _totemCollection,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            TextButton(
              child: Row(
                children: [
                  Image(
                    image: AssetImage('graphics/Add Icon.png'),
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
              onPressed: () {
                if (getScreen() != 'Add' && (_auth.currentUser != null)) {
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType.bottomToTop,
                      child: MyHomePage(
                        title: 'Add',
                        content: AddPost(
                          currentCollection: _totemCollection,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            TextButton(
              child: Row(
                children: [
                  Image(
                    image: AssetImage('graphics/Feed Icon.png'),
                    width: 35,
                    height: 35,
                  ),
                ],
              ),
              onPressed: () {
                if (getScreen() != 'Feed' && (_auth.currentUser != null)) {
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: MyHomePage(
                        title: 'Feed',
                        content: Feed(
                          tcollection: _totemCollection,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
      ),
    );
  }
}
