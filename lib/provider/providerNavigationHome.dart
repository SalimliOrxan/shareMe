import 'package:flutter/cupertino.dart';

class ProviderNavigationHome with ChangeNotifier {

  List<bool> _visibilityReplies = [];
  bool _hasText       = false;
  bool _keyboardState = false;
  bool _dialVisible   = true;
  int _maxLines = 5;



  List<bool> get visibilityReplies => _visibilityReplies;

  set visibilityReplies(List<bool> value) {
    _visibilityReplies = value;
    notifyListeners();
  }


  bool get hasText => _hasText;

  set hasText(bool value) {
    _hasText = value;
    notifyListeners();
  }


  bool get keyboardState => _keyboardState;

  set keyboardState(bool value) {
    _keyboardState = value;
    notifyListeners();
  }


  bool get dialVisible => _dialVisible;

  set dialVisible(bool value) {
    _dialVisible = value;
    notifyListeners();
  }


  int get maxLines => _maxLines;

  set maxLines(int value) {
    _maxLines = value;
    notifyListeners();
  }
}