import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/model/comment.dart';
import 'package:share_me/model/post.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/provider/providerFab.dart';
import 'package:share_me/service/database.dart';
import 'package:share_me/ui/navigation/home/navigationHomePage.dart';
import 'package:share_me/ui/navigation/home/videoView.dart';

enum FileFormat{IMAGE, VIDEO, VIDEO_RECORD}

class ImageOrVideo extends StatefulWidget {

  final ScrollController controller;
  ImageOrVideo({@required this.controller});

  @override
  _ImageOrVideoState createState() => _ImageOrVideoState();
}


class _ImageOrVideoState extends State<ImageOrVideo> {

  ProviderFab _providerFab;
  List<User>_friendsData;
  User _me;
  TextEditingController _controllerTitle;
  FileFormat _fileFormat;

  @override
  void initState() {
    super.initState();
    _fileFormat = FileFormat.IMAGE;
    _controllerTitle = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _providerFab.file = null);
  }

  @override
  void dispose() {
    _controllerTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _providerFab = Provider.of<ProviderFab>(context);
    _friendsData = Provider.of<List<User>>(context);
    _me          = Provider.of<User>(context);

    return Scaffold(
        backgroundColor: colorApp,
        body: _body()
    );
  }


  Widget _body(){
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: SingleChildScrollView(
        controller: widget.controller,
        child: Column(
            children: <Widget>[
              _titleField(),
              _fileContainer(),
              _pickButtons(),
              _postButton()
            ]
        )
      )
    );
  }

  Widget _titleField(){
    return Container(
      padding: EdgeInsets.only(top: 2),
      child: TextFormField(
          controller: _controllerTitle,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                      color: Colors.blueGrey
                  )
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              )
          ),
          minLines: 1,
          maxLines: 3,
          keyboardType: TextInputType.multiline
      ),
    );
  }

  Widget _fileContainer(){
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.transparent
            ),
            child: _providerFab.file == null
                ? Icon(Icons.image, size: 250, color: Colors.blueGrey)
                : _fileFormat == FileFormat.IMAGE
                ? ClipRRect(child: Image.file(_providerFab.file, fit: BoxFit.cover), borderRadius: BorderRadius.circular(5))
                : ClipRRect(borderRadius: BorderRadius.circular(5), child: VideoView(url: null, file: _providerFab.file))
        ),
      )
    );
  }

  Widget _pickButtons(){
    return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                IconButton(
                    onPressed: () async {
                      final file = await pickImage(false);
                      if(file != null){
                        _fileFormat = FileFormat.IMAGE;
                        _providerFab.file = file;
                      }
                    },
                    icon: Icon(Icons.image, size: 35, color: Colors.white)
                ),
                IconButton(
                    onPressed: () async {
                      final file = await pickImage(true);
                      if(file != null){
                        _fileFormat = FileFormat.IMAGE;
                        _providerFab.file = file;
                      }
                    },
                    icon: Icon(Icons.camera_alt, size: 35, color: Colors.white)
                )
              ]
            ),
            IconButton(
                onPressed: _deleteFile,
                icon: Icon(Icons.delete, size: 35, color: Colors.white)
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                    onPressed: () async {
                      _deleteFile();
                      final file = await pickVideo(false);
                      if(file != null){
                        _fileFormat = FileFormat.VIDEO;
                        _providerFab.file = file;
                      }
                    },
                    icon: Icon(Icons.video_library, size: 35, color: Colors.white)
                ),
                IconButton(
                    onPressed: () async {
                      _deleteFile();
                      final file = await pickVideo(true);
                      if(file != null){
                        _fileFormat = FileFormat.VIDEO_RECORD;
                        _providerFab.file = file;
                      }
                    },
                    icon: Icon(Icons.videocam, size: 35, color: Colors.white)
                )
              ]
            )
          ]
        )
    );
  }

  Widget _postButton(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        width: double.infinity,
        child: RaisedButton(
          onPressed: _post,
          color: Colors.deepOrange,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)
          ),
          child: Text(
            'Post',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }



  void _post() async {
    showLoading(context);

    Post newPost = Post();
    newPost.uid      = _me.uid;
    newPost.fullName = _me.fullName;
    newPost.userImg  = _me.imgProfile;
    newPost.title    = _controllerTitle.text.trim();
    newPost.fileType = _fileFormat == FileFormat.IMAGE ? Fab.photo.toString() : Fab.video.toString();

    String postId = await Database.instance.createPost(newPost, _providerFab.file);
    await Database.instance.createComments(Comment()..commentId = postId);
    await Database.instance.updateUserData(_me..posts.add(postId));

    Navigator.pop(context);
    Navigator.pop(context);

    for(int i=0; i<_me.friends.length; i++){
      _friendsData[i].posts.add(postId);
      await Database.instance.updateOtherUser(_friendsData[i]);
    }
  }

  void _deleteFile(){
    _fileFormat = FileFormat.IMAGE;
    _providerFab.file = null;
  }
}