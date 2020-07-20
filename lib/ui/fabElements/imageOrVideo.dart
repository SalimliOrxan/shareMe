import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/helper/customValues.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/provider/providerFab.dart';
import 'package:video_player/video_player.dart';

enum FileFormat{IMAGE, VIDEO, VIDEO_RECORD}

class ImageOrVideo extends StatefulWidget {

  @override
  _ImageOrVideoState createState() => _ImageOrVideoState();
}


class _ImageOrVideoState extends State<ImageOrVideo> {

  ProviderFab _providerFab;
  TextEditingController _controllerTitle;
  FileFormat _fileFormat;
  FlickManager flickManager;

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
    flickManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _providerFab = Provider.of<ProviderFab>(context);
    _initFlickManager();

    return Scaffold(
        backgroundColor: colorApp,
        body: _body()
    );
  }


  Widget _body(){
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18.0),
      child: Column(
          children: <Widget>[
            _titleField(),
            _fileContainer(),
            _pickButtons(),
            _postButton()
          ]
      ),
    );
  }

  Widget _titleField(){
    return TextFormField(
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
    );
  }

  Widget _fileContainer(){
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.transparent
          ),
          child: _providerFab.file == null
              ? Icon(Icons.image, size: 250, color: Colors.blueGrey)
              : _fileFormat == FileFormat.IMAGE
              ? ClipRRect(child: Image.file(_providerFab.file, fit: BoxFit.cover), borderRadius: BorderRadius.circular(5))
              : ClipRRect(child: FlickVideoPlayer(flickManager: flickManager), borderRadius: BorderRadius.circular(5))
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
                    icon: Icon(Icons.image, size: 20, color: Colors.white)
                ),
                IconButton(
                    onPressed: () async {
                      final file = await pickImage(true);
                      if(file != null){
                        _fileFormat = FileFormat.IMAGE;
                        _providerFab.file = file;
                      }
                    },
                    icon: Icon(Icons.camera_alt, size: 20, color: Colors.white)
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                    onPressed: () async {
                      final file = await pickVideo(false);
                      if(file != null){
                        _fileFormat = FileFormat.VIDEO;
                        _providerFab.file = file;
                      }
                    },
                    icon: Icon(Icons.video_library, size: 20, color: Colors.white)
                ),
                IconButton(
                    onPressed: () async {
                      final file = await pickVideo(true);
                      if(file != null){
                        _fileFormat = FileFormat.VIDEO_RECORD;
                        _providerFab.file = file;
                      }
                    },
                    icon: Icon(Icons.videocam, size: 20, color: Colors.white)
                ),
              ],
            )
          ],
        )
    );
  }

  Widget _postButton(){
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        width: double.infinity,
        child: RaisedButton(
          onPressed: post,
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



  void _initFlickManager(){
    if(_fileFormat == FileFormat.VIDEO){
      flickManager = FlickManager(videoPlayerController: VideoPlayerController.file(_providerFab.file), autoPlay: false);
    }
  }

  void post(){

  }
}