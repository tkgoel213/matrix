import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:matrix/Postscreenpage.dart';
import 'package:matrix/profile.dart';
import 'package:matrix/widgets/headerwidget.dart';
import 'package:matrix/widgets/progressbar.dart';
import 'home.dart';
import 'package:timeago/timeago.dart' as tAgo;

class Notificationpage extends StatefulWidget {
  @override
  _NotificationpageState createState() => _NotificationpageState();
}

class _NotificationpageState extends State<Notificationpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strtitle: "Notifications"),
      body: Container(
        child: FutureBuilder(
            future: retrievenotifications(),
            builder: (context, datasnapshot) {
              if (!datasnapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: circularprogress(),
                );
              }
              return ListView(
               children:datasnapshot.data,
              );
            }),
      ),
    );
  }

  retrievenotifications() async {
    QuerySnapshot querySnapshot = await activityfeedref
        .document(currentuser.id)
        .collection("feeditems")
        .orderBy("timestamp", descending: true)
        .limit(60)
        .getDocuments();
    List<Notificationitem> notificationitems = [];
    querySnapshot.documents.forEach((document) {
      notificationitems.add(Notificationitem.fromDocument(document));
    });

    return notificationitems;
  }
}

Widget mediapreview;
String notificationitemtext;

class Notificationitem extends StatelessWidget {
  final String type;
  final String username;
  final String userid;
  final String commentData;
  final String postid;
  final String userprofileimage;
  final String url;
  final Timestamp timestamp;

  Notificationitem(
      {this.type,
      this.username,
      this.userid,
      this.commentData,
      this.postid,
      this.userprofileimage,
      this.url,
      this.timestamp});

  factory Notificationitem.fromDocument(DocumentSnapshot documentSnapshot) {
    return Notificationitem(
        username: documentSnapshot["username"],
        type: documentSnapshot["type"],
        userid: documentSnapshot["userid"],
        commentData: documentSnapshot["commentData"],
        postid: documentSnapshot["postid"],
        userprofileimage: documentSnapshot["userprofileimage"],
        url: documentSnapshot["url"],
        timestamp: documentSnapshot["timestamp"]);
  }

  @override
  Widget build(BuildContext context) {
    configuremediapreview(context);
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: Container(
        color: Colors.white,
        child: ListTile(
          title: GestureDetector(
            onTap: () => displayuserprofile(context, userprofileid: userid),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                  children: [
                    TextSpan(
                      text: username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: " $notificationitemtext"),
                  ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userprofileimage),
          ),
          subtitle: Text(
            tAgo.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black),
          ),
          trailing: mediapreview,
        ),
      ),
    );
  }

  configuremediapreview(context) {
    if (type == "comment" || type == "like") {
      mediapreview = GestureDetector(
        onTap: ()=>displayfullpost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(url))),
            ),
          ),
        ),
      );
    } else {
      mediapreview = Text("");
    }

    if (type == "like") {
      notificationitemtext = "liked your post";
    }
    else if (type == "comment") {
      notificationitemtext = "replied $commentData";
    }
    else if (type == "follow") {
      notificationitemtext = "started following you";
    } else {
      notificationitemtext = "Error unknown type =  $type ";
    }
  }

  displayfullpost(context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Postscreenpage(
                  postid: postid,
                  ownerid: userid,
                )));
  }

  displayuserprofile(BuildContext context, {String userprofileid}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Profile(userprofileid: userprofileid)));
  }
}
