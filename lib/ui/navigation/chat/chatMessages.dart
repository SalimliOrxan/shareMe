import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link_previewer/link_previewer.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/model/message.dart';
import 'package:share_me/model/messageDetail.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerChat.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/service/storage.dart';
import 'package:share_me/ui/navigation/chat/audioView.dart';
import 'package:share_me/ui/navigation/chat/groupInfo.dart';
import 'package:share_me/ui/navigation/chat/insertFileView.dart';
import 'package:share_me/ui/navigation/home/navigationHomePage.dart';
import 'package:share_me/ui/navigation/home/videoView.dart';
import 'package:share_me/ui/navigation/home/youtubeVideoView.dart';

class ChatMessages extends StatefulWidget {

  final User me;
  final List<User> receivers;
  ChatMessages({@required this.me, @required this.receivers});

  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

enum FileFormat {GALLERY_IMAGE, CAMERA, GALLERY_VIDEO, VIDEO}

class _ChatMessagesState extends State<ChatMessages> with TickerProviderStateMixin {

  ProviderChat _providerChat;
  Message _chat;
  List<ChatMessage>_activeMessages;
  List<int>_colorPositions;

  GlobalKey _key;
  AnimationController _animationController;
  TextEditingController _controllerMessage;
  File _file;
  Offset _startPosition;
  int _userCount = 0;
  bool _isDeletedFile = false;

