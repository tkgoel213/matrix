import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:matrix/Notificationpage.dart';
import 'package:matrix/createaccountpage.dart';
import 'package:matrix/profile.dart';
import 'package:matrix/search.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:matrix/timeline.dart';
import 'package:matrix/upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:matrix/usermodel.dart';


final GoogleSignIn googleSignIn = GoogleSignIn();
final usersref=Firestore.instance.collection("users");
final StorageReference storageReference=FirebaseStorage.instance.ref().child("Posts pictures");
final postssref=Firestore.instance.collection("posts");
final activityfeedref=Firestore.instance.collection("feed");
final commentsref=Firestore.instance.collection("comments");
final followersref=Firestore.instance.collection("followers");
final followingsref=Firestore.instance.collection("following");
final timelineref=Firestore.instance.collection("timeline");






final DateTime time= DateTime.now();
User currentuser;


class homepage extends StatefulWidget {
  @override
  _homepageState createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  FirebaseMessaging firebaseMessaging=FirebaseMessaging();
  bool issignedin = false;
  PageController pageController;
  int getpageindex = 0;
  final scaffoldkey=GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((account) {
      controlsignin(account);
    }, onError: (err) {
      print("signin !$err");
    });
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      controlsignin(account);
    }).catchError((err) {
      print('Error signin $err');
    });
  }

  loginuser() {
    googleSignIn.signIn();
  }

  saveusertofirestore() async{
    final GoogleSignInAccount googlecurrentuser=googleSignIn.currentUser;
    DocumentSnapshot documentSnapshot= await usersref.document(googlecurrentuser.id).get();
    if(!documentSnapshot.exists){
      final username=await Navigator.push(context, MaterialPageRoute(builder: (context) => Createaccount()));
      usersref.document(googlecurrentuser.id).setData({
      "id":googlecurrentuser.id,
        "profilename":googlecurrentuser.displayName,
        "username":username,
        "url":googlecurrentuser.photoUrl,
        "email":googlecurrentuser.email,
        "bio":"",
        "timestamp" : time

      });


      await followersref.document(googlecurrentuser.id).collection("userfollowers").document(googlecurrentuser.id).setData({});
      documentSnapshot=await usersref.document(googlecurrentuser.id).get();

    }

    currentuser=User.fromDocument(documentSnapshot);
  }


  controlsignin(GoogleSignInAccount account) async {
    if (account != null) {
      await saveusertofirestore();
      setState(() {
        issignedin = true;
      });

      configurepushnotifications();

    } else {
      setState(() {
        issignedin = false;
      });
    }
  }
  configurepushnotifications(){
      final GoogleSignInAccount guser=googleSignIn.currentUser;
      if(Platform.isIOS){
        getpermissions();
      }
      firebaseMessaging.getToken().then((token) {
        usersref.document(guser.id).updateData({"androidNotificationToken":token});
      });
  firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> msg) async {
      final String recipientid= msg["data"]["recipient"];
      final String body= msg["notification"]["body"];

      if(recipientid==guser.id){
        SnackBar snackBar=SnackBar(
          backgroundColor: Colors.grey,
          content: Text(
            body,
            style: TextStyle(color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );
        scaffoldkey.currentState.showSnackBar(snackBar);
      }



    },
  );

  }
  getpermissions(){
    firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(alert: true,badge: true,sound: true));
  }

  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  logoutuser() {
    googleSignIn.signOut();
  }

  ontapchangepage(int pageindex) {
    pageController.animateToPage(pageindex,
        duration: Duration(milliseconds: 10), curve: Curves.linear);
  }

  whenpagechanges(int pageindex) {
    setState(() {
      this.getpageindex = pageindex;
    });
  }

  Scaffold buildsigninscreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor
            ])),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Matrix",
              style: TextStyle(fontSize: 92.0, color: Colors.white),
            ),
            GestureDetector(
              onTap: () => loginuser(),
              child: Container(
                width: 200.0,
                height: 100.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/invented.png"),
                        fit: BoxFit.cover)),
              ),
            )
          ],
        ),
      ),
    );
  }
  createbutton(){
    return RaisedButton(
      onPressed:()=> googleSignIn.signOut(),
      color: Colors.white,
    );
  }

  Scaffold buildhomescreen() {
    return Scaffold(
      key: scaffoldkey,
      body: PageView(
        children: <Widget>[Timeline(gcurrentuser: currentuser), Search(), Upload(gcurrentuser: currentuser,), Notificationpage(), Profile(userprofileid :currentuser.id)],
        controller: pageController,
        onPageChanged: whenpagechanges,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CurvedNavigationBar(
          index: getpageindex,
          height: 50.0,
          onTap: ontapchangepage,
          buttonBackgroundColor: Colors.white,
          backgroundColor: Theme.of(context).accentColor,
          items: <Widget>[
            Icon(Icons.rss_feed,size: 25.0,color: Colors.black,),
            Icon(Icons.search,size: 25.0,color: Colors.black,),
            Icon(Icons.camera,size: 35.0,color: Colors.black,),
            Icon(Icons.notifications_active,size: 25.0,color: Colors.black,),
            Icon(Icons.person,size: 25.0,color: Colors.black,),
          ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (issignedin) {
      return buildhomescreen();
    } else {
      return buildsigninscreen();
    }
  }
}
