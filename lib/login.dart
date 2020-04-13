import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences preferences;
  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: RaisedButton(
        child: Text("Sign in With Gmail"),
        onPressed: handleSignIn,
      ),
    );
  }

  void initState() {
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
    });

    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn) {
      preferences = await SharedPreferences.getInstance();
    }
    this.setState(() {
      isLoading = false;
    });
  }

  Future<Null> handleSignIn() async {
    GoogleSignInAccount gUser = await googleSignIn.signIn();
    GoogleSignInAuthentication gAuth = await gUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: gAuth.idToken, accessToken: gAuth.accessToken);
    FirebaseUser firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'nickname': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'id': firebaseUser.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null,
        });
        currentUser = firebaseUser;
        preferences = await SharedPreferences.getInstance();
        await preferences.setString('id', currentUser.uid);
        await preferences.setString('nickname', currentUser.displayName);
        await preferences.setString('photoUrl', currentUser.photoUrl);
      } else {
        // Write data to local
        preferences = await SharedPreferences.getInstance();
        await preferences.setString('id', documents[0]['id']);
        await preferences.setString('nickname', documents[0]['nickname']);
        await preferences.setString('photoUrl', documents[0]['photoUrl']);
        await preferences.setString('aboutMe', documents[0]['aboutMe']);
      }
      Fluttertoast.showToast(msg: "Signed in Successfully");
      this.setState(() {
        isLoading = false;
      });
    } else {
      Fluttertoast.showToast(msg: "Failure");
      this.setState(() {
        isLoading = false;
      });
    }
  }
}