  @override
  void initState() {
    _key = GlobalKey();
    _controllerMessage = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800)
    );
    _animationController.addListener((){
      if(_animationController.status == AnimationStatus.completed){
        _providerChat.isVoiceRecording = false;
        _animationController.reset();

        if(File(_providerChat.recording.path).existsSync()){
          File(_providerChat.recording.path).deleteSync();
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controllerMessage.dispose();
    _providerChat.clearAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _providerChat = Provider.of(context);
    _chat         = Provider.of<Message>(context);
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
        title: GestureDetector(
          onTap: _openGroupInfo,
          child: Container(
            width: double.infinity,
            color: Colors.transparent,
            child: Text(
                _chat?.groupName ?? '',
                style: TextStyle(color: Colors.white)
            ),
          )
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
          ),
          Visibility(
              visible: _providerChat.isVoiceRecording,
              child: _providerChat.voiceButtonPosition != null ? _voiceInputView() : Container()
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
        user: user,
        onSend: (_) => _sendMessage(),
        showUserAvatar: true,
        scrollToBottom: true,
        inputMaxLines: 4,
        onLoadEarlier: (){},
        chatFooterBuilder: _chatFooter,
        messages: _activeMessages,
        messageBuilder: _itemMessage,
        textController: _controllerMessage,
        sendButtonBuilder: _sendButton,
        onTextChange: (message){
          if(message.trim().length > 0 && !_providerChat.hasText){
            _providerChat.hasText = true;
          }
          else if(message.trim().length == 0 && _providerChat.hasText){
            _providerChat.hasText = false;
          }
        }
    );
  }

  Widget _itemMessage(ChatMessage message){
    int index    = _chat.usersForRead.indexWhere((element) => element.uid == message.user.uid);
    int position = _activeMessages.indexOf(message);
    bool isMe    = message.user.uid == widget.me.uid;
    String audio = _chat.messagesForRead[position].audio;
    String link  = _chat.messagesForRead[position].link;
    bool hasFile = message.video != null || message.image != null || audio != null || link != null;

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: hasFile ? 1 : message.text.length > 100 ? 1 : 0.5,
          child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: message.user.containerColor,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Align(
                      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          message.user.name,
                          style: TextStyle(color: colors[_colorPositions[index]]),
                        ),
                      ),
                    ),
                    message.image != null
                        ? _photoView(message.image)
                        : message.video != null
                        ? _videoView(message.video)
                        : audio != null
                        ? _providerChat.audioViews[position.toString()] ?? _audioView(audio, position.toString())
                        : hasFile
                        ? _linkView(link)
                        : Container(),
                    Visibility(
                      visible: message.text.isNotEmpty,
                      child: Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                message.text,
                                style: TextStyle(color: Colors.white)
                              )
                          )
                      )
                    ),
                    Align(
                        alignment: isMe ? Alignment.bottomRight : Alignment.bottomLeft,
                        child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              message.createdAt.toString().substring(10, 19),
                              style: TextStyle(color: Colors.white70, fontSize: 10)
                            )
                        )
                    )
                  ]
              )
          )
        )
      )
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

  Widget _sendButton(send){
    return GestureDetector(
        onTap: (){
          if(_providerChat.hasText) _sendMessage();
          else playSound(soundRecording);
        },
        onLongPressStart: (view) async {
          if(!_providerChat.hasText){
            await playSound(soundRecording);
            await Future.delayed(Duration(milliseconds: 300));
            _isDeletedFile = false;
            _startPosition = view.globalPosition;
            Offset position = Offset(view.globalPosition.dx - 20, view.globalPosition.dy);
            _providerChat.voiceButtonPosition = position;
            _providerChat.isVoiceRecording = true;
            startRecordingVoice(context);
          }
        },
        onLongPressMoveUpdate: (view){
          if(!_providerChat.hasText && _startPosition != null){
            if(view.globalPosition.dx < _startPosition.dx - 20){
              if(view.globalPosition.dx > _startPosition.dx / 2) _providerChat.voiceButtonPosition = view.globalPosition;
              else {
                _isDeletedFile = true;
                _animationController.animateTo(1.0);
                playSound(soundDelete);
              }
            }
          }
        },
        onLongPressEnd: (view){
          if(!_providerChat.hasText){
            _providerChat.voiceButtonPosition = _startPosition;
            stopRecordingVoice(context).then((file){
              if(!_isDeletedFile && file != null && file.existsSync()){
                if(_providerChat.recording.duration >= Duration(seconds: 1)){
                  _file = file;
                  _sendMessage();
                }
              }
            });
          }
        },
        onLongPressUp: (){
          if(!_providerChat.hasText){
            if(!_animationController.isAnimating && _providerChat.isVoiceRecording) _providerChat.isVoiceRecording = false;
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Visibility(
            visible: !_providerChat.isVoiceRecording,
            child: CircleAvatar(
              maxRadius: _providerChat.isVoiceRecording ? 30 : 20,
              backgroundColor: _providerChat.hasText ? Colors.white : colorApp,
              child: Icon(
                  _providerChat.hasText ? Icons.send : Icons.keyboard_voice,
                  color: Colors.blue,
                  size: 25
              ),
            ),
          )
        )
    );
  }

  Widget _voiceInputView(){
    return Positioned(
      bottom: 0,
      child: Stack(
        children: <Widget>[
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
            child: Row(
              children: <Widget>[
                RotationTransition(
                  turns: _animationController,
                  child: Icon(Icons.delete_forever, color: Colors.red, size: 30)
                ),
                Text(
                    _providerChat.recording != null ? _providerChat.recording.duration.toString().substring(2, 7) : '00:00',
                    style: TextStyle(color: Colors.white)
                ),
                Spacer(),
                ColorizeAnimatedTextKit(
                  colors: [Colors.white24, Colors.white54, Colors.white70, Colors.white],
                  text: ['Slide to delete'],
                  repeatForever: true,
                  speed: Duration(milliseconds: 200),
                  textStyle: TextStyle(
                      fontSize: 15.0,
                      fontFamily: "Horizon"
                  )
                ),
                Spacer()
              ]
            )
          ),
          Positioned(
            bottom: 0,
            left: _providerChat.voiceButtonPosition.dx,
            child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CircleAvatar(
                    maxRadius: 20,
                    backgroundColor: colorApp,
                    child: Icon(
                        Icons.keyboard_voice,
                        color: Colors.blue,
                        size: 25
                    )
                )
            )
          )
        ]
      )
    );
  }

  Widget _photoView(String fileUrl){
    return GestureDetector(
      onTap: () => showImageDialog(context, fileUrl),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 250),
        child: CachedNetworkImage(
            imageUrl: fileUrl,
            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error, size: 30, color: Colors.white),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.none
        ),
      )
    );
  }

  Widget _videoView(String fileUrl){
    return AspectRatio(
        aspectRatio: 4 / 3,
        child: VideoView(url: fileUrl, file: null)
    );
  }

  Widget _audioView(String fileUrl, String position){
    return GestureDetector(
      onTap: (){
        _providerChat.audioViews.clear();
        _providerChat.addAudioView(position, Container(child: AudioView(url: fileUrl, audioKey: position), height: 60));
      },
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        child: Icon(Icons.music_note, color: Colors.pinkAccent, size: 30)
      )
    );
  }

  Widget _linkView(String link){
    return link.contains('youtu')
        ? _youtubeView(link)
        : Uri.parse(link).isAbsolute
        ? LinkPreviewer(link: link)
        : Container(child: Center(child: Text('Invalid link', style: TextStyle(color: Colors.white))));
  }

  Widget _youtubeView(String link){
    return AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubeView(url: link)
    );
  }

  Widget _chatFooter(){
    return !_providerChat.isLinkInsertMode ? Container() : Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Row(
          children: <Widget>[
            GestureDetector(
                onTap: () => _providerChat.isLinkInsertMode = false,
                child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                        padding: EdgeInsets.all(3),
                        child: Icon(Icons.close, color: Colors.white, size: 10),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blueGrey
                        )
                    )
                )
            ),
            Container(
                height: 30,
                padding: EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(30)
                ),
                child: Align(
                    alignment: Alignment.center,
                    child: Text(
                        'Insert Link'
                    )
                )
            )
          ]
      ),
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
        _colorPositions = [];
        _userCount = _chat.usersForRead.length;

        _chat.usersForRead.forEach((element){
          _colorPositions.add(element.color);
        });
      }
    }
  }

  Future<void>_sendMessage() async {
    playSound(soundSent);
    MessageDetail messageDetail = MessageDetail(
        uid:      widget.me.uid,
        date:     Timestamp.now(),
        message:  _providerChat.isLinkInsertMode ? '' : _controllerMessage.text.trim(),
        fullName: widget.me.fullName,
        userIcon: widget.me.imgProfile,
        audio:    await Storage.instance.uploadChatFile(_file, _chat.chatId, Fab.audio),
        link:     _providerChat.isLinkInsertMode ? _controllerMessage.text.trim() : null
    );

    _controllerMessage.clear();
    if(_providerChat.hasText) _providerChat.hasText = false;
    if(_providerChat.isLinkInsertMode) _providerChat.isLinkInsertMode = false;
    _chat.messagesForRead.add(messageDetail);
    _chat.messagesForWrite.add(messageDetail.toMap());
    _chat.senderFcmToken = widget.me.fcmToken;

    await Database.instance.updateChat(_chat, null);

    widget.receivers.forEach((user) async {
      if(user.deletedChats.contains(_chat.chatId)){
        await Database.instance.updateOtherUser(user..deletedChats.remove(_chat.chatId));
      }
    });
    _file = null;
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
    if(_chat.isGroup){
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
              value: 'takeImage',
              height: 65,
              child: Center(
                  child: CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.camera_alt, color: Colors.lightBlueAccent, size: 30)
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
                      child: Icon(Icons.video_library, color: Colors.pink, size: 30)
                  )
              )
          ),
          PopupMenuItem(
              value: 'takeVideo',
              height: 65,
              child: Center(
                  child: CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.videocam, color: Colors.pink, size: 30)
                  )
              )
          ),
          PopupMenuItem(
              value: 'link',
              height: 65,
              child: Center(
                  child: CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.link, color: Colors.green, size: 30)
                  )
              )
          )
        ]
    );
    _onPressedInsert(selected);
  }

  Future<void>_onPressedInsert(String value) async {
    _file = null;

    switch(value){
      case 'image':
        _file = await pickImage(false);
        _openFileView(Fab.photo);
        break;

      case 'takeImage':
        _file = await pickImage(true);
        _openFileView(Fab.photo);
        break;

      case 'video':
        _file = await pickVideo(false);
        _openFileView(Fab.video);
        break;

      case 'takeVideo':
        _file = await pickVideo(true);
        _openFileView(Fab.video);
        break;

      case 'link':
        _providerChat.isLinkInsertMode = true;
        break;
    }
  }

  void _openFileView(Fab fileType){
    if(_file != null){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => InsertFileView(chat: _chat, me: widget.me, file: _file, fileType: fileType)
          )
      );
    }
  }
}