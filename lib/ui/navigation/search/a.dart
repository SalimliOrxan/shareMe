import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/model/post.dart';

class A extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    List<Post> posts = Provider.of<List<Post>>(context);
    if(posts != null) {
      print('name = ${posts[0].comments[0]['0'].comment}');
   }


    return Scaffold(
      body: Container()
    );
  }
}