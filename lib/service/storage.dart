import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/auth.dart';
import 'package:share_me/service/database.dart';
import 'package:path/path.dart' as path;

class Storage {

  Storage._privateConstructor();
  static final Storage instance = Storage._privateConstructor();

  final StorageReference _storage = FirebaseStorage.instance.ref();
  StorageTaskSnapshot _downloadUrl;
  StorageUploadTask _uploadTask;


  Future<bool> updateUserData(User user, File cover, File profile) async {
    bool access = await Auth.instance.hasAccess(user.password);
    if(access){
      if(cover != null){
        _uploadTask     = _storage.child('images/imgCover').child('cover${path.extension(cover.path)}').putFile(cover);
        _downloadUrl    = await _uploadTask.onComplete;
        user.imgCover   = await _downloadUrl.ref.getDownloadURL();
      }
      if(profile != null){
        _uploadTask     = _storage.child('images/imgProfile').child('profile${path.extension(profile.path)}').putFile(profile);
        _downloadUrl    = await _uploadTask.onComplete;
        user.imgProfile = await _downloadUrl.ref.getDownloadURL();
      }
      await Database.instance.updateUserData(user);
    }
    return access;
  }
}