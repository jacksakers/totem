import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';
import './addtotem.dart';
import './main.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  bool showProgress = false;
  late String email, password;
  late String userName = 'Loading...';

  @override
  Widget build(BuildContext context) {
    var currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Container(
        color: Colors.green[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Sign Up or Sign In:",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0),
            ),
            SizedBox(
              height: 20.0,
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              onChanged: (value) {
                email = "$value@gmail.com"; //get the value entered by user.
              },
              decoration: InputDecoration(
                  hintText: "Enter your UserName",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)))),
            ),
            SizedBox(
              height: 20.0,
            ),
            TextField(
              obscureText: true,
              textAlign: TextAlign.center,
              onChanged: (value) {
                password = value; //get the value entered by user.
              },
              decoration: InputDecoration(
                  hintText: "Enter your Password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)))),
            ),
            SizedBox(
              height: 20.0,
            ),
            Material(
              elevation: 5,
              color: Colors.green,
              borderRadius: BorderRadius.circular(32.0),
              child: MaterialButton(
                onPressed: () async {
                  try {
                    await _auth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    users.doc(_auth.currentUser!.uid).set({
                      'UserID': _auth.currentUser?.uid,
                      'UserName': email.split('@')[0]
                    });
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'weak-password') {
                      print('The password provided is too weak.');
                    } else if (e.code == 'email-already-in-use') {
                      try {
                        await _auth.signInWithEmailAndPassword(
                            email: email, password: password);
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          print('No user found for that email.');
                        } else if (e.code == 'wrong-password') {
                          print('Wrong password provided for that user.');
                        }
                      }
                    }
                  } catch (e) {
                    print(e);
                  }
                  setState(() {
                    showProgress = true;
                    currentUser;
                  });
                },
                minWidth: 200.0,
                height: 45.0,
                child: Text(
                  "Sign Up/In",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      users.doc(currentUser.uid).get().then((DocumentSnapshot docSnapshot) {
        Map<String, dynamic> data = docSnapshot.data()! as Map<String, dynamic>;
        setState(() {
          userName = data['UserName'];
        });
        return;
      });
      return Column(
        children: [
          Container(
            alignment: Alignment.topCenter,
            color: Colors.lightGreen,
            height: 80,
            child: Center(
              child: Text(
                userName,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          MaterialButton(
            child: Text(
              'Add Totem',
              style: TextStyle(fontSize: 20),
            ),
            color: Colors.green,
            elevation: 4,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: MyHomePage(
                    title: 'AddTotem',
                    content: AddTotem(
                        user: _auth.currentUser?.uid, username: userName),
                  ),
                ),
              );
            },
          ),
          MaterialButton(
            child: Text(
              'Sign Out',
              style: TextStyle(fontSize: 20),
            ),
            color: Colors.green,
            elevation: 4,
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              setState(() {
                currentUser;
              });
            },
          ),
        ],
      );
    }
  }
}
