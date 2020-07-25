import 'package:flutter/cupertino.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/auth.dart';
import 'package:share_me/service/database.dart';

class ProviderSearch with ChangeNotifier {

  List<User>_users = [];
  bool _statusSearch = false;
  bool _statusFollow = false;
  String _keySearch;



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


  String get keySearch => _keySearch;

  set keySearch(String value) {
    _keySearch = value;
    notifyListeners();
  }




  Future<void>followOperations(User me, User requestedUser) async {
    bool isFollowingDone      = requestedUser.friends.contains(Auth.instance.uid);
    bool isFollowingRequested = requestedUser.followRequests.contains(Auth.instance.uid);

    if(isFollowingDone){
      // stop following
      statusFollow = true;
      requestedUser.friends.remove(Auth.instance.uid);
      await Database.instance.updateOtherUser(requestedUser);
      me.friends.remove(requestedUser.uid);
      await Database.instance.updateUserData(me);
      statusFollow = false;
    } else {
      if(isFollowingRequested){
        // remove sending following request
        statusFollow = true;
        requestedUser.countNotification--;
        requestedUser.followRequests.remove(Auth.instance.uid);
        await Database.instance.updateOtherUser(requestedUser);
        statusFollow = false;
      } else {
        // send following request
        statusFollow = true;
        requestedUser.countNotification++;
        requestedUser.followRequests.add(Auth.instance.uid);
        await Database.instance.updateOtherUser(requestedUser);
        statusFollow = false;
      }
    }
  }

  Future<void>acceptRequest(User me, User requestedUser) async {
    statusFollow = true;
    // add me his friend list
    requestedUser.friends.add(Auth.instance.uid);
    // add him my friend list
    me.friends.add(requestedUser.uid);
    // remove follow request my follow list
    me.followRequests.remove(requestedUser.uid);
    // decrease count notification
    me.countNotification--;
    // update me
    await Database.instance.updateUserData(me);
    // update him
    await Database.instance.updateOtherUser(requestedUser);
    statusFollow = false;
  }

  Future<void>declineRequest(User me, User requestedUser) async {
    statusFollow = true;
    // remove follow request my follow list
    me.followRequests.remove(requestedUser.uid);
    // decrease count notification
    me.countNotification--;
    // update me
    await Database.instance.updateUserData(me);
    statusFollow = false;
  }
}