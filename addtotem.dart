import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './main.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class AddTotem extends StatefulWidget {
  const AddTotem({Key? key, required this.user, required this.username})
      : super(key: key);

  final String? user;
  final String? username;

  @override
  _AddTotemState createState() => _AddTotemState();
}

class _AddTotemState extends State<AddTotem> {
  ValueNotifier<dynamic> result = ValueNotifier(null);
  String? newTotem;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference totems = FirebaseFirestore.instance.collection('totems');
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<bool>(
        future: NfcManager.instance.isAvailable(),
        builder: (context, ss) => ss.data != true
            ? Center(child: Text('NfcManager.isAvailable(): ${ss.data}'))
            : Flex(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                direction: Axis.vertical,
                children: [
                  Flexible(
                    flex: 2,
                    child: Container(
                      height: 400,
                      width: double.infinity,
                      color: Colors.grey,
                      child: (newTotem != null)
                          ? Container(
                              color: Colors.grey,
                              height: 300,
                              width: double.infinity,
                              child: Center(
                                  child: Text(
                                "${newTotem!} added to collection!",
                                style: TextStyle(fontSize: 30),
                                textAlign: TextAlign.center,
                              )),
                            )
                          : Container(
                              color: Colors.grey,
                              height: 300,
                              width: double.infinity,
                              child: const Center(
                                  child: Text(
                                "No Totem Found",
                                style: TextStyle(fontSize: 30),
                              )),
                            ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: ElevatedButton(
                      child: Text(
                        'Press Here to Scan New Totem',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _tagRead,
                      style:
                          ElevatedButton.styleFrom(primary: Colors.green[700]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _tagRead() {
    String decodedPayload = '';
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      var record = ndef?.cachedMessage?.records.first;
      var encodedPayload = record?.payload;
      for (int i = 3; i < encodedPayload!.length; i++) {
        decodedPayload += String.fromCharCode(encodedPayload[i]);
      }
      print('Tag Discovered ${decodedPayload}');
      setState(() {
        newTotem = decodedPayload;
      });
      result.value = tag.data;
      NfcManager.instance.stopSession();
      users.doc(widget.user).update({
        'Collection': FieldValue.arrayUnion([decodedPayload])
      });
      totems.doc(decodedPayload).update({
        'Owner': widget.username,
        'Subscribers': FieldValue.arrayUnion([_auth.currentUser?.uid]),
      });
    });

    return decodedPayload;
  }
}
