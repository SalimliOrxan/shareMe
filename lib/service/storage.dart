import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/database.dart';
import 'package:path/path.dart' as path;

class Storage {

  Storage._privateConstructor();
  static final Storage instance = Storage._privateConstructor();

  final StorageReference _storage = FirebaseStorage.instance.ref();
  StorageTaskSnapshot _downloadUrl;
  StorageUploadTask _uploadTask;


  Future<void> uploadImageCover(User user, File file) async {
    _uploadTask   = _storage.child('images/imgCover').child('cover${path.extension(file.path)}').putFile(file);
    _downloadUrl  = await _uploadTask.onComplete;
    user.imgCover = await _downloadUrl.ref.getDownloadURL();
    Database.instance.updateUserData(user);
  }

  Future<void> uploadImageProfile(User user, File file) async {
    _uploadTask     = _storage.child('images/imgProfile').child('profile${path.extension(file.path)}').putFile(file);
    _downloadUrl    = await _uploadTask.onComplete;
    user.imgProfile = await _downloadUrl.ref.getDownloadURL();
    Database.instance.updateUserData(user);
  }
}