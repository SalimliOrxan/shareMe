import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeView extends StatefulWidget {

  final url;
  YoutubeView({@required this.url});

  @override
  _YoutubeViewState createState() => _YoutubeViewState();
}


class _YoutubeViewState extends State<YoutubeView> {

  YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(widget.url),
        flags: YoutubePlayerFlags(autoPlay: false)
    );
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: YoutubePlayer(controller: _controller)
        )
    );
  }
}