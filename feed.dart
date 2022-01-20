import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:totem/main.dart';
import './post.dart';
import './totem.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class Feed extends StatefulWidget {
  Feed({Key? key, required this.tcollection}) : super(key: key);

  var postlist = <Post>[];
  var tcollection = <Totem>[];

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference totems = firestore.collection('totems');
    final _auth = FirebaseAuth.instance;
    var totemStream = totems
        .where('Subscribers', arrayContains: _auth.currentUser?.uid)
        .get()
        .asStream();
    Stream<QuerySnapshot> postStream =
        totems.doc('totemID').collection('totemposts').get().asStream();
    Stream<QuerySnapshot> newpostStream = firestore
        .collectionGroup('totemposts')
        .orderBy('TimePosted', descending: true)
        .get()
        .asStream();
    String currentTotem = '';

    Stream<QuerySnapshot> getPostsFor(totemID) {
      postStream = totems
          .doc(totemID)
          .collection('totemposts')
          .orderBy('TimePosted', descending: true)
          .get()
          .asStream();
      currentTotem = totemID;
      return postStream;
    }

    var tNameCollection = <String>[];
    for (int i = 0; i < widget.tcollection.length; i++) {
      tNameCollection.add(widget.tcollection[i].getName());
    }

    return StreamBuilder<QuerySnapshot>(
      stream: totemStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // for (int i = 0; i < snapshot.data!.docs.length - 1; i++) {
        //   getPostsFor(snapshot.data!.docs[i].id);
        // }

        // getPostsFor(widget.tcollection[0].getName());
        // print('TOTEM NAME: ${widget.tcollection[0].getName()}');
        if (snapshot.hasData) {
          return StreamBuilder<QuerySnapshot>(
              stream: newpostStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }
                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    var _timePosted = data['TimePosted'].toDate();

                    if (tNameCollection.contains(data['Totem'])) {
                      if (data['ImageUrl'] != null) {
                        return Post(
                          title: data['Title'],
                          content: data['Content'],
                          checks: data['Checkers'].length,
                          timePosted: _timePosted.toString(),
                          image: data['ImageUrl'],
                          totem: data['Totem'],
                          currentPost: document.id,
                          userLiked: data['UserLiked'],
                          checkers: data['Checkers'],
                        );
                      } else {
                        return Post(
                          title: data['Title'],
                          content: data['Content'],
                          checks: data['Checkers'].length,
                          timePosted: _timePosted.toString(),
                          totem: data['Totem'],
                          currentPost: document.id,
                          userLiked: data['UserLiked'],
                          checkers: data['Checkers'],
                        );
                      }
                    } else {
                      return Container();
                    }
                  }).toList(),
                );
              });
        } else if (snapshot.hasError) {
          return Text("There was an error");
        } else {
          return CircularProgressIndicator();
        }
      },
    );
    return ListView(
      children: widget.postlist,
    );
  }
}
