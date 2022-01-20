import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:totem/camera_widget.dart';
import './main.dart';
import 'dart:io';
import 'package:page_transition/page_transition.dart';
import './feed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import './totem.dart';
import './collection.dart';
import './addtotem.dart';
import 'package:nfc_manager/nfc_manager.dart';

class AddPost extends StatefulWidget {
  AddPost(
      {Key? key,
      this.currentPhoto,
      this.currentTitle,
      this.currentContent,
      this.currentCollection})
      : super(key: key);

  File? currentPhoto;
  String? currentTitle;
  String? currentContent;
  List<Totem>? currentCollection;

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  String? newTotem;
  ValueNotifier<dynamic> result = ValueNotifier(null);

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    (widget.currentTitle != null)
        ? titleController.text = widget.currentTitle!
        : null;
    (widget.currentContent != null)
        ? contentController.text = widget.currentContent!
        : null;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference totems = firestore.collection('totems');

    String imageUrl;

    Future<String> uploadFile(File file) async {
      var now = Timestamp.now().seconds;
      String fileName = 'Uploaded Image$now';
      FirebaseStorage firebaseStorageRef = FirebaseStorage.instance;
      TaskSnapshot taskSnapshot =
          await firebaseStorageRef.ref(fileName).putFile(file);
      imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    }

    void postPost(String totemName) async {
      var currentTotemPosts = totems.doc(totemName).collection('totemposts');

      if (titleController.text.isNotEmpty &&
          contentController.text.isNotEmpty &&
          newTotem != null) {
        Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.topToBottom,
            child: MyHomePage(
              title: 'Collection',
              content: Collection(
                totemcollection: widget.currentCollection!,
              ),
            ),
          ),
        );
        if (widget.currentPhoto != null) {
          var Cururl = await uploadFile(widget.currentPhoto!);
          currentTotemPosts.add({
            'Title': titleController.text,
            'Content': contentController.text,
            'Checks': 0,
            'TimePosted': Timestamp.now(),
            'ImageUrl': Cururl,
            'UserLiked': false,
            'Totem': newTotem,
            'Checkers': [],
          });
        } else {
          currentTotemPosts.add({
            'Title': titleController.text,
            'Content': contentController.text,
            'Checks': 0,
            'TimePosted': Timestamp.now(),
            'UserLiked': false,
            'Totem': newTotem,
            'Checkers': [],
          });
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.brown[400],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Totem:',
                      style: TextStyle(
                        fontSize: 60,
                        fontFamily: 'Lora',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[200],
                      ),
                    ),
                    (newTotem != null)
                        ? Container(
                            color: Colors.grey,
                            child: Center(
                                child: Text(
                              newTotem!,
                            )),
                          )
                        : TextButton(
                            onPressed: _tagRead,
                            child: Container(
                              height: 70,
                              width: 70,
                              color: Colors.grey,
                              child: const Center(
                                  child: Text(
                                "Press to Scan",
                              )),
                            ),
                          ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                        bottom: 25,
                        left: 8,
                        right: 5,
                      ),
                      child: Text(
                        'Photo:',
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[200],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        (widget.currentPhoto != null)
                            ? Container(
                                height: 70,
                                width: 70,
                                child: Image(
                                    image: FileImage(widget.currentPhoto!)),
                              )
                            : Container(
                                height: 70,
                                width: 70,
                                color: Colors.grey,
                                child: Center(child: Text("Add Photo")),
                              ),
                        ElevatedButton(
                          onPressed: () {
                            widget.currentTitle = titleController.text;
                            widget.currentContent = contentController.text;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyHomePage(
                                  title: 'Feed',
                                  content: CameraWidget(
                                    content: widget.currentContent,
                                    title: widget.currentTitle,
                                    collection: widget.currentCollection,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Text("Add Photo"),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green[900]),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                        bottom: 25,
                        left: 8,
                        right: 5,
                      ),
                      child: Text(
                        'Title:',
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[200],
                        ),
                      ),
                    ),
                    Flexible(
                      child: TextField(
                        controller: titleController,
                        maxLength: 30,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                          hintText: 'Enter a title',
                          hintStyle: TextStyle(color: Colors.grey[200]),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                        bottom: 25,
                        left: 8,
                        right: 5,
                      ),
                      child: Text(
                        'Content:',
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'Lora',
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[200],
                        ),
                      ),
                    ),
                    TextField(
                      controller: contentController,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      maxLength: 500,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      decoration: InputDecoration(
                        hintMaxLines: 4,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        hintText: 'Enter some text',
                        hintStyle: TextStyle(color: Colors.grey[200]),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    postPost(newTotem!);
                  },
                  child: Text(
                    "Post",
                    style: TextStyle(fontSize: 30),
                  ),
                  style: ElevatedButton.styleFrom(primary: Colors.green[900]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _tagRead() {
    widget.currentTitle = titleController.text;
    widget.currentContent = contentController.text;
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
    });

    return decodedPayload;
  }
}
