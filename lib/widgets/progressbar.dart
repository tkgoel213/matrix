import 'package:flutter/material.dart';

circularprogress(){
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top:12.0),
    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.blueGrey),),

  );
}