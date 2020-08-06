import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_me/model/messageDetail.dart';

class Message {

  String chatId;
  String senderId;
  String receiverId;
  String senderImg;
  String receiverImg;
  String senderName;
  String receiverName;
  Timestamp date;
  List<MessageDetail> messagesForRead = [];
  List<dynamic> messagesForWrite      = [];

  Message({
    this.chatId,
    this.senderId,
    this.receiverId,
    this.senderImg,
    this.receiverImg,
    this.senderName,
    this.receiverName,
    this.date,
    this.messagesForWrite
  });

  Map<String, dynamic> toMap(){
    return {
      'chatId':       chatId,
      'senderId':     senderId,
      'receiverId':   receiverId,
      'senderImg':    senderImg,
      'receiverImg':  receiverImg,
      'senderName':   senderName,
      'receiverName': receiverName,
      'date':         date,
      'messages':     messagesForWrite
    };
  }

  Message.fromMap(map){
    this.chatId           = map['chatId'] ?? '';
    this.senderId         = map['senderId'] ?? '';
    this.receiverId       = map['receiverId'] ?? '';
    this.senderImg        = map['senderImg'] ?? '';
    this.receiverImg      = map['receiverImg'] ?? '';
    this.senderName       = map['senderName'] ?? '';
    this.receiverName     = map['receiverName'] ?? '';
    this.date             = map['date'] ?? Timestamp.now();
    this.messagesForWrite = map['messages'] ?? List<dynamic>();

    messagesForRead = [];
    messagesForWrite.forEach((element){
      messagesForRead.add(MessageDetail.fromMap(element));
    });
  }
}