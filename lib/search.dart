import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/home.dart';
import 'package:matrix/profile.dart';
import 'package:matrix/usermodel.dart';
import 'package:matrix/widgets/progressbar.dart';
import 'package:cached_network_image/cached_network_image.dart';


class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchedtext = TextEditingController();
  Future<QuerySnapshot> futuresesults;

  emptyfield() {
    searchedtext.clear();
  }

  controlsearching(String str) {
    Future<QuerySnapshot> allusers = usersref.where(
        "profilename", isGreaterThanOrEqualTo: str).getDocuments();
    setState(() {
      futuresesults = allusers;
    });
  }

  AppBar searchpageheader() {
    return AppBar(
      backgroundColor: Colors.black,
      title: TextFormField(
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.white,
        ),
        controller: searchedtext,
        decoration: InputDecoration(
            hintText: "Search here..",
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            filled: true,
            prefixIcon: Icon(
              Icons.supervised_user_circle,
              color: Colors.white,
              size: 30.0,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: emptyfield,
            )),
        onFieldSubmitted: controlsearching,
      ),
    );
  }

  Container displaynoresultsscreen() {
    final Orientation orientation = MediaQuery
        .of(context)
        .orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(
              Icons.hourglass_empty,
              color: Colors.grey,
              size: 150.0,
            ),
            Text(
              "Search Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 60.0
              ),
            )

          ],
        ),
      ),
    );
  }

  displayusersfound(){
    return FutureBuilder(
      future: futuresesults,
      builder: (context,datasnapshot){
          if(!datasnapshot.hasData){
            return circularprogress();
          }

          List<userresult> searchuserresult=[];
          datasnapshot.data.documents.forEach((document){
          User eachuser=User.fromDocument(document);
          userresult userres=userresult(eachuser);
          searchuserresult.add(userres);
          });
      return ListView(children: searchuserresult,);
      },
    );
  }
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: searchpageheader(),
      body: futuresesults == null ? displaynoresultsscreen(): displayusersfound(),
    );
  }
}


class userresult extends StatelessWidget {
  final User eachuser;
  userresult(this.eachuser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3.0),
      child: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: ()=>displayuserprofile(context,userprofileid:eachuser.id),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: CachedNetworkImageProvider(
                    eachuser.url
                  ),
                ),
                title: Text(
                  eachuser.profilename,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0
                  ),
                ),
                subtitle: Text(
                  eachuser.username,
                  style: (
                  TextStyle(
                    color: Colors.white,
                    fontSize: 12.0
                  )
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  displayuserprofile(BuildContext context,{String userprofileid}){
    Navigator.push(context, MaterialPageRoute(builder: (context) =>
        Profile(userprofileid:userprofileid)
    ));
  }
}
