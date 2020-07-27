import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_me/model/post.dart';
import 'package:share_me/model/targetUser.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/auth.dart';

class Database {

  Database._privateConstructor();
  static final Database instance = Database._privateConstructor();

  final CollectionReference _collectionUsers = Firestore.instance.collection('users');
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
    return await userRef.updateData(user.toMap());
  }

  Future<void>createPost(Post post) async {
    DocumentReference userRef = _collectionUsers.document(Auth.instance.uid).collection('posts').document();
    post.postId = userRef.documentID;
    return await userRef.setData(post.toMap());
  }

  Future<void>updatePost(Post post) async {
    DocumentReference userRef = _collectionUsers.document(Auth.instance.uid).collection('posts').document(post.postId);
    return await userRef.updateData(post.toMap());
  }

  Stream<TargetUser>userById(String uid){
    DocumentReference userRef = _collectionUsers.document(uid);
    return userRef.snapshots().map((event) => TargetUser.fromMap(event));
  }

  Stream<List<User>>usersByUid(List followingRequests){
    return _collectionUsers.snapshots().map((event){
      return event.documents.where((doc) => followingRequests.contains(doc.documentID)).map((doc){
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

  Stream<List<Post>>get myFriends{
    return _collectionUsers
        .document(Auth.instance.uid)
        .collection('posts')
        .snapshots()
        .map((posts) => posts.documents.map((post) => Post.fromMap(post.data)).toList());
  }
}