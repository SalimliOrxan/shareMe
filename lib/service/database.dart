import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_me/model/fullNameModel.dart';
import 'package:share_me/model/groupModel.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/auth.dart';

class Database {

  Database._privateConstructor();
  static final Database instance = Database._privateConstructor();

  final CollectionReference _collectionUsers  = Firestore.instance.collection('users');
  final CollectionReference _collectionSearch = Firestore.instance.collection('search');
  DocumentReference _currentUserRef;



  Future<void>createUserData(User user) async {
    _currentUserRef = _collectionUsers.document(user.uid);
    return await _currentUserRef.setData(user.toMap());
  }

  Future<void>updateUserData(User user) async {
    return await _currentUserRef.updateData(user.toMap());
  }

  Stream<User>get currentUserData{
    _currentUserRef = _collectionUsers.document(Auth.instance.uid);
    return _currentUserRef.snapshots().map((data) => User.fromMap(data));
  }

  Stream<FullNameData>get fullNameDataInSearch{
    DocumentReference docFullName = _collectionSearch.document('fullName');
    return docFullName.snapshots().map((data) => FullNameData.fromMap(data));
  }

  Stream<GroupData>get groupDataInSearch{
    DocumentReference docGroup = _collectionSearch.document('group');
    return docGroup.snapshots().map((data) => GroupData.fromMap(data));
  }

  Future<List<User>>get searchedUsers async {
    List<User>users = [];
    await _collectionUsers.snapshots().firstWhere((element){
      element.documents.forEach((element){
        if(element.documentID == 'wme25DqO13QB4Bi9Nm5RxCwb8u62'){
          users.add(User.fromMap(element));
        }
      });
      return true;
    });
    return users;
  }
}