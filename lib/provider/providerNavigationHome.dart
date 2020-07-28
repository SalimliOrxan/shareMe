import 'package:flutter/cupertino.dart';
import 'package:share_me/model/commentDetail.dart';

class ProviderNavigationHome with ChangeNotifier {

  List<bool> _visibilityReplies = [];
  List<CommentDetail>_comments  = [];
  bool _hasText                 = false;
  bool _keyboardState           = false;
  bool _dialVisible             = true;
  int _maxLines                 = 5;
  String _replyTag              = '';



  List<bool> get visibilityReplies => _visibilityReplies;

  set visibilityReplies(List<bool> value) {
    _visibilityReplies = value;
    notifyListeners();
  }


  List<CommentDetail> get comments => _comments;

  set comments(List<CommentDetail> value) {
    _comments = value;
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


  String get replyTag => _replyTag;

  set replyTag(String value) {
    _replyTag = value;
    notifyListeners();
  }
}