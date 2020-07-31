import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {

  final url;
  final file;
  VideoView({@required this.url, @required this.file});

  @override
  _VideoViewState createState() => _VideoViewState();
}


class _VideoViewState extends State<VideoView> {

  ChewieController _chewieController;
  VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();

    _videoPlayerController = widget.file == null ? VideoPlayerController.network(widget.url) : VideoPlayerController.file(widget.file);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 4 / 3,
      autoPlay: false,
      autoInitialize: true,
      allowedScreenSleep: false
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Chewie(controller: _chewieController)
      )
    );
  }
}