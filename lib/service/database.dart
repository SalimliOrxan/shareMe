import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_me/model/comment.dart';
import 'package:share_me/model/message.dart';
import 'package:share_me/model/post.dart';
import 'package:share_me/model/targetUser.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/auth.dart';
import 'package:share_me/service/storage.dart';

class Database {

  Database._privateConstructor();
  static final Database instance = Database._privateConstructor();

  final CollectionReference _collectionUsers    = Firestore.instance.collection('users');
  final CollectionReference _collectionPosts    = Firestore.instance.collection('posts');
  final CollectionReference _collectionComments = Firestore.instance.collection('comments');
  final CollectionReference _collectionChat     = Firestore.instance.collection('chat');
  DocumentReference _currentUserRef;




  Future<void>createUserData(User user) async {
    _currentUserRef = _collectionUsers.document(user.uid);
    return await _currentUserRef.setData(user.toMap());
  }

  Future<void>updateUserData(User user) async {
    return await _currentUserRef.updateData(user.toMap());
  }

  Future<void>updateOtherUser(User user) async {
    DocumentReference userRef = _collectionUsers.document(user.uid);
    return await userRef.updateData(user.toMap()..removeWhere((key, value) => value == null));
  }

  Future<String>createPost(Post post, File file) async {
    DocumentReference docRef = _collectionPosts.document();
    post.postId = docRef.documentID;
    await Storage.instance.uploadPostFile(post, file);
    await docRef.setData(post.toMap());
    return post.postId;
  }

  Future<void>updatePost(Post post) async {
    DocumentReference docRef = _collectionPosts.document(post.postId);
    return await docRef.updateData(post.toMap());
  }

  Future<void>deletePostById(Post post) async {
    DocumentReference postRef = _collectionPosts.document(post.postId);
    await postRef.delete();

    DocumentReference commentRef = _collectionComments.document(post.postId);
    await commentRef.delete();
    await Storage.instance.deletePostFile(post);
  }

  Future<void>createComments(Comment comment) async {
    DocumentReference docRef = _collectionComments.document(comment.commentId);
    return await docRef.setData(comment.toMap());
  }

  Future<void>updateComments(Comment comment) async {
    DocumentReference docRef = _collectionComments.document(comment.commentId);
    return await docRef.updateData(comment.toMap());
  }

  Future<String>createChat(Message chat, File groupIcon) async {
    DocumentReference docRef = _collectionChat.document();
    chat.chatId = docRef.documentID;
    await Storage.instance.uploadGroupIcon(groupIcon, chat);
    await docRef.setData(chat.toMap());
    return chat.chatId;
  }

  Future<void>updateChat(Message chat, File groupIcon) async {
    DocumentReference docRef = _collectionChat.document(chat.chatId);
    await Storage.instance.uploadGroupIcon(groupIcon, chat);
    await docRef.updateData(chat.toMap());
  }

  Future<void>deleteChat(Message chat) async {
    DocumentReference docRef = _collectionChat.document(chat.chatId);
    await docRef.delete();
  }


  Stream<TargetUser>userById(String uid){
    DocumentReference userRef = _collectionUsers.document(uid);
    return userRef.snapshots().map((event) => TargetUser.fromMap(event));
  }

  Stream<List<User>>usersByUid(List uIds){
    return _collectionUsers.snapshots().map((event){
      return event.documents.where((doc) => uIds.contains(doc.documentID)).map((doc){
        return User.fromMap(doc);
      }).toList();
    });
  }

  Stream<User>get currentUserData{
    _currentUserRef = _collectionUsers.document(Auth.instance.uid);
    return _currentUserRef.snapshots().map((data) => User.fromMap(data));
  }

  Stream<List<User>>searchedUsers(String word){
    word = word.toLowerCase();

    return _collectionUsers.where('searchKeys', arrayContains: word)
        .snapshots()
        .map((event){
      return event.documents.where((doc) => doc.documentID != Auth.instance.uid).map((doc){
        return User.fromMap(doc);
      }).toList();
    });
  }

  Stream<List<Post>>getPosts(List idPosts){
    return _collectionPosts.snapshots().map((event){
      return event.documents.where((doc) => idPosts.contains(doc.documentID)).map((doc){
        return Post.fromMap(doc.data);
      }).toList();
    });
  }

  Stream<Post>getPostById(String id){
    return _collectionPosts
        .document(id)
        .snapshots()
        .map((post) => Post.fromMap(post.data));
  }

  Stream<Comment>getComments(String idPost){
    return _collectionComments
        .document(idPost)
        .snapshots()
        .map((comment) => Comment.fromMap(comment.data));
  }

  Stream<List<Message>>getChats(List idChats){
    return _collectionChat.snapshots().map((event){
      return event.documents.where((doc) => idChats.contains(doc.documentID)).map((doc){
        return Message.fromMap(doc.data);
      }).toList();
    });
  }

  Stream<Message>getChatById(String id){
    return _collectionChat
        .document(id)
        .snapshots()
        .map((chat) => Message.fromMap(chat.data));
  }
}