import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String id;
  final String profilename;
  final String username;
  final String url;
  final String email;
  final String bio;

  User({this.id, this.profilename, this.username, this.url, this.email, this.bio});

    factory User.fromDocument(DocumentSnapshot doc){
      return User(
        id:doc.documentID,
        email:doc['email'],
        username:doc['username'],
        url:doc['url'],
        profilename: doc['profilename'],
        bio: doc['bio']
      );
    }

}