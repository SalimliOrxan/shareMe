import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/model/message.dart';
import 'package:share_me/model/messageDetail.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/ui/navigation/chat/groupInfo.dart';

class ChatMessages extends StatefulWidget {

  final User me;
  final List<User> receivers;
  ChatMessages({@required this.me, @required this.receivers});

  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}


class _ChatMessagesState extends State<ChatMessages> {

  Message _chat;
  List<ChatMessage>_activeMessages;

  @override
  Widget build(BuildContext context) {
    _chat = Provider.of<Message>(context);
    _initMessages();

    return Scaffold(
        backgroundColor: colorApp,
        appBar: _appBar(),
        body: _chat == null ? _emptyBody() : _body()
    );
  }



  Widget _appBar(){
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.black26,
      actionsIconTheme: IconThemeData(color: Colors.white),
      actions: <Widget>[
        _more()
      ]
    );
  }

  Widget _body(){
    return Stack(
      children: <Widget>[
        _chatView(),
        Visibility(
            visible: _chat.messagesForRead.length == 0,
            child: _emptyBody()
        )
      ],
    );
  }

  Widget _emptyBody(){
    return Center(child: Icon(Icons.chat, size: 100, color: Colors.deepOrange));
  }

  Widget _chatView(){
    ChatUser user = ChatUser()
      ..uid    = widget.me.uid
      ..name   = widget.me.fullName
      ..avatar = widget.me.imgProfile;

    return DashChat(
        onSend: _sendMessage,
        user: user,
        showUserAvatar: true,
        messages: _activeMessages
    );
  }

  Widget _more(){
    return PopupMenuButton(
        onSelected: _onPressedPopUp,
        color: colorApp,
        icon: Icon(Icons.more_vert, color: Colors.white),
        itemBuilder: (BuildContext context){
          return <PopupMenuEntry<String>>[
            PopupMenuItem(
                height: 40,
                value: 'info',
                child: Text(
                    'Group info',
                    style: TextStyle(fontSize: 14, color: Colors.white)
                )
            ),
            PopupMenuItem(
                height: 40,
                value: 'exit',
                child: Text(
                    'Exit group',
                    style: TextStyle(fontSize: 14, color: Colors.white)
                )
            ),
            PopupMenuItem(
                height: 40,
                value: 'delete',
                child: Text(
                    'Delete group',
                    style: TextStyle(fontSize: 14, color: Colors.white)
                )
            )
          ];
        }
    );
  }



  void _initMessages(){
    _activeMessages = [];
    if(_chat != null){
      _chat.messagesForRead.forEach((element){
        ChatUser user = ChatUser()
          ..uid    = element.uid
          ..name   = element.fullName
          ..avatar = element.img;

        ChatMessage message = ChatMessage(user: user, text: element.message, createdAt: element.date.toDate());
        _activeMessages.add(message);
      });
    }
  }

  Future<void>_sendMessage(ChatMessage message) async {
    _activeMessages.add(message);

    MessageDetail messageDetail = MessageDetail()
      ..date = Timestamp.now()
      ..uid = widget.me.uid
      ..message = message.text
      ..fullName = widget.me.fullName
      ..img = widget.me.imgProfile;

    _chat.messagesForRead.add(messageDetail);
    _chat.messagesForWrite.add(messageDetail.toMap());

    await Database.instance.updateChat(_chat);

    print(widget.receivers.length.toString());
    widget.receivers.forEach((user) async {
      print(_chat.chatId);
      if(user.deletedChats.contains(_chat.chatId)){
        await Database.instance.updateOtherUser(user..deletedChats.remove(_chat.chatId));
      }
    });
  }

  void _onPressedPopUp(String value){
    switch(value){
      case 'info':
        _openGroupInfo();
        break;

      case 'exit':
        break;

      case 'delete':
        break;
    }
  }

  void _openGroupInfo(){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => MultiProvider(
              providers: [
                StreamProvider.value(value: Database.instance.usersByUid(widget.me.friends)),
                StreamProvider.value(value: Database.instance.getChatById(_chat.chatId))
              ],
              child: GroupInfo()
            )
        )
    );
  }
}