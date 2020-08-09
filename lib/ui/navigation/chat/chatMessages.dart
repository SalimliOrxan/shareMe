import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
      title: Text(
        _chat?.groupName ?? '',
        style: TextStyle(color: Colors.white)
      ),
      actionsIconTheme: IconThemeData(color: Colors.white),
      actions: <Widget>[_more()]
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
            !_chat.isGroup ? null : PopupMenuItem(
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
    _clearFcm();
    _activeMessages.add(message);

    MessageDetail messageDetail = MessageDetail()
      ..date = Timestamp.now()
      ..uid = widget.me.uid
      ..message = message.text
      ..fullName = widget.me.fullName
      ..img = widget.me.imgProfile;

    _chat.messagesForRead.add(messageDetail);
    _chat.messagesForWrite.add(messageDetail.toMap());

    await Database.instance.updateChat(_chat, null);

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
        _showExitDialog();
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

  Future<void>_showExitDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext _context){
          return AlertDialog(
              scrollable: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              contentPadding: EdgeInsets.all(10),
              backgroundColor: colorApp,
              title: Text(
                'Are you sure?',
                style: TextStyle(color: Colors.white)
              ),
              actions: <Widget>[
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.cancel, color: Colors.deepOrange, size: 30)
                ),
                IconButton(
                    onPressed: _exitGroup,
                    icon: Icon(Icons.exit_to_app, color: Colors.deepOrange, size: 30)
                )
              ]
          );
        }
    );
  }

  Future<void>_exitGroup() async {
    Navigator.pop(context);
    _clearFcm();
    _chat.admins.remove(widget.me.uid);

    if(_chat.admins.length == 0){
      for(var user in _chat.usersForRead)
        if(user.uid != widget.me.uid){
          // add first user as admin
          _chat.admins.add(user.uid);
          break;
        }
    }

    for(var user in _chat.usersForRead){
      if(user.uid == widget.me.uid){
        int index = _chat.usersForRead.indexOf(user);
        _chat.usersForWrite.removeAt(index);
        break;
      }
    }

    await Database.instance.updateChat(_chat, null);
    await Database.instance.updateUserData(widget.me..chats.remove(_chat.chatId));
    await FirebaseMessaging().unsubscribeFromTopic(_chat.chatId);
  }

  void _clearFcm(){
    _chat.addedUsers.clear();
    _chat.removedUsers.clear();
  }
}