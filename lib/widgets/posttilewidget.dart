import 'package:flutter/material.dart';
import 'package:matrix/Postscreenpage.dart';
import 'package:matrix/widgets/postwidget.dart';




class posttile extends StatelessWidget {
  final Post post;
  posttile(this.post);

  displayfullpost(context){
    Navigator.push(context, MaterialPageRoute(builder: (context) => Postscreenpage(postid :post.postid,ownerid :post.ownerid)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => displayfullpost(context),
      child: Image.network(post.url),
    );
  }
}
