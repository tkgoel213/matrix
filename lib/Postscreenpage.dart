import 'package:flutter/material.dart';
import 'package:matrix/home.dart';
import 'package:matrix/widgets/headerwidget.dart';
import 'package:matrix/widgets/postwidget.dart';
import 'package:matrix/widgets/progressbar.dart';

class Postscreenpage extends StatelessWidget {
  String postid;
  String ownerid;


  Postscreenpage({this.postid, this.ownerid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postssref.document(ownerid).collection("usersposts").document(postid).get(),
      builder: (context,dataSnapshot){
        if(!dataSnapshot.hasData){
          return circularprogress();
        }
        Post post=Post.fromDocument(dataSnapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context,strtitle: post.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

