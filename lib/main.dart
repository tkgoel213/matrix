import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:matrix/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matrix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'google pro',
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.black,
        dialogBackgroundColor: Colors.black,
        accentColor: Colors.black
      ),
      home: homepage(),
    );
  }
}


