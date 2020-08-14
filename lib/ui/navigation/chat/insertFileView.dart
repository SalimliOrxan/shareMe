import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_me/model/messageDetail.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/service/storage.dart';
import 'package:share_me/ui/navigation/home/navigationHomePage.dart';
import 'package:share_me/ui/navigation/home/videoView.dart';

class InsertFileView extends StatefulWidget {

  final chat;
  final me;
  final file;
  final fileType;
  InsertFileView({@required this.chat, @required this.me, @required this.file, @required this.fileType});

  @override
  _InsertFileState createState() => _InsertFileState();
}


class _InsertFileState extends State<InsertFileView> {

  TextEditingController _controllerMessage;

  @override
  void initState() {
    _controllerMessage = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controllerMessage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: _appBar(),
        body: _body()
    );
  }


  Widget _appBar(){
    return AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        actionsIconTheme: IconThemeData(color: Colors.white)
    );
  }

  Widget _body(){
    return Stack(
        children: <Widget>[
          widget.fileType == Fab.photo ? _photoView() : _videoView(),
          _messageField()
        ]
    );
  }

  Widget _photoView(){
    return Center(
        child: PhotoView(
          imageProvider: FileImage(widget.file),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.contained * 2,
        )
    );
  }

  Widget _videoView(){
    return Center(
      child: AspectRatio(
          aspectRatio: 4 / 3,
          child: VideoView(url: null, file: widget.file)
      ),
    );
  }

  Widget _messageField(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: TextFormField(
              controller: _controllerMessage,
              minLines: 1,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  labelText: 'Message',
                  labelStyle: TextStyle(color: Colors.greenAccent, fontSize: 12),
                  contentPadding: EdgeInsets.only(left: 10, right: 10),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                      onPressed: _sendMessage,
                      icon: Icon(Icons.send, color: Colors.greenAccent)
                  )
              )
          )
      )
    );
  }


  Future<void>_sendMessage() async {
    Navigator.pop(context);
    String urlFile = await Storage.instance.uploadChatFile(widget.file, widget.chat.chatId, widget.fileType);

    MessageDetail messageDetail = MessageDetail(
        uid:      widget.me.uid,
        date:     Timestamp.now(),
        message:  _controllerMessage.text.trim(),
        fullName: widget.me.fullName,
        userIcon: widget.me.imgProfile,
        img:      widget.fileType == Fab.photo ? urlFile : null,
        video:    widget.fileType == Fab.video ? urlFile : null
    );

    widget.chat.messagesForRead.add(messageDetail);
    widget.chat.messagesForWrite.add(messageDetail.toMap());
    widget.chat.senderFcmToken = widget.me.fcmToken;

    await Database.instance.updateChat(widget.chat, null);
  }
}