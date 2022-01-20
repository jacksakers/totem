// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:totem/totempage.dart';
import './main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Totem extends StatelessWidget {
  Totem({Key? key, required this.totemName}) : super(key: key);

  final String totemName;

  String getName() {
    return totemName;
  }

  String totemImage = '';
  String owner = '';
  String monthStarted = '';
  final CollectionReference totems =
      FirebaseFirestore.instance.collection('totems');
  void getImage() {
    totems.doc(totemName).get().then((DocumentSnapshot docSnapshot) {
      Map<String, dynamic> data = docSnapshot.data()! as Map<String, dynamic>;
      totemImage = data['Image'];
      owner = data['Owner'];
      monthStarted = data['MonthStarted'].toDate().toString();
      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    getImage();

    return Container(
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: MyHomePage(
                title: 'Totem Page',
                content: TotemPage(
                  currentTotem: totemName,
                  totemImage: totemImage,
                  owner: owner,
                  month: monthStarted,
                ),
              ),
            ),
          );
        },
        child: Image.network(
          totemImage,
          width: 100,
          height: 100,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return const Center(child: Text('Loading...'));
          },
          errorBuilder: (context, error, stackTrace) =>
              const Text('Give me a sec...'),
        ),
      ),
    );
  }
}
