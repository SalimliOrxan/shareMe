import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_me/model/messageDetail.dart';

import 'chatUser.dart';

class Message {

  String chatId;
  String groupName;
  String groupImg;
  String senderId;
  String senderImg;
  String senderName;
  bool isGroup = false;
  Timestamp date;
  List<MessageDetail> messagesForRead = [];
  List<dynamic> messagesForWrite      = [];
  List<MyChatUser> usersForRead       = [];
  List<dynamic> usersForWrite         = [];
  List<dynamic> admins                = [];
  List<dynamic> addedUsers            = [];
  List<dynamic> removedUsers          = [];

  Message({
    this.chatId,
    this.groupName,
    this.groupImg,
    this.senderId,
    this.senderImg,
    this.senderName,
    this.isGroup,
    this.date,
    this.messagesForWrite,
    this.usersForWrite,
    this.admins,
    this.addedUsers,
    this.removedUsers
  });

  Map<String, dynamic> toMap(){
    return {
      'chatId':       chatId,
      'groupName':    groupName,
      'groupImg':     groupImg,
      'senderId':     senderId,
      'senderImg':    senderImg,
      'senderName':   senderName,
      'isGroup':      isGroup,
      'date':         date,
      'messages':     messagesForWrite,
      'users':        usersForWrite,
      'admins':       admins,
      'addedUsers':   addedUsers,
      'removedUsers': removedUsers
    };
  }

  Message.fromMap(map){
    this.chatId           = map['chatId'] ?? '';
    this.groupName        = map['groupName'] ?? '';
    this.groupImg         = map['groupImg'] ?? '';
    this.senderId         = map['senderId'] ?? '';
    this.senderImg        = map['senderImg'] ?? '';
    this.senderName       = map['senderName'] ?? '';
    this.isGroup          = map['isGroup'] ?? false;
    this.date             = map['date'] ?? Timestamp.now();
    this.messagesForWrite = map['messages'] ?? List<dynamic>();
    this.usersForWrite    = map['users'] ?? List<dynamic>();
    this.admins           = map['admins'] ?? List<dynamic>();
    this.addedUsers       = map['addedUsers'] ?? List<dynamic>();
    this.removedUsers     = map['removedUsers'] ?? List<dynamic>();

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