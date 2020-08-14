import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:share_me/model/user.dart';

class ProviderChat with ChangeNotifier {
  List<int>_selectedChatUserPositions = [];
  List<User>_friendsIsNotInChat = [];
  File _groupIcon;
  bool _isEditable = false;
  bool _isGroup = false;

  bool _hasText = false;
  bool _isVoiceRecording = false;
  Offset _voiceButtonPosition;
  Recording _recording;
  double _voicePosition = 0;
  IconData _icon = Icons.play_arrow;
  Map<String, Widget>_audioViews = Map();




  List<int> get selectedChatUserPositions => _selectedChatUserPositions;

  set selectedChatUserPositions(List<int> value) {
    _selectedChatUserPositions = value;
    notifyListeners();
  }


  List<User> get friendsIsNotInChat => _friendsIsNotInChat;

  set friendsIsNotInChat(List<User> value) {
    _friendsIsNotInChat = value;
    notifyListeners();
  }


  File get groupIcon => _groupIcon;

  set groupIcon(File value) {
    _groupIcon = value;
    notifyListeners();
  }


  bool get isEditable => _isEditable;

  set isEditable(bool value) {
    _isEditable = value;
    notifyListeners();
  }


  bool get isGroup => _isGroup;

  set isGroup(bool value) {
    _isGroup = value;
    notifyListeners();
  }


  bool get hasText => _hasText;

  set hasText(bool value) {
    _hasText = value;
    notifyListeners();
  }


  bool get isVoiceRecording => _isVoiceRecording;

  set isVoiceRecording(bool value) {
    _isVoiceRecording = value;
    notifyListeners();
  }


  Offset get voiceButtonPosition => _voiceButtonPosition;

  set voiceButtonPosition(Offset value) {
    _voiceButtonPosition = value;
    notifyListeners();
  }


  Recording get recording => _recording;

  set recording(Recording value) {
    _recording = value;
    notifyListeners();
  }


  double get voicePosition => _voicePosition;

  set voicePosition(double value) {
    _voicePosition = value;
    notifyListeners();
  }


  IconData get icon => _icon;

  set icon(IconData value) {
    _icon = value;
    notifyListeners();
  }


  Map<String, Widget> get audioViews => _audioViews;

  set audioViews(Map<String, Widget> value) {
    _audioViews = value;
    notifyListeners();
  }





  void addSelectedChatUserPositions(int value) {
    _selectedChatUserPositions.add(value);
    notifyListeners();
  }

  void removeSelectedChatUserPositions(int value) {
    _selectedChatUserPositions.remove(value);
    notifyListeners();
  }

  void addAudioView(String key, Widget value) {
    _audioViews[key] = value;
    notifyListeners();
  }

  void clearAll(){
    _groupIcon = null;
    _isEditable = false;
    _isGroup = false;
  }

  void clearAudioDetails(String key){
    _voicePosition = 0;
    _icon = Icons.play_arrow;
    _audioViews[key] = null;
  }
}