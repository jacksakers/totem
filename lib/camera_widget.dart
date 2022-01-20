import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:totem/addpost.dart';
import 'package:totem/main.dart';
import 'package:totem/totem.dart';

class CameraWidget extends StatefulWidget {
  CameraWidget({Key? key, this.content, this.title, this.collection})
      : super(key: key);

  String? content;
  String? title;
  List<Totem>? collection;

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          (imageFile != null)
              ? Image(
                  image: FileImage(imageFile!),
                  height: 300,
                  width: 700,
                )
              : Container(
                  color: Colors.grey,
                  height: 300,
                  width: double.infinity,
                  child: const Center(
                      child: Text(
                    "Add a Photo",
                    style: TextStyle(fontSize: 30),
                  )),
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => getImage(source: ImageSource.gallery),
                child: Text("Choose from Gallery"),
              ),
              ElevatedButton(
                onPressed: () => getImage(source: ImageSource.camera),
                child: Text("Choose from Camera"),
              ),
            ],
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(
                        title: 'Add',
                        content: AddPost(
                          currentPhoto: imageFile,
                          currentContent: widget.content,
                          currentTitle: widget.title,
                          currentCollection: widget.collection,
                        )),
                  ),
                );
              },
              child: Text("Submit Image"))
        ],
      ),
    );
  }

  void getImage({required ImageSource source}) async {
    final file = await ImagePicker().pickImage(source: source);

    if (file?.path != null) {
      setState(() {
        imageFile = File(file!.path);
      });
    }
  }
}
