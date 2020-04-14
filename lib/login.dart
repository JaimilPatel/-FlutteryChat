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
          centerTitle: true,
          title: Text("Fluttery Chat"),
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: RaisedButton(
                  onPressed: handleSignIn,
                  child: Text(
                    'SIGN IN WITH GOOGLE',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: Color(0xffdd4b39),
                  highlightColor: Color(0xffff7f7f),
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
            ),

            // Loading
            Positioned(
              child: isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                  : Container(),
            ),
          ],
        ));
  }

  void initState() {
    super.initState();
  }

  Future<Null> handleSignIn() async {
//    this.setState(() {
//      isLoading = true;
//    });
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
          'name': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'id': firebaseUser.uid,
          'email': firebaseUser.email,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        });
        currentUser = firebaseUser;
        preferences = await SharedPreferences.getInstance();
        await preferences.setString('id', currentUser.uid);
        await preferences.setString('name', currentUser.displayName);
        await preferences.setString('photoUrl', currentUser.photoUrl);
        await preferences.setString('email', currentUser.email);
      } else {
        // Write data to local
        preferences = await SharedPreferences.getInstance();
        await preferences.setString('id', documents[0]['id']);
        await preferences.setString('name', documents[0]['name']);
        await preferences.setString('photoUrl', documents[0]['photoUrl']);
        await preferences.setString('email', documents[0]['email']);
      }
      Fluttertoast.showToast(msg: "Signed in Successfully");

      Navigator.of(context)
          .pushNamedAndRemoveUntil('/chats', (Route<dynamic> route) => false);
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
