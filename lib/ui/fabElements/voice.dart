import 'dart:async';
import 'dart:io' as io;

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:provider/provider.dart';
import 'package:share_me/providers/providerFab.dart';
import 'package:share_me/utils/customValues.dart';
import 'package:file/local.dart';
import 'package:file/file.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecorder extends StatefulWidget {

  final LocalFileSystem localFileSystem;
  final isInsert;
  VoiceRecorder({localFileSystem, @required this.isInsert}) : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  _VoiceRecorderState createState() => _VoiceRecorderState();
}


class _VoiceRecorderState extends State<VoiceRecorder> with TickerProviderStateMixin {

  ProviderFab _providerFab;
  AudioPlayer _audioPlayer;
  var _positionSubscription, _audioPlayerStateSubscription;
  AnimationController _controller;
  List<Color>_colors;
  RecordingStatus _statusRecord = RecordingStatus.Unset;

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();
    _colors = [Colors.blue, Colors.red];
    _init();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: Duration(milliseconds: 1500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_){
      _providerFab.colorVoiceFab = _colors[0];
      _providerFab.voiceVolume   = 0;
    });
  }

  @override
  void dispose() {
    if(_audioPlayer.state == AudioPlayerState.PLAYING || _audioPlayer.state == AudioPlayerState.PAUSED){
      _audioPlayer.stop();
    }
    if(_statusRecord == RecordingStatus.Recording){
      _stop();
      _controller.stop();
      _controller.reset();
    }
    _controller.dispose();
    _positionSubscription?.cancel();
    _audioPlayerStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _providerFab = Provider.of<ProviderFab>(context);

    return Scaffold(
        backgroundColor: colorApp,
        body: _body()
    );
  }


  Widget _body(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buttonRecord(),
        _durationField(),
        _audioPlayerField(),
        _buttonPost()
      ]
    );
  }

  Widget _buttonRecord(){
    return Visibility(
      visible: widget.isInsert,
      child: Expanded(
        child: AnimatedBuilder(
          animation: CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                _buildContainerAnimation(50  * _controller.value),
                _buildContainerAnimation(70  * _controller.value),
                _buildContainerAnimation(90  * _controller.value),
                _buildContainerAnimation(110 * _controller.value),
                FloatingActionButton(
                  onPressed: _recordProcess,
                  child: Icon(Icons.keyboard_voice),
                  backgroundColor: _providerFab.colorVoiceFab,
                  elevation: 5,
                )
              ]
            );
          }
        )
      ),
    );
  }

  Widget _buildContainerAnimation(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withOpacity(1 - _controller.value),
      ),
    );
  }

  Widget _durationField(){
    return Visibility(
      visible: widget.isInsert,
      child: Text(
        _providerFab.current?.duration == null ? '00.00.00' : _providerFab.current?.duration.toString().substring(0, 7),
        style: TextStyle(
            fontSize: 14,
            color: Colors.white
        ),
      ),
    );
  }

  Widget _audioPlayerField(){
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: <Widget>[
          IgnorePointer(
            ignoring: false,
            child: Slider(
                value: _providerFab.voiceVolume,
                min: 0,
                max: _audioPlayer.duration.inSeconds.toDouble(),
                onChanged: (value){
                  _audioPlayer.seek(value);
                  _providerFab.voiceVolume = value;
                }
            ),
          ),
          Stack(
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        onPressed: onPlayAudio,
                        icon: Icon(_providerFab.iconPlayPause, color: Colors.white, size: 40)
                    ),
                    IconButton(
                        onPressed: () async => await _audioPlayer.stop(),
                        icon: Icon(Icons.stop, color: Colors.white, size: 40)
                    )
                  ]
              ),
              Visibility(
                visible: widget.isInsert,
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: (){
                        if(_statusRecord == RecordingStatus.Stopped && _audioPlayer.state != AudioPlayerState.PLAYING){
                          _init();
                          _providerFab.voiceVolume = 0;
                        }
                      },
                      icon: Icon(Icons.clear, color: Colors.white, size: 40)
                    )
                  ),
                ),
              )
            ]
          )
        ]
      ),
    );
  }

  Widget _buttonPost(){
    return Visibility(
      visible: widget.isInsert,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
        child: Container(
          width: double.infinity,
          child: RaisedButton(
            onPressed: (){
              print(_providerFab.current.path);
            },
            elevation: 5,
            child: Text(
              'Post',
              style: TextStyle(color: Colors.white),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)
            ),
            color: Colors.deepOrange,
          ),
        ),
      ),
    );
  }


  Future<void> _recordProcess() async {
    if(_audioPlayer.state != AudioPlayerState.PLAYING){
      switch(_statusRecord){
        case RecordingStatus.Initialized:
          _start();
          _providerFab.colorVoiceFab = _colors[1];
          _controller.repeat();
          break;

        case RecordingStatus.Recording:
          _stop();
          _providerFab.colorVoiceFab = _colors[0];
          _controller.stop();
          _controller.reset();
          break;

        case RecordingStatus.Stopped:
          _providerFab.colorVoiceFab = _colors[1];
          await _init();
          await _start();
          break;

        default: break;
      }
    }
  }

  Future<void>_init() async {
    try {
      if(await FlutterAudioRecorder.hasPermissions){
        String customPath = '/share_me_';
        io.Directory appDocDirectory;

        if(io.Platform.isIOS){
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path + customPath + DateTime.now().millisecondsSinceEpoch.toString();

        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _providerFab.recorder = FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);

        await _providerFab.recorder.initialized;
        // after initialization
        var current = await _providerFab.recorder.current(channel: 0);
        print(current);
        // should be "Initialized", if all working fine
        _providerFab.current = current;
        _statusRecord = current.status;
        print('----- $_statusRecord');
      } else Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("You must accept permissions")));
    } catch (e) {
      print(e);
    }
  }

  Future<void>_start() async {
    try {
      await _providerFab.recorder.start();
      var current = await _providerFab.recorder.current(channel: 0);
      _providerFab.current = current;

      const tick = const Duration(milliseconds: 50);
      new Timer.periodic(tick, (Timer t) async {
        if (_statusRecord == RecordingStatus.Stopped) {
          t.cancel();
        }

        var current = await _providerFab.recorder.current(channel: 0);
        // print(current.status);
        _providerFab.current = current;
        _statusRecord = _providerFab.current.status;
        print('----- $_statusRecord');
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void>_stop() async {
    var result = await _providerFab.recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    File file = widget.localFileSystem.file(result.path);
    print("File length: ${await file.length()}");
    _providerFab.current = result;
    _statusRecord = _providerFab.current.status;
    print('----- $_statusRecord');
  }

  void onPlayAudio() async {
    if(widget.isInsert){
      if(_statusRecord != RecordingStatus.Recording && io.File(_providerFab.current.path).existsSync()){
        if(_audioPlayer.state == AudioPlayerState.PLAYING){
          await _audioPlayer.pause();
        } else await _audioPlayer.play(_providerFab.current.path, isLocal: true);
      } else return;
    } else {
      if(_audioPlayer.state == AudioPlayerState.PLAYING){
        await _audioPlayer.pause();
      } else await _audioPlayer.play('https://mp3.big.az/demomp3/745172_3482622514.mp3', isLocal: false);
    }
    _positionSubscription = _audioPlayer.onAudioPositionChanged.listen((p) => _providerFab.voiceVolume = p.inSeconds.toDouble());

    _audioPlayerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((s){
      switch(s){
        case AudioPlayerState.PLAYING:
          _providerFab.iconPlayPause = Icons.pause;
          break;
        case AudioPlayerState.PAUSED:
          _providerFab.iconPlayPause = Icons.play_arrow;
          break;
        case AudioPlayerState.COMPLETED:
          _providerFab.iconPlayPause = Icons.play_arrow;
          break;
        case AudioPlayerState.STOPPED:
          _providerFab.voiceVolume = 0;
          _providerFab.iconPlayPause = Icons.play_arrow;
          break;
      }
    }, onError: (msg){
      _providerFab.voiceVolume = 0;
      _providerFab.iconPlayPause = Icons.play_arrow;
    });
  }
}