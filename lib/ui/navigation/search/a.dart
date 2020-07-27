import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/model/commentDetail.dart';
import 'package:share_me/model/post.dart';
import 'package:share_me/service/database.dart';

class A extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    List<Post> posts = Provider.of<List<Post>>(context);

    return Scaffold(
      body: Container(
        child: InkWell(
          onTap: (){
            if(posts != null) {
              List<dynamic>list = [];
              Map<String, dynamic> map1 = Map();

              CommentDetail c = CommentDetail();
              c.comment = 'updated';
              map1['0'] = c.toMap();
              list.add(map1);
              Post newPost = Post()
                ..commentsForWrite = list
                ..countComment = 120
                ..postId = posts[1].postId;

              print('name = ${list}');

              Database.instance.updatePost(newPost);

            }
          },
          child: Center(child: Text('Tap here'))
        ),
      )
    );
  }
}