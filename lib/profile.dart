import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matrix/home.dart';
import 'package:matrix/usermodel.dart';
import 'package:matrix/widgets/headerwidget.dart';
import 'package:matrix/widgets/posttilewidget.dart';
import 'package:matrix/widgets/postwidget.dart';
import 'package:matrix/widgets/progressbar.dart';
import 'Edituserprofile.dart';

class Profile extends StatefulWidget {
  String userprofileid;

  Profile({this.userprofileid});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentonlineuserid = currentuser.id;
  bool loading =false;
  int countpost;
  List<Post> postlist=[];
  String postorientation="grid";
  int counttotalfollowers=0;
  int counttotalfollowing=0;
  bool following=false;


  void initState(){
    super.initState();
    getallprofileposts();
    getallfollowers();
    getallfollowing();
    checkiffollowing();
  }
  getallfollowers() async{
    QuerySnapshot querySnapshot=await followersref.document(widget.userprofileid).collection("userfollowers").getDocuments();
    setState(() {
      counttotalfollowers=querySnapshot.documents.length;
    });
  }
  getallfollowing() async{
    QuerySnapshot querySnapshot=await followingsref.document(widget.userprofileid).collection("userfollowings").getDocuments();
    setState(() {
      counttotalfollowing=querySnapshot.documents.length;
    });
  }


  checkiffollowing() async{
    DocumentSnapshot documentSnapshot=await followersref.document(widget.userprofileid).collection("userfollowers").
    document(currentonlineuserid).get();
    setState(() {
      following=documentSnapshot.exists;
    });
  }


  createprofiletopview() {
    return FutureBuilder(
      future: usersref.document(widget.userprofileid).get(),
      builder: (context, datasnapshot) {
        if (!datasnapshot.hasData) {
          return circularprogress();
        }

        User user = User.fromDocument(datasnapshot.data);
        return Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 45.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            createcolumns("Posts", countpost),
                            createcolumns("Followers", counttotalfollowers),
                            createcolumns("Following", counttotalfollowing),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            createbutton(),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  user.username,style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white
                ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  user.profilename,style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.white
                ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  user.bio,style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.white
                ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  createbutton() {
    bool ownprofile = currentonlineuserid == widget.userprofileid;
    if(ownprofile){
      return createbuttontitleandfunction(title:"Edit Profile",performfunction:edituserprofile);
    }
    else if(following){
      return createbuttontitleandfunction(title:"Unfollow",performfunction:controlunfollow);
    }
    else if(!following){
      return createbuttontitleandfunction(title:"Follow",performfunction:controlfollow);
    }
  }
  controlfollow(){
    setState(() {
      following=true;
    });

    followersref.document(widget.userprofileid).collection("userfollowers").document(currentonlineuserid).setData({});
    followingsref.document(currentonlineuserid).collection("userfollowings").document(widget.userprofileid).setData({});
    activityfeedref.document(widget.userprofileid).collection("feeditems").document(currentonlineuserid).setData({
      "type":"follow",
      "ownerid":widget.userprofileid,
      "username":currentuser.username,
      "timestamp":DateTime.now(),
      "userprofileimage":currentuser.url,
      "userid":currentonlineuserid,

    });


  }

  controlunfollow(){
    setState(() {
      following=false;
    });

    followersref.document(widget.userprofileid).collection("userfollowers").document(currentonlineuserid).get().then((value){
      if(value.exists){
        value.reference.delete();
      }
    });
    followingsref.document(currentonlineuserid).collection("userfollowings").document(widget.userprofileid).get().then((value){
      if(value.exists){
        value.reference.delete();
      }
    });

    activityfeedref.document(widget.userprofileid).collection("feeditems").document(currentonlineuserid).get().then((value) {
      if(value.exists){
        value.reference.delete();
      }
    });
  }
  Container createbuttontitleandfunction({performfunction, String title}){
    return Container(
      padding: EdgeInsets.all(3.0),
      child: FlatButton(
        onPressed: performfunction,
        child: Container(
          width: 150.0,
          height: 25.0,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(6.0)
          ),
        ),
      ),
    );
  }

  Column createcolumns(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
                color: Colors.grey),
          ),
        )
      ],
    );
  }

  edituserprofile(){
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => Edituserprofile(currentonlineuserId: currentonlineuserid)
    )).then((value){
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strtitle: "Profile"),
      body: ListView(
        children: <Widget>[
          createprofiletopview(),
          Divider(height :3.0),
          createtileorgridposts(),
          Divider(height: 2.0,),
          displayprofilepost()
        ],
      ),
    );
  }



  displayprofilepost()
  {
      if(loading){
        return circularprogress();
      }
      else if(postlist.isEmpty){
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Icon(
                  Icons.photo,
                  color: Colors.white,
                  size: 100.0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  "No posts yet",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40.0
                  ),
                ),
              )
            ],
          ),
        );

      }
      else if(postorientation=="grid"){
        List<GridTile> gridlist=[];
        postlist.forEach((eachpost) {
          gridlist.add(GridTile(
            child: posttile(eachpost)
          ));
        });

        return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: gridlist,
        );
      }

      else if(postorientation=="list"){
        return SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: <Widget>[
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount:postlist.length,
                  itemBuilder: (context,index){
                    return Post(postid: postlist[index].postid,
                      location: postlist[index].location,
                      description: postlist[index].description,
                      url: postlist[index].url,
                      ownerid: postlist[index].ownerid,
                      username: postlist[index].username,
                      Likes: postlist[index].Likes,
                    );
                  })
            ],
          ),
        );
      }
  }

  getallprofileposts() async{

    setState(() {
      loading=true;
    });



    QuerySnapshot querySnapshot=await postssref.document(widget.userprofileid).collection("usersposts").orderBy("timestamp",descending: true).getDocuments();
  setState(() {
    loading=false;
    countpost=querySnapshot.documents.length;
    postlist=querySnapshot.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();

  });

  }

  createtileorgridposts(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: ()=> setorientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postorientation=="grid" ? Colors.white:Colors.grey,
        ),
        IconButton(
          onPressed: ()=> setorientation("list"),
          icon: Icon(Icons.list),
          color: postorientation=="list" ? Colors.white:Colors.grey,
        )
      ],
    );
  }
  setorientation(String orientation){
    setState(() {
      this.postorientation=orientation;
    });
  }
}
