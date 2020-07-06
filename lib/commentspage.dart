import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:matrix/widgets/headerwidget.dart';
import 'package:matrix/widgets/progressbar.dart';
import 'home.dart';
import 'package:timeago/timeago.dart' as tAgo;


class commentspage extends StatefulWidget {
  final String postid;
  final String postownerid;
  final String postimageurl;

  commentspage({this.postid, this.postownerid, this.postimageurl});

  @override
  _commentspageState createState() => _commentspageState(
      postid: postid, postownerid: postownerid, postimageurl: postimageurl);
}

class _commentspageState extends State<commentspage> {
  final String postid;
  final String postownerid;
  final String postimageurl;
  TextEditingController commenteditingController = TextEditingController();

  _commentspageState({this.postid, this.postownerid, this.postimageurl});

  displaycomments() {
    return StreamBuilder(
      stream: commentsref
          .document(postid)
          .collection("comments")
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, datasnapshot) {
        if (!datasnapshot.hasData) {
          return circularprogress();
        }
        List<Comment> comments = [];
        datasnapshot.data.documents.forEach((document) {
          comments.add(Comment.fromDocument(document));
        });

        return ListView(
          children: comments,
        );
      },
    );
  }

  savecomment(){
    commentsref.document(postid).collection("comments").add({
      "username" :currentuser.username,
      "comment" : commenteditingController.text,
      "timestamp":DateTime.now(),
      "url":currentuser.url,
      "userid":currentuser.id
    });

    bool isnotpostowner= currentuser.id!=postownerid;
    if(isnotpostowner){
      activityfeedref.document(postownerid).collection("feeditems").add({
        "type":"comment",
        "commentData":commenteditingController.text,
        "postid":postid,
        "userid":currentuser.id,
        "username":currentuser.username,
        "userprofileimage":currentuser.url,
        "url":postimageurl,
        "timestamp":DateTime.now()
      });
    }
    commenteditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(1.0),
      child: Scaffold(
        appBar: header(context, strtitle: "Comments"),
        body: Column(
          children: <Widget>[
            Expanded(
              child: displaycomments(),
            ),
            Divider(),
            ListTile(
              title: TextFormField(
                controller: commenteditingController,
                decoration: InputDecoration(
                    labelText: "Write Comment here..",
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: (UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey))),
                focusedBorder:  (UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)))),

                style: TextStyle(
                  color: Colors.white
                ),


              ),

              trailing: OutlineButton(
                onPressed:savecomment,
                borderSide: BorderSide.none,
                child: Text(
                  "Publish",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String userid;
  final String username;
  final String url;
  final String comment;
  final Timestamp timestamp;

  factory Comment.fromDocument(DocumentSnapshot documentSnapshot) {
    return Comment(
      username: documentSnapshot["username"],
      userid: documentSnapshot["userid"],
      url: documentSnapshot["url"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
    );
  }

  Comment({this.userid, this.username, this.url, this.comment, this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(username +"  :: " + comment,style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,

              ),
              ),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(url),
              ),
              subtitle: Text(tAgo.format(timestamp.toDate()),style: TextStyle(
                color: Colors.white
              ),),
            )
          ],
        ),
      ),
    );
  }
}
