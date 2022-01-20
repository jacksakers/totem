// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:totem/main.dart';
// import './post.dart';
// import './totem.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class Feed2 extends StatefulWidget {
//   Feed2({Key? key, required this.tcollection}) : super(key: key);

//   var postlist = <Post>[];
//   var tcollection = <Totem>[];

//   @override
//   State<Feed2> createState() => _Feed2State();
// }

// class _Feed2State extends State<Feed2> {
//   @override
//   Widget build(BuildContext context) {
//     FirebaseFirestore firestore = FirebaseFirestore.instance;
//     CollectionReference totems = firestore.collection('totems');
//     final _auth = FirebaseAuth.instance;
//     Stream<QuerySnapshot> postStream =
//         totems.doc('totemID').collection('totemposts').get().asStream();
//     String currentTotem = '';

//     // Stream<QuerySnapshot> getPostsFor(totemID) {

//     //   currentTotem = totemID;
//     //   return _postStream;
//     // }

//     var _postStream = firestore.collectionGroup('totemposts').get().asStream();

//     return StreamBuilder<QuerySnapshot>(
//         stream: _postStream,
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return Text('Something went wrong');
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Text("Loading");
//           }
//           return ListView(
//             children: snapshot.data!.docs.map((DocumentSnapshot document) {
//               Map<String, dynamic> data =
//                   document.data()! as Map<String, dynamic>;
//               var _timePosted = data['TimePosted'].toDate();
//               if (data['ImageUrl'] != null) {
//                 return Post(
//                   title: data['Title'],
//                   content: data['Content'],
//                   checks: data['Checks'],
//                   timePosted: _timePosted.toString(),
//                   image: data['ImageUrl'],
//                   totem: currentTotem,
//                   currentPost: document.id,
//                   userLiked: data['UserLiked'],
//                 );
//               } else {
//                 return Post(
//                   title: data['Title'],
//                   content: data['Content'],
//                   checks: data['Checks'],
//                   timePosted: _timePosted.toString(),
//                   totem: currentTotem,
//                   currentPost: document.id,
//                   userLiked: data['UserLiked'],
//                 );
//               }
//             }).toList(),
//           );
//         });
//   }
// }
