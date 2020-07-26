class CommentDetail{

  String uid;
  String name;
  String img;
  String comment;

  CommentDetail({
    this.uid,
    this.name,
    this.img,
    this.comment
  });


  Map<String, dynamic> toMap(){
    return {
      'uid':     uid,
      'name':    name,
      'img':     img,
      'comment': comment
    };
  }

  CommentDetail.fromMap(Map map){
    this.uid     = map['uid'] ?? '';
    this.name    = map['name'] ?? '';
    this.img     = map['img'] ?? '';
    this.comment = map['comment'] ?? '';
  }
}