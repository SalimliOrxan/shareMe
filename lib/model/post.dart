import 'package:share_me/model/commentDetail.dart';

class Post{

  List<Map<String, CommentDetail>>comments;
  List<dynamic>hour;
  List<dynamic>titles;
  int countComment;


  Post({
    this.comments,
    this.hour,
    this.titles,
    this.countComment
  });

  Map<String, dynamic> toMap(){
    return {
      'comments':     comments,
      'hour':         hour,
      'titles':       titles,
      'countComment': countComment
    };
  }


  Post.fromMap(Map map){
    CommentDetail commentDetail;
    Map<String, CommentDetail>commentDetailMap = Map();

    List<dynamic> data = map['comments'] ?? List<Map<String, CommentDetail>>();
    if(data.length > 0){
      this.comments = List();
      data.forEach((map1){
        commentDetailMap = Map();
        map1.forEach((key, map2){
          commentDetail = CommentDetail.fromMap(map2);
          commentDetailMap[key] = commentDetail;
        });
        this.comments.add(commentDetailMap);
      });
    } else this.comments = List<Map<String, CommentDetail>>();

    this.hour         = map['hour'] ?? List<dynamic>();
    this.titles       = map['titles'] ?? List<dynamic>();
    this.countComment = map['countComment'] ?? 0;
  }
}