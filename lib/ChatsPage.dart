import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/ChatScreen.dart';
import 'package:flutter_chat_app/Choice.dart';
import 'package:flutter_chat_app/login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatsPage extends StatefulWidget {
  final String currentUserId;
  ChatsPage({Key key, @required this.currentUserId}) : super(key: key);
  @override
  _ChatsPageState createState() =>
      _ChatsPageState(currentUserId: currentUserId);
}

class _ChatsPageState extends State<ChatsPage> {
  final String currentUserId;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin firebaseLocalNotificationPlugin =
      FlutterLocalNotificationsPlugin();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool isLoading = false;
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];
  _ChatsPageState({Key key, @required this.currentUserId});

  @override
  void initState() {
    super.initState();
  }

  void onItemMenuPress(Choice choice) {
    if (choice.title == 'Log out') {
      handleLogOut();
    } else {
      return null;
    }
  }

  void registerNotification() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MAIN',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                          color: Colors.black,
                        ),
                        Container(
                          width: 10.0,
                        ),
                        Text(
                          choice.title,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ));
              }).toList();
            },
          ),
        ],
      ),
      body: WillPopScope(
          child: StreamBuilder(
            stream: Firestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                );
              } else {
                return ListView.builder(
                  itemBuilder: (context, index) =>
                      buildItem(context, snapshot.data.documents[index]),
                  itemCount: snapshot.data.documents.length,
                );
              }
            },
          ),
          onWillPop: null),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == currentUserId) {
      return Container();
    } else {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: document['photoUrl'] != null
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                            width: 50.0,
                            height: 50.0),
                        imageUrl: document['photoUrl'],
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: Colors.grey,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Nickname: ${document['nickname']}',
                          style: TextStyle(color: Colors.blue),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: Text(
                          'About me: ${document['aboutMe'] ?? 'Not available'}',
                          style: TextStyle(color: Colors.blue),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(
                          peerId: document.documentID,
                          peerAvatar: document['photoUrl'],
                        )));
          },
          color: Colors.blueGrey,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }

  Future<Null> handleLogOut() async {
    this.setState(() {
      isLoading = true;
    });
    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    this.setState(() {
      isLoading = false;
    });
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false);
  }
}
