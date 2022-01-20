// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:totem/main.dart';
// import './post.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class Feed extends StatefulWidget {
//   Feed({Key? key, required this.postlist}) : super(key: key);

//   var postlist = <Post>[];

//   @override
//   _FeedState createState() => _FeedState();
// }

// class _FeedState extends State<Feed> {
//   @override
//   Widget build(BuildContext context) {
//     FirebaseFirestore firestore = FirebaseFirestore.instance;
//     CollectionReference totems = firestore.collection('totems');
//     CollectionReference posts = firestore.collection('posts');

//     Stream<QuerySnapshot> totemStream = totems.get().asStream();
//     StreamController<Post> controller = StreamController<Post>();
//     Stream<Post> postStream = controller.stream;
//     //print(totemStream.isEmpty);

//     Stream<QuerySnapshot> totemPostGetter(String totemName) {
//       var postToReturn = <Post>[];
//       //print(totemName);
//       // var totemPosts = totems
//       //     .doc(totemName)
//       //     .collection('totemposts')
//       //     .orderBy('TimePosted')
//       //     .get();
//       Stream<QuerySnapshot> toteposts = totems
//           .doc(totemName)
//           .collection('totemposts')
//           .orderBy('TimePosted')
//           .get()
//           .asStream();
//       //print('AMOUNT OF POSTS: ${toteposts.docs.length}');

//       print(toteposts.length);

//       return toteposts;
//     }

//     // if (postlist.length != 0) {
//     //   setState(() {
//     //     postlist;
//     //   });
//     // }

//     return StreamBuilder<QuerySnapshot>(
//       stream: totemStream,
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         print("!!!!!!!!!!!!!!!!!!!!!!");
//         print(snapshot);
//         if (snapshot.hasError) {
//           return Text('Something went wrong');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return CircularProgressIndicator();
//         }

//         if (snapshot.connectionState == ConnectionState.done) {
//           print('CONNECTION DONE');
//         }
//         var listofPosts = [
//           Post(
//             title: 'Place',
//             content: 'holder',
//             checks: 2,
//             timePosted: '5 oclock',
//           )
//         ];
//         print(snapshot.data!.docs.length);
//         for (int i = 0; i < snapshot.data!.docs.length; i++) {
//           print("THE STREAM IS ON");
//           StreamBuilder<QuerySnapshot>(
//             stream: totemPostGetter(snapshot.data!.docs[i].id),
//             builder:
//                 (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//               if (snapshot.hasError) {
//                 return Text('Something went wrong');
//               }

//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Text("Loading");
//               }
//               return ListView(
//                 children: snapshot.data!.docs.map((DocumentSnapshot document) {
//                   Map<String, dynamic> data =
//                       document.data()! as Map<String, dynamic>;
//                   var _timePosted = data['TimePosted'].toDate();
//                   print(_timePosted);
//                   return Post(
//                     title: data['Title'],
//                     content: data['Content'],
//                     checks: data['Checks'],
//                     timePosted: _timePosted.toString(),
//                   );
//                 }).toList(),
//               );
//             },
//           );
//         }
//         return ListView(
//           children: postlist,
//         );
//       },
//     );

//     // return FutureBuilder<DocumentSnapshot>(
//     //     future: totems
//     //         .doc('BlueGuy01')
//     //         .collection('totemposts')
//     //         .doc('2PMS81Od5cvR9Pa73QXA')
//     //         .get(),
//     //     builder:
//     //         (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//     //       if (snapshot.hasError) {
//     //         return Text("problem with database connection");
//     //       }

//     //       if (snapshot.connectionState == ConnectionState.done) {
//     //         PopulatePostlist();
//     //         print("THIS HAPPENS");
//     //         Map<String, dynamic> post_data =
//     //             snapshot.data!.data() as Map<String, dynamic>;
//     //         if (post_data != null) {
//     //           var timePosted = post_data['TimePosted'].toDate();
//     //           return Text(
//     //               "Title: ${post_data['Title']} ${post_data['Content']} Checks:${post_data['Checks']} ${timePosted.toString()}");
//     //         }
//     //       }

//     //       return Text("Loading...");
//     //     });
//     //while (widget.postlist.length == 0) {
//     //PopulatePostlist();
//     print(widget.postlist);
//     return ListView(
//       padding: EdgeInsets.all(4),
//       children: widget.postlist,
//     );
//   }
// }
