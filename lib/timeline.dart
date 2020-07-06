import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:matrix/usermodel.dart';
import 'package:matrix/widgets/headerwidget.dart';
import 'package:matrix/widgets/postwidget.dart';
import 'package:matrix/widgets/progressbar.dart';

import 'home.dart';



class Timeline extends StatefulWidget {
  final User gcurrentuser;

  Timeline({this.gcurrentuser});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
  List<String> followings=[];
  final scaffoldkey=GlobalKey<ScaffoldState>();

  retrievefollowings() async{
    QuerySnapshot querySnapshot=await followingsref.document(widget.gcurrentuser.id).collection("userfollowings").getDocuments();

  setState(() {
    followings=querySnapshot.documents.map((document) => document.documentID).toList();
  });

  }


  retrievetimeline() async{
    QuerySnapshot querySnapshot=await timelineref.document(widget.gcurrentuser.id).collection("timelinePosts").orderBy("timestamp",descending: true).getDocuments();
    List<Post> allposts=querySnapshot.documents.map((document) => Post.fromDocument(document)).toList();
    setState(() {
      this.posts=allposts;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    retrievetimeline();
    retrievefollowings();
  }

  createusertimeline(){
    if(posts==null){
      return circularprogress();
    }
    else{
      return ListView(
        children: posts,
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      appBar: header(context,isapptitle: true),
      body: RefreshIndicator(child: createusertimeline(),onRefresh: ()=> retrievetimeline(),),
    );
  }
}

