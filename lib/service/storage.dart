import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:share_me/model/post.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/auth.dart';
import 'package:share_me/service/database.dart';
import 'package:path/path.dart' as path;
import 'package:share_me/ui/navigation/home/navigationHomePage.dart';

class Storage {

  Storage._privateConstructor();
  static final Storage instance = Storage._privateConstructor();

  final StorageReference _storage = FirebaseStorage.instance.ref();
  StorageTaskSnapshot _downloadUrl;
  StorageUploadTask _uploadTask;


  Future<bool> uploadUserImages(User user, File cover, File profile) async {
    user.uid = Auth.instance.uid;
    bool access = await Auth.instance.hasAccess(user.password);
    if(access){
      if(cover != null){
        _uploadTask     = _storage.child('images/imgCover').child('${user.uid}${path.extension(cover.path)}').putFile(cover);
        _downloadUrl    = await _uploadTask.onComplete;
        user.imgCover   = await _downloadUrl.ref.getDownloadURL();
      }
      if(profile != null){
        _uploadTask     = _storage.child('images/imgProfile').child('${user.uid}${path.extension(profile.path)}').putFile(profile);
        _downloadUrl    = await _uploadTask.onComplete;
        user.imgProfile = await _downloadUrl.ref.getDownloadURL();
      }
      await Database.instance.updateUserData(user);
    }
    return access;
  }

  Future<void> uploadPostFile(Post post, File file) async {
    if(file != null){
      String fileType = post.fileType;
      Fab type = Fab.values.firstWhere((e) => e.toString() == fileType);

      switch(type){
        case Fab.audio:
          _uploadTask = _storage.child('audio/audioPost/${post.postId}').child('${post.fileName}').putFile(file);
          break;
        case Fab.video:
          _uploadTask = _storage.child('video/videoPost/${post.postId}').child('${post.fileName}').putFile(file);
          break;
        case Fab.photo:
          _uploadTask = _storage.child('images/imgPost/${post.postId}').child('${post.fileName}').putFile(file);
          break;
        case Fab.location:
          break;
        case Fab.link:
          break;
        case Fab.snippet:
          break;
      }

      post.fileName   = 'postFile${path.extension(file.path)}';
      _downloadUrl    = await _uploadTask.onComplete;
      post.fileUrl    = await _downloadUrl.ref.getDownloadURL();
    }
  }

  Future<void> deletePostFile(Post post) async {
    await _storage.child('images/imgPost').child('${post.postId}/${post.fileName}').delete();
  }
}