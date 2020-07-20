import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/auth.dart';

class Database {

  Database._privateConstructor();
  static final Database instance = Database._privateConstructor();

  final CollectionReference _userCollection = Firestore.instance.collection('users');
  DocumentReference _currentUserRef;



  Future<void>createUserData(User user) async {
    return await _currentUserRef.setData(user.toMap());
  }

  Future<void>updateUserData(User user) async {
    return await _currentUserRef.updateData(user.toMap());
  }


  User _userFromSnapshot(DocumentSnapshot snapshot){
    return User.fromMap(snapshot);
  }

  Stream<User>get currentUserData{
    _currentUserRef = _userCollection.document(Auth.instance.uid);
    return _currentUserRef.snapshots().map(_userFromSnapshot);
  }


//  List<User>_userListFromSnapshot(QuerySnapshot snapshot){
//    return snapshot.documents.map((doc){
//      return User(
//          uid:     doc.data['uid'] ?? '',
//          name:    doc.data['name'] ?? '',
//          surname: doc.data['surname'] ?? '',
//          email:   doc.data['email'] ?? ''
//      );
//    }).toList();
//  }
//
//  Stream<List<User>>get usersData{
//    return userCollection.snapshots().map(_userListFromSnapshot);
//  }
}