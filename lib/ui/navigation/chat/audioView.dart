import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_me/provider/providerChat.dart';

class AudioView extends StatefulWidget {

  final url;
  final audioKey;
  AudioView({@required this.url, @required this.audioKey});

  @override
  _AudioState createState() => _AudioState();
}


class _AudioState extends State<AudioView> {

  ProviderChat _providerChat;
  AudioPlayer _audioPlayer;
  var _positionSubscription, _audioPlayerStateSubscription;

  @override
  void initState() {
    _audioPlayer = AudioPlayer();
    super.initState();
  }

  @override
  void dispose() {
    if(_audioPlayer.state == AudioPlayerState.PLAYING || _audioPlayer.state == AudioPlayerState.PAUSED){
      _audioPlayer.stop();
    }
    _positionSubscription?.cancel();
    _audioPlayerStateSubscription?.cancel();
    _providerChat.clearAudioDetails(widget.audioKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _providerChat = Provider.of(context);

    return Scaffold(
        body: _body()
    );
  }


  Widget _body(){
    return Container(
        height: 60,
        width: double.infinity,
        child: Column(
            children: <Widget>[
              Row(
                  children: <Widget>[
                    IconButton(
                        onPressed: playAudio,
                        icon: Icon(_providerChat.icon, color: Colors.lightGreenAccent, size: 30)
                    ),
                    Slider(
                        value: _providerChat.voicePosition,
                        min: 0,
                        max: _audioPlayer.duration.inSeconds.toDouble(),
                        onChanged: (value){
                          _audioPlayer.seek(value);
                          _providerChat.voicePosition = value;
                        }
                    )
                  ]
              ),
              Padding(
                padding: const EdgeInsets.only(left: 63, right: 40),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                          Duration(seconds: _providerChat.voicePosition.toInt()).toString().substring(2, 7),
                          style: TextStyle(color: Colors.white, fontSize: 10)
                      ),
                      Text(
                          _audioPlayer.duration.toString().substring(2, 7),
                          style: TextStyle(color: Colors.white, fontSize: 10)
                      )
                    ]
                )
              )
            ]
        )
    );
  }


  void playAudio() async {
    if(_audioPlayer.state == AudioPlayerState.PLAYING){
      await _audioPlayer.pause();
    } else await _audioPlayer.play(widget.url, isLocal: false);

    _positionSubscription = _audioPlayer.onAudioPositionChanged.listen((p) => _providerChat.voicePosition = p.inSeconds.toDouble());

    _audioPlayerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((s){
      switch(s){
        case AudioPlayerState.PLAYING:
          _providerChat.icon = Icons.pause;
          break;
        case AudioPlayerState.PAUSED:
          _providerChat.icon = Icons.play_arrow;
          break;
        case AudioPlayerState.COMPLETED:
          _providerChat.icon = Icons.play_arrow;
          break;
        case AudioPlayerState.STOPPED:
          _providerChat.icon = Icons.play_arrow;
          _providerChat.voicePosition = 0;
          break;
      }
    }, onError: (msg){
      _providerChat.icon = Icons.play_arrow;
      _providerChat.voicePosition = 0;
    });
  }
}