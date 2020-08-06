import 'package:cloud_firestore/cloud_firestore.dart';

class MessageDetail {

  String uid;
  String message;
  String fullName;
  String img;
  Timestamp date;

  MessageDetail({
    this.uid,
    this.message,
    this.fullName,
    this.img,
    this.date
  });

  Map<String, dynamic> toMap(){
    return {
      'uid':      uid,
      'message':  message,
      'fullName': fullName,
      'img':      img,
      'date':     date
    };
  }

  MessageDetail.fromMap(map){
    this.uid      = map['uid'] ?? '';
    this.message  = map['message'] ?? '';
    this.fullName = map['fullName'] ?? '';
    this.img      = map['img'] ?? '';
    this.date     = map['date'] ?? Timestamp.now();
  }
}