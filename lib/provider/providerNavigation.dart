import 'package:flutter/cupertino.dart';

class ProviderNavigation with ChangeNotifier {

  int _positionPage      = 0;
  bool _isVerified       = false;
  String _status         = 'Verification email has been sent';
  String _time           = '60';
  bool _visibleButton    = true;
  bool _isFcmInitialised = false;



  int get positionPage => _positionPage;

  set positionPage(int value) {
    _positionPage = value;
    notifyListeners();
  }


  bool get isVerified => _isVerified;

  set isVerified(bool value) {
    _isVerified = value;
    notifyListeners();
  }


  String get status => _status;

  set status(String value) {
    _status = value;
    notifyListeners();
  }


  String get time => _time;

  set time(String value) {
    _time = value;
    notifyListeners();
  }


  bool get visibleButton => _visibleButton;

  set visibleButton(bool value) {
    _visibleButton = value;
    notifyListeners();
  }


  bool get isFcmInitialised => _isFcmInitialised;

  set isFcmInitialised(bool value) {
    _isFcmInitialised = value;
    notifyListeners();
  }
}