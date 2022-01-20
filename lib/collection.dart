import 'package:flutter/material.dart';
import 'package:totem/totem.dart';
import './main.dart';

class Collection extends StatefulWidget {
  Collection({Key? key, required this.totemcollection}) : super(key: key);

  List<Totem> totemcollection = <Totem>[];

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.count(
        crossAxisCount: 4,
        children: widget.totemcollection,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.brown[900],
      ),
    );
  }
}
