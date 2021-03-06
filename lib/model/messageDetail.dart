import 'package:cloud_firestore/cloud_firestore.dart';

class MessageDetail {

  String uid;
  String message;
  String fullName;
  String userIcon;
  String img;
  String video;
  String audio;
  String link;
  Timestamp date;

  MessageDetail({
    this.uid,
    this.message,
    this.fullName,
    this.userIcon,
    this.img,
    this.video,
    this.audio,
    this.link,
    this.date
  });

  Map<String, dynamic> toMap(){
    return {
      'uid':      uid,
      'message':  message,
      'fullName': fullName,
      'userIcon': userIcon,
      'img':      img,
      'video':    video,
      'audio':    audio,
      'link':     link,
      'date':     date
    };
  }

  MessageDetail.fromMap(map){
    this.uid      = map['uid'] ?? '';
    this.message  = map['message'] ?? '';
    this.fullName = map['fullName'] ?? '';
    this.userIcon = map['userIcon'];
    this.img      = map['img'];
    this.video    = map['video'];
    this.audio    = map['audio'];
    this.link     = map['link'];
    this.date     = map['date'] ?? Timestamp.now();
  }
}