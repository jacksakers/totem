import 'package:flutter/material.dart';
import 'package:totem/totem.dart';
// import 'package:flutter/rendering.dart';
import 'feed.dart';
import './post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TotemPage extends StatefulWidget {
  const TotemPage(
      {Key? key,
      required this.currentTotem,
      required this.totemImage,
      required this.owner,
      required this.month})
      : super(key: key);

  final String currentTotem;
  final String totemImage;
  final String owner;
  final String month;

  @override
  State<TotemPage> createState() => _TotemPageState();
}

class _TotemPageState extends State<TotemPage> {
  CollectionReference totems = FirebaseFirestore.instance.collection('totems');
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');

  var collection = ['BlueGuy01'];

  // setTotem(started, owner) {
  //   setState(() {
  //     monthStarted = started;
  //     owner = owner;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> postStream = totems
        .doc(widget.currentTotem)
        .collection('totemposts')
        .orderBy('TimePosted', descending: true)
        .get()
        .asStream();
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.topCenter,
          color: Colors.lightGreen,
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: Text(
                  'Started:\n${widget.month.split(' ')[0]}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Lora',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Image.network(
                  widget.totemImage,
                  width: 100,
                  height: 100,
                ),
              ),
              Flexible(
                  child: Text(
                'Current Owner:\n${widget.owner}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Lora',
                  fontWeight: FontWeight.bold,
                ),
              )),
            ],
          ),
        ),
        Expanded(
          child: Feed(tcollection: [Totem(totemName: widget.currentTotem)]),
        )
      ],
    );
  }
}
