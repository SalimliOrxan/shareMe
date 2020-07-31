import 'package:cloud_firestore/cloud_firestore.dart';

class Post{

  String uid;
  String fullName;
  String userImg;
  String postId;
  String title;
  String fileName;
  String fileUrl;
  String fileType;
  int countComment;
  int countShare;
  Timestamp date;
  List<dynamic>likedUsers;


  Post({
    this.uid,
    this.fullName,
    this.userImg,
    this.postId,
    this.title,
    this.fileName,
    this.fileUrl,
    this.fileType,
    this.countComment,
    this.countShare,
    this.date,
    this.likedUsers
  });

  Map<String, dynamic> toMap(){
    return {
      'uid':          uid,
      'fullName':     fullName,
      'userImg':      userImg,
      'postId':       postId,
      'title':        title,
      'fileName':     fileName,
      'fileUrl':      fileUrl,
      'fileType':     fileType,
      'countComment': countComment,
      'countShare':   countShare,
      'date':         date ?? Timestamp.now(),
      'likedUsers':   likedUsers
    };
  }

  Post.fromMap(Map map){
    this.uid          = map['uid'] ?? '';
    this.fullName     = map['fullName'] ?? '';
    this.userImg      = map['userImg'] ?? '';
    this.postId       = map['postId'] ?? '';
    this.title        = map['title'] ?? '';
    this.fileName     = map['fileName'] ?? '';
    this.fileUrl      = map['fileUrl'] ?? '';
    this.fileType     = map['fileType'] ?? '';
    this.countComment = map['countComment'] ?? 0;
    this.countShare   = map['countShare'] ?? 0;
    this.date         = map['date'] ?? Timestamp.now();
    this.likedUsers   = map['likedUsers'] ?? [];
  }
}