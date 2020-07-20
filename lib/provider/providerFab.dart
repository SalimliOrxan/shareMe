import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';

class ProviderFab with ChangeNotifier {

  FlutterAudioRecorder _recorder;
  Recording _current;
  Color _colorVoiceFab;
  double _voiceVolume = 0;
  IconData _iconPlayPause = Icons.play_arrow;

  File _file;



  FlutterAudioRecorder get recorder => _recorder;

  set recorder(FlutterAudioRecorder value) {
    _recorder = value;
    notifyListeners();
  }


  Recording get current => _current;

  set current(Recording value) {
    _current = value;
    notifyListeners();
  }


  Color get colorVoiceFab => _colorVoiceFab;

  set colorVoiceFab(Color value) {
    _colorVoiceFab = value;
    notifyListeners();
  }


  double get voiceVolume => _voiceVolume;

  set voiceVolume(double value) {
    _voiceVolume = value;
    notifyListeners();
  }


  IconData get iconPlayPause => _iconPlayPause;

  set iconPlayPause(IconData value) {
    _iconPlayPause = value;
    notifyListeners();
  }


  File get file => _file;

  set file(File value) {
    _file = value;
    notifyListeners();
  }
}