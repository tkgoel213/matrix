import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:matrix/commentspage.dart';
import 'package:matrix/home.dart';
import 'package:matrix/usermodel.dart';
import 'package:matrix/widgets/progressbar.dart';

import '../profile.dart';

class Post extends StatefulWidget {
  final String postid;
  final String ownerid;
  final String username;
  final dynamic Likes;
  final String description;
  final String location;
  final String url;

  Post(
      {this.postid,
      this.ownerid,
      this.username,
      this.Likes,
      this.description,
      this.location,
      this.url});

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postid: documentSnapshot["postid"],
      ownerid: documentSnapshot["ownerid"],
      username: documentSnapshot["username"],
      Likes: documentSnapshot["Likes"],
      description: documentSnapshot["description"],
      location: documentSnapshot["location"],
      url: documentSnapshot["url"],
    );
  }

  int gettotallikes(Likes) {
    if (Likes == null) {
      return 0;
    }
    int counter = 0;
    Likes.values.forEach((eachValue) {
      if (eachValue == true) {
        counter = counter + 1;
      }
    });
    return counter;
  }

  @override
  _PostState createState() => _PostState(
      postid: this.postid,
      ownerid: this.ownerid,
      Likes: this.Likes,
      description: this.description,
      location: this.location,
      url: this.url,
      username: this.username,
      likecount: gettotallikes(this.Likes));
}

class _PostState extends State<Post> {
  final String postid;
  final String ownerid;
  final String username;
  Map Likes;
  final String description;
  final String location;
  final String url;
  int likecount;
  bool isliked;
  bool showheart = false;
  final String currentonlineuserid = currentuser.id;

  _PostState(
      {this.postid,
      this.ownerid,
      this.username,
      this.Likes,
      this.description,
      this.location,
      this.url,
      this.likecount});

  @override
  Widget build(BuildContext context) {
    isliked=(Likes[currentonlineuserid]==true);


    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: <Widget>[
          createpostheader(),
          createpostimage(),
          createpostfooter(),
        ],
      ),
    );
  }

  controlpostdelete(BuildContext mcontext){
    return showDialog(context: mcontext,builder: (context){
      return SimpleDialog(
       title: Text("What do you want ?",style: TextStyle(
         color: Colors.white
       ),),
        children: <Widget>[
          SimpleDialogOption(
            child: Text(
              "Delete this post",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
            ),

            onPressed: (){
              Navigator.pop(context);
              removeuserpost();
            },
          ),
          SimpleDialogOption(
            child: Text(
              "Cancel",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),
            ),
            onPressed: ()=> Navigator.pop(context),
          )
        ],

      );
    });
  }

  removeuserpost() async{
    postssref.document(ownerid).collection("usersposts").document(postid).get().then((value) {
      if(value.exists){
        value.reference.delete();
      }
    });

    storageReference.child("post_$postid.jpg").delete();
    QuerySnapshot querySnapshot=await activityfeedref.document(ownerid).collection("feeditems").where("postid",isEqualTo: postid).getDocuments();
    querySnapshot.documents.forEach((document) {
        if(document.exists){
          document.reference.delete();
        }
    });
    QuerySnapshot commentquerysnapshot=await commentsref.document(postid).collection("comments").getDocuments();
    commentquerysnapshot.documents.forEach((document) {
      if(document.exists){
        document.reference.delete();
      }
    });
  }

  createpostheader() {
    return FutureBuilder(
        future: usersref.document(ownerid).get(),
        builder: (context, datasnapshot) {
          if (!datasnapshot.hasData) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: circularprogress(),
            );
          }

          User user = User.fromDocument(datasnapshot.data);
          bool ispostowner = currentonlineuserid == ownerid;
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.url),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () => displayuserprofile(context,userprofileid: user.id),
              child: Text(
                user.username,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(
              location,
              style: TextStyle(color: Colors.white),
            ),
            trailing: ispostowner
                ? IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () => controlpostdelete(context),
                  )
                : Text(""),
          );
        });
  }
  displayuserprofile(BuildContext context,{String userprofileid}){
    Navigator.push(context, MaterialPageRoute(builder: (context) =>
        Profile(userprofileid:userprofileid)
    ));
  }

  removelike(){
    bool isnotpostowner= currentonlineuserid!=ownerid;
    if(isnotpostowner){
      activityfeedref.document(ownerid).collection("feeditems").document(postid).get().then((document) {
        if(document.exists){
          document.reference.delete();
        }
      });
    }
  }

  addlike(){
    bool isnotpostowner= currentonlineuserid!=ownerid;
    if(isnotpostowner){
      activityfeedref.document(ownerid).collection("feeditems").document(postid).setData({
        "type" :"like",
        "username":currentuser.username,
        "userid" :currentuser.id,
        "timestamp":DateTime.now(),
        "url":url,
        "postid":postid,
        "userprofileimage":currentuser.url



      });
    }
  }
  controluserlikes(){
    bool liked=Likes[currentonlineuserid]==true;

    if(liked){

      postssref.document(ownerid).collection("usersposts").document(postid).updateData({"Likes.$currentonlineuserid" :false});
      removelike();

      setState(() {
        likecount=likecount-1;
        isliked=false;
        Likes[currentonlineuserid]=false;

      });
    }

    else if(!liked){
      postssref.document(ownerid).collection("usersposts").document(postid).updateData({"Likes.$currentonlineuserid" :true});
      addlike();
      setState(() {
        likecount=likecount+1;
        isliked=true;
        Likes[currentonlineuserid]=true;
        showheart=true;

      });
      
      Timer(Duration(
        milliseconds: 600
      ),(){
        setState(() {
          showheart=false;
        });
      });
    }
  }


  createpostimage() {
    return GestureDetector(
      onDoubleTap: () => controluserlikes(),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.network(url),
          showheart ? Icon(Icons.favorite,size: 80.0,color: Colors.red,) : Text("")
        ],
      ),
    );
  }



  createpostfooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 40.0, left: 20),
            ),
            GestureDetector(
              onTap: () => controluserlikes(),
              child: Icon(
                isliked ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
                size: 25.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10),
            ),
            GestureDetector(
              onTap: () => displaycomments(context,postid:postid,ownerid:ownerid,url:url),
              child: Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 25.0,
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                "$likecount likes",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                "$username ",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(
                description,
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        )
      ],
    );
  }

  displaycomments(BuildContext context,{String postid,String ownerid,String url}){
    Navigator.push(context, MaterialPageRoute(builder: (context){


      return commentspage(postid:postid,postownerid:ownerid,postimageurl:url);
    }));
  }
}
