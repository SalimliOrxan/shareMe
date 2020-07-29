import 'package:cloud_firestore/cloud_firestore.dart';

class Post{

  String postId;
  String title;
  int countComment;
  Timestamp date;


  Post({
    this.postId,
    this.title,
    this.countComment,
    this.date
  });

  Map<String, dynamic> toMap(){
    return {
      'postId':       postId,
      'title':        title,
      'countComment': countComment,
      'date':         date
    };
  }

  Post.fromMap(Map map){
    this.postId       = map['postId'] ?? '';
    this.title        = map['title'] ?? '';
    this.countComment = map['countComment'] ?? 0;
    this.date         = map['date'] ?? Timestamp.now();
  }
}