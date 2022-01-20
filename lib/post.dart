import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import './feed.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Post extends StatefulWidget {
  Post(
      {Key? key,
      required this.title,
      required this.content,
      required this.checks,
      required this.timePosted,
      required this.userLiked,
      required this.totem,
      required this.currentPost,
      required this.checkers,
      this.image = ''})
      : super(key: key);

  final String title;
  final String content;
  int checks;
  final String timePosted;
  bool userLiked;
  final String image;
  final String totem;
  final String currentPost;
  var checkers = [];

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  CollectionReference totems = FirebaseFirestore.instance.collection('totems');
  final _auth = FirebaseAuth.instance;

  Future<void> updateChecks(bool liked) {
    if (liked == true) {
      return totems
          .doc(widget.totem)
          .collection('totemposts')
          .doc(widget.currentPost)
          .update({
            'Checks': (widget.checks),
            'UserLiked': liked,
            'Checkers': FieldValue.arrayUnion([_auth.currentUser?.uid])
          })
          .then((value) => print("Checks Updated"))
          .catchError((error) => print("Failed to update checks: $error"));
    } else {
      return totems
          .doc(widget.totem)
          .collection('totemposts')
          .doc(widget.currentPost)
          .update({
            'Checks': (widget.checks),
            'UserLiked': liked,
            'Checkers': FieldValue.arrayRemove([_auth.currentUser?.uid])
          })
          .then((value) => print("Checks Updated"))
          .catchError((error) => print("Failed to update checks: $error"));
    }
  }

  String whichCheck = 'graphics/emptycheck.png';

  clickCheck() async {
    setState(() {
      if (whichCheck == 'graphics/emptycheck.png') {
        whichCheck = 'graphics/filledcheck.png';
        widget.checks++;
        updateChecks(true);
        widget.checkers;
        widget.userLiked = true;
        print('Add Check');
      } else {
        whichCheck = 'graphics/emptycheck.png';
        widget.checks--;
        updateChecks(false);
        widget.checkers;
        widget.userLiked = false;
        print('Remove Check');
      }
      print(whichCheck);
    });
    await totems
        .doc(widget.totem)
        .collection('totemposts')
        .doc(widget.currentPost)
        .get()
        .then((value) {
      Map<String, dynamic> data = value.data()!;
      widget.checkers = data['Checkers'];
    });
    setState(() {
      widget.checkers;
      whichCheck;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('${widget.title} has ${widget.checkers}');
    if (widget.checkers.contains(_auth.currentUser?.uid)) {
      print('${widget.title} gets here');
      whichCheck = 'graphics/filledcheck.png';
    } else {
      whichCheck = 'graphics/emptycheck.png';
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.grey[100],
      ),
      child: Column(
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 4,
              left: 4,
              right: 4,
              bottom: 3,
            ),
            child: (widget.image != '')
                ? Column(children: [
                    Image.network(
                      widget.image,
                      height: 450,
                      width: 400,
                    ),
                    Text(
                      widget.content,
                      style: TextStyle(fontSize: 15),
                    ),
                  ])
                : Text(
                    widget.content,
                    style: TextStyle(fontSize: 15),
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  widget.timePosted,
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(primary: Colors.green[900]),
                icon: Image(
                  image: AssetImage(whichCheck),
                  width: 25,
                  height: 25,
                ),
                label: Text(widget.checks.toString()),
                onPressed: clickCheck,
              ),
            ],
          )
        ],
      ),
      margin: EdgeInsets.all(10),
    );
  }
}
