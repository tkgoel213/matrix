import 'package:flutter/material.dart';

AppBar header(context,
    {bool isapptitle=false, String strtitle, disablebackbutton = false}) {
  return AppBar(
    iconTheme: IconThemeData(color: Colors.white),
    automaticallyImplyLeading: disablebackbutton ? false : true,
    title: Text(
      isapptitle ? "Matrix" : strtitle,
      style: TextStyle(color: Colors.white, fontSize: isapptitle ? 45.0 : 22.0,fontFamily: 'google pro',fontWeight: FontWeight.w100),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
