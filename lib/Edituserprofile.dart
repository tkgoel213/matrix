import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:matrix/home.dart';
import 'package:matrix/profile.dart';
import 'package:matrix/usermodel.dart';
import 'package:matrix/widgets/progressbar.dart';

class Edituserprofile extends StatefulWidget {
  final String currentonlineuserId;


  Edituserprofile({this.currentonlineuserId});

  @override
  _EdituserprofileState createState() => _EdituserprofileState();
}

class _EdituserprofileState extends State<Edituserprofile> {
  TextEditingController profilename = TextEditingController();
  TextEditingController bio = TextEditingController();
  final scaffoldglobalkey = GlobalKey<ScaffoldState>();
  bool loading = false;
  User user;
  bool biovalid = true;
  bool profilevalid = true;


  void initState(){
    super.initState();
    getanddisplayuserinfo();
  }
  getanddisplayuserinfo() async{
    setState(() {
      loading=true;

    });

    DocumentSnapshot documentSnapshot=await usersref.document(widget.currentonlineuserId).get();
    user=User.fromDocument(documentSnapshot);
    profilename.text=user.profilename;
    bio.text=user.bio;
    setState(() {
      loading=false;
    });
  }

 Column createprofilefield(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Profile name",style: TextStyle(
            color: Colors.grey,
          ),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.white),

          controller: profilename,
          decoration: InputDecoration(
            fillColor: Colors.white,
            hintText: "Write profile name here..",
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white
              )
            ),
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            errorText: profilevalid ? null :"Profile name is very short"
          ),
        )

      ],
    );
  }

  Column createbiofield()
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "write bio",style: TextStyle(
            color: Colors.grey,
          ),
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.white),
          controller: bio,
          decoration: InputDecoration(
            fillColor: Colors.white,
              hintText: "Write bio here..",
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white
                  )
              ),
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
              errorText: biovalid ? null :"Bio is very Long"
          ),
        )

      ],
    );
  }
  updateprofile(){
   setState(() {
     profilename.text.trim().length<3 || profilename.text.isEmpty ? profilevalid=false : profilevalid=true;
     bio.text.trim().length>120 || bio.text.isEmpty ? biovalid=false :biovalid=true;
   });
   if(profilevalid && biovalid){
     usersref.document(widget.currentonlineuserId).updateData({
       "profilename":profilename.text,
       "bio" :bio.text
     });

     SnackBar snackBar=SnackBar(
       content: Text("Profile has been updated"),
     );

     scaffoldglobalkey.currentState.showSnackBar(snackBar);
   }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldglobalkey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white,),
        title: Text(
          "Edit Profile",
          style: TextStyle(
              color: Colors.white,
            fontSize: 40.0,

          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.done,
            color: Colors.white,
            size: 30.0),
            onPressed: () => Navigator.pop(context))
        ],
      ),
      body: loading ? circularprogress() :ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      createprofilefield(),
                      createbiofield(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 25.0,left: 50.0,right: 50.0),
                  child: RaisedButton(
                    onPressed: () => updateprofile(),
                    child: Text(
                      "Update",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0
                      ),
                    ),

                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
