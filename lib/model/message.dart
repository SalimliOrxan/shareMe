import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_me/model/messageDetail.dart';

import 'chatUser.dart';

class Message {

  String chatId;
  String groupName;
  String groupImg;
  String senderFcmToken;
  bool isGroup = false;
  Timestamp date;
  List<MessageDetail> messagesForRead = [];
  List<dynamic> messagesForWrite      = [];
  List<MyChatUser> usersForRead       = [];
  List<dynamic> usersForWrite         = [];
  List<dynamic> admins                = [];
  List<dynamic> fcmTokens             = [];

  Message({
    this.chatId,
    this.groupName,
    this.groupImg,
    this.senderFcmToken,
    this.isGroup,
    this.date,
    this.messagesForWrite,
    this.usersForWrite,
    this.admins,
    this.fcmTokens
  });

  Map<String, dynamic> toMap(){
    return {
      'chatId':         chatId,
      'groupName':      groupName,
      'groupImg':       groupImg,
      'senderFcmToken': senderFcmToken,
      'isGroup':        isGroup,
      'date':           date,
      'messages':       messagesForWrite,
      'users':          usersForWrite,
      'admins':         admins,
      'fcmTokens':      fcmTokens
    };
  }

  Message.fromMap(map){
    this.chatId           = map['chatId'] ?? '';
    this.groupName        = map['groupName'] ?? '';
    this.groupImg         = map['groupImg'] ?? '';
    this.senderFcmToken   = map['senderFcmToken'] ?? '';
    this.isGroup          = map['isGroup'] ?? false;
    this.date             = map['date'] ?? Timestamp.now();
    this.messagesForWrite = map['messages'] ?? List<dynamic>();
    this.usersForWrite    = map['users'] ?? List<dynamic>();
    this.admins           = map['admins'] ?? List<dynamic>();
    this.fcmTokens        = map['fcmTokens'] ?? List<dynamic>();

    messagesForRead = [];
    messagesForWrite.forEach((element){
      messagesForRead.add(MessageDetail.fromMap(element));
    });

    usersForRead = [];
    usersForWrite.forEach((chatUser){
      usersForRead.add(MyChatUser.fromMap(chatUser));
    });
  }
}