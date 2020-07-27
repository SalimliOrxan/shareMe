import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_me/model/commentDetail.dart';

class Post{

  String postId;
  List<Map<String, CommentDetail>>commentsForRead;
  List<dynamic>commentsForWrite = [];
  String title;
  int countComment;
  Timestamp hour;
  Timestamp date;


  Post({
    this.postId,
    this.commentsForWrite,
    this.title,
    this.countComment,
    this.hour,
    this.date
  });

  Map<String, dynamic> toMap(){
    return {
      'postId':       postId,
      'comments':     commentsForWrite,
      'title':        title,
      'countComment': countComment,
      'hour':         hour,
      'date':         date
    };
  }

  Post.fromMap(Map map){
    CommentDetail commentDetail;
    Map<String, CommentDetail>commentDetailMap = Map();

    List<dynamic> data = map['comments'] ?? List<Map<String, CommentDetail>>();
    if(data.length > 0){
      this.commentsForRead = List();
      data.forEach((map1){
        commentDetailMap = Map();
        map1.forEach((key, map2){
          commentDetail = CommentDetail.fromMap(map2);
          commentDetailMap[key] = commentDetail;
        });
        this.commentsForRead.add(commentDetailMap);
      });
    } else this.commentsForRead = List<Map<String, CommentDetail>>();

    this.postId       = map['postId'] ?? '';
    this.title        = map['title'] ?? '';
    this.countComment = map['countComment'] ?? 0;
    this.hour         = map['hour'] ?? Timestamp.now();
    this.date         = map['date'] ?? Timestamp.now();
  }
}