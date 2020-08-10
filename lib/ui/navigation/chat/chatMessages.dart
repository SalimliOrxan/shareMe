import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/model/message.dart';
import 'package:share_me/model/messageDetail.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/service/storage.dart';
import 'package:share_me/ui/navigation/chat/groupInfo.dart';
import 'dart:math' as math;

class ChatMessages extends StatefulWidget {

  final User me;
  final List<User> receivers;
  ChatMessages({@required this.me, @required this.receivers});

  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

enum FileFormat {GALLERY_IMAGE, CAMERA, GALLERY_VIDEO, VIDEO}

class _ChatMessagesState extends State<ChatMessages> {

  GlobalKey _key = GlobalKey();
  Message _chat;
  List<ChatMessage>_activeMessages;
  List<Color>_colors;
  File _file;
  int _userCount = 0;

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
        actions: <Widget>[
          IconButton(
              onPressed: _showInsertDialog,
              icon: Icon(Icons.attach_file, key: _key),
              padding: EdgeInsets.zero
          ),
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
        ]
    );
  }

  Widget _emptyBody(){
    return Center(child: Icon(Icons.chat, size: 100, color: Colors.deepOrange));
  }

  Widget _chatView(){
    ChatUser user = ChatUser(uid: widget.me.uid, name: widget.me.fullName, avatar: widget.me.imgProfile);

    return DashChat(
      onSend: _sendMessage,
      user: user,
      showUserAvatar: true,
      scrollToBottom: true,
      onLoadEarlier: (){},
      messages: _activeMessages,
      messageTextBuilder: (text, [messages]){
        return _itemMessageText(text, messages);
      }
    );
  }

  Widget _itemMessageText(String text, ChatMessage messages){
    int index = _chat.usersForRead.indexWhere((element) => element.uid == messages.user.uid);

    return Column(
        children: <Widget>[
          Text(
            messages.user.name,
            style: TextStyle(color: _colors[index]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Text(
              text,
              style: TextStyle(color: Colors.white70),
            )
          )
        ]
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
    if(_chat != null){
      _activeMessages = [];

      _chat.messagesForRead.forEach((data){
        ChatUser user       = ChatUser(uid: data.uid, name: data.fullName, avatar: data.userIcon, containerColor: Colors.black26, color: Colors.white70);
        ChatMessage message = ChatMessage(user: user, text: data.message, createdAt: data.date.toDate(), image: data.img, video: data.video);
        _activeMessages.add(message);
      });

      if(_chat.usersForRead.length != _userCount){
        _colors = [];
        _userCount = _chat.usersForRead.length;

        _chat.usersForRead.forEach((element){
          _colors.add(Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0));
        });
      }
    }
  }

  Future<void>_sendMessage(ChatMessage message) async {
    String urlImage = await Storage.instance.uploadChatFile(_file, _chat.chatId);

    MessageDetail messageDetail = MessageDetail()
      ..date = Timestamp.now()
      ..uid = widget.me.uid
      ..message = message.text
      ..fullName = widget.me.fullName
      ..userIcon = widget.me.imgProfile
      ..img = urlImage;

    _chat.messagesForRead.add(messageDetail);
    _chat.messagesForWrite.add(messageDetail.toMap());
    _chat.senderFcmToken = widget.me.fcmToken;

    await Database.instance.updateChat(_chat, null);

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
    _chat.fcmTokens.remove(widget.me.fcmToken);
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

  Future<void>_showInsertDialog() async {
    RenderBox box = _key.currentContext.findRenderObject();
    Offset position = box.localToGlobal(Offset.zero);

    var selected = await showMenu(
      context: context,
      color: Colors.transparent,
      position: RelativeRect.fromLTRB(position.dx, position.dy + 40, 0, 0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      items: [
        PopupMenuItem(
            value: 'image',
            height: 65,
            child: Center(
              child: CircleAvatar(
                maxRadius: 30,
                backgroundColor: Colors.black,
                child: Icon(Icons.photo, color: Colors.lightBlueAccent, size: 30)
              )
            )
        ),
        PopupMenuItem(
            value: 'video',
            height: 65,
            child: Center(
              child: CircleAvatar(
                  maxRadius: 30,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.video_library, color: Colors.lightBlueAccent, size: 30)
              )
            )
        )
      ]
    );
    _onPressedInsert(selected);
  }

  Future<void>_onPressedInsert(String value) async {
    switch(value){
      case 'image':
        _file = await pickImage(false);
        break;

      case 'video':
        _file = await pickVideo(false);
        break;
    }
  }
}