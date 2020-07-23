import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/auth.dart';

class Database {

  Database._privateConstructor();
  static final Database instance = Database._privateConstructor();

  final CollectionReference _collectionUsers  = Firestore.instance.collection('users');
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

  Stream<List<User>>usersByUid(List followingRequests){
    return _collectionUsers.snapshots().map((event){
      return event.documents.where((doc) => followingRequests.contains(doc.documentID)).map((doc){
        return User.fromMap(doc)..uid = doc.documentID;
      }).toList();
    });
  }

  Stream<User>get currentUserData{
    _currentUserRef = _collectionUsers.document(Auth.instance.uid);
    return _currentUserRef.snapshots().map((data) => User.fromMap(data));
  }

  Stream<List<User>>searchedUsers(String word){
    var strFrontCode = word.substring(0, word.length - 1);
    var strEndCode   = word.substring(word.length - 1, word.length);
    var endCode      = strFrontCode + String.fromCharCode(strEndCode.codeUnitAt(0) + 1);

    return _collectionUsers.where('fullName', isGreaterThanOrEqualTo: word).where('fullName', isLessThan: endCode)
        .snapshots()
        .map((event){
      return event.documents.where((doc) => doc.documentID != Auth.instance.uid).map((doc){
        return User.fromMap(doc)..uid = doc.documentID;
      }).toList();
    });
  }
}