import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  SharedPreferences sharedPreferences;
  void initState() {
    super.initState();
    readFromStorage();
  }

  void readFromStorage() async {
    sharedPreferences = await SharedPreferences.getInstance();
    isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn) {
      Future.delayed(const Duration(milliseconds: 3000), () {
        setState(() {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/chats', (Route<dynamic> route) => false);
        });
      });
    } else {
      Future.delayed(const Duration(milliseconds: 3000), () {
        setState(() {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/login', (Route<dynamic> route) => false);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlutterLogo(
            size: 100.0,
          ),
        ],
      )),
    );
  }
}
