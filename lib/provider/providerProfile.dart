import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/storage.dart';

class ProviderProfile with ChangeNotifier {

  File _imgCover;
  File _imgProfile;



  File get imgCover => _imgCover;

  set imgCover(File value) {
    _imgCover = value;
    notifyListeners();
  }


  File get imgProfile => _imgProfile;

  set imgProfile(File value) {
    _imgProfile = value;
    notifyListeners();
  }


  Future<void> updateUserData(GlobalKey<ScaffoldState> key, User user) async {
    showLoading(key.currentState.context);
    bool completed = await Storage.instance.uploadUserImages(user, imgCover, imgProfile);
    if(completed){
      Navigator.pop(key.currentState.context);
      Navigator.pop(key.currentState.context);
      showSnackBar(key, 'Saved successfully', true);
    } else Navigator.pop(key.currentState.context);
  }
}