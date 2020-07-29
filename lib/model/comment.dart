import 'commentDetail.dart';

class Comment{

  String commentId;
  List<Map<String, CommentDetail>>commentsForRead;
  List<dynamic>commentsForWrite = [];


  Comment({
    this.commentId,
    this.commentsForWrite
  });

  Map<String, dynamic> toMap(){
    return {
      'commentId':    commentId,
      'comments':     commentsForWrite
    };
  }

  Comment.fromMap(Map map){
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

    this.commentId = map['commentId'] ?? '';
  }
}