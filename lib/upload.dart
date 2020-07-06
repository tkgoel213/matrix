import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matrix/usermodel.dart';
import 'package:matrix/widgets/progressbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as InD;

import 'home.dart';

class Upload extends StatefulWidget {
  final User gcurrentuser;

  Upload({this.gcurrentuser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> with AutomaticKeepAliveClientMixin<Upload>{
  bool uploading =false;
  String postid=Uuid().v4();
   File imageURI;
  TextEditingController caption = TextEditingController();
  TextEditingController location = TextEditingController();

   Future getImageFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      imageURI = image;
    });
  }

   Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      imageURI = image;
    });
  }


  displayuploadscreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.add_a_photo,
            color: Colors.grey,
            size: 150.0,
          ),
          Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                color: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.0),
                ),
                child: Text(
                  "Camera",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
                onPressed: () => getImageFromCamera(),
              )),
          Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                color: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.0),
                ),
                child: Text(
                  "Gallery",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
                onPressed: () => getImageFromGallery(),
              ))
        ],
      ),
    );
  }

  removeimage() {
    location.clear();
    caption.clear();
    setState(() {

      imageURI = null;
    });
  }

  getuserlocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> place = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark mplace = place[0];
    String completedress =
        '${mplace.subThoroughfare} ${mplace.thoroughfare},${mplace.subLocality} ${mplace.locality},${mplace.subAdministrativeArea} ${mplace.administrativeArea},${mplace.postalCode} ${mplace.country}';
    String partadress = ' ${mplace.locality},${mplace.country}';
    location.text = partadress;
  }

  compressphoto(File img) async{
    final tdirectory=await getTemporaryDirectory();
    final path=tdirectory.path;
    InD.Image mimagefile=InD.decodeImage(img.readAsBytesSync());
    final compressedimagefile=File('$path/img_$postid.jpg')..writeAsBytesSync(InD.encodeJpg(mimagefile,quality: 60));
    setState(() {
      img=compressedimagefile;
      imageURI=compressedimagefile;
    });


  }


  controluploadandsave(File img) async
  {
    setState(() {
      uploading=true;
    });

    await compressphoto(img);
    String downloadurl=await uploadphoto(img);
    savepostsinfotofirestore(url:downloadurl,location:location.text,description:caption.text);
    location.clear();
    caption.clear();
    setState(() {
      imageURI=null;
      uploading=false;
      postid=Uuid().v4();
    });

  }
  savepostsinfotofirestore({String url,String description,String location}){
     postssref.document(widget.gcurrentuser.id).collection("usersposts").document(postid).setData({
       "postid":postid,
       "ownerid":widget.gcurrentuser.id,
       "username":widget.gcurrentuser.username,
       "timestamp":DateTime.now(),
       "Likes":{},
       "description": description,
       "location":location,
       "url":url
     });

  }

  Future<String> uploadphoto(mimagefile) async{
      StorageUploadTask storageUploadTask=storageReference.child("post_$postid.jpg").putFile(mimagefile);
      StorageTaskSnapshot storageTaskSnapshot=await storageUploadTask.onComplete;
      String url=await storageTaskSnapshot.ref.getDownloadURL();
      return url;
  }


   displayuploadformscreen(File img)  {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed : () => removeimage(),
        ),
        title: Text(
          "new post",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontSize: 24.0,
              fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: uploading ? null : () => controluploadandsave(img),
            child: Text(
              "Share",
              style: TextStyle(
                  color: Colors.green,
                  fontStyle: FontStyle.italic,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          uploading ? circularprogress() :Text(" "),
           Container(
             height: 300.0,
             width: 300.0,
             decoration: BoxDecoration(
               image: DecorationImage(
                 image: FileImage(
                   img
                 ),fit: BoxFit.cover
               )
             ),
           ),
          Padding(
            padding: EdgeInsets.only(top: 12.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.gcurrentuser.url),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: caption,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    labelText: "Write description here..",
                    labelStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.person_pin,
              color: Colors.white,
              size: 36.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: location,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    labelText: "Write Location here..",
                    labelStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none),
              ),
            ),
          ),
          Container(
            width: 220.0,
            height: 110.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35.0)),
              color: Colors.green,
              icon: Icon(
                Icons.location_on,
                color: Colors.white,
              ),
              label: Text(
                "Get my current location",
                style: TextStyle(color: Colors.white),
              ),
              onPressed:  () => getuserlocation(),
            ),
          )
        ],
      ),
    );
  }
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    return imageURI==null ? displayuploadscreen() : displayuploadformscreen(imageURI);
  }
}
