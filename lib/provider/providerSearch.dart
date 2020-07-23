import 'package:flutter/cupertino.dart';
import 'package:share_me/model/user.dart';

class ProviderSearch with ChangeNotifier {

  List<User>_users = [];
  bool _statusSearch = false;
  bool _statusFollow = false;



  List<User> get users => _users;

  set users(List<User> value) {
    _users = value;
    notifyListeners();
  }


  bool get statusSearch => _statusSearch;

  set statusSearch(bool value) {
    _statusSearch = value;
    notifyListeners();
  }


  bool get statusFollow => _statusFollow;

  set statusFollow(bool value) {
    _statusFollow = value;
    notifyListeners();
  }
}