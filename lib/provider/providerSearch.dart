import 'package:flutter/cupertino.dart';
import 'package:share_me/model/user.dart';

class ProviderSearch with ChangeNotifier {

  List<String>_uids  = [];
  List<User>_users = [];



  List<String> get uids => _uids;

  set uids(List<String> value) {
    _uids = value;
    notifyListeners();
  }


  List<User> get users => _users;

  set users(List<User> value) {
    _users = value;
    notifyListeners();
  }
}