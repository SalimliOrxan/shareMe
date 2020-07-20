import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/model/user.dart';
import 'package:share_me/service/database.dart';

class Auth {

  Auth._privateConstructor();

  static final Auth instance = Auth._privateConstructor();
  final FirebaseAuth _auth   = FirebaseAuth.instance;
  final _logger = Logger();

  String uid;


  User _userFromFirebase(FirebaseUser user){
    return user != null ? User(uid: user.uid, isEmailVerified: user.isEmailVerified) : null;
  }

  Stream<User>get user{
    return _auth.onAuthStateChanged.map(_userFromFirebase);
  }

  Future<User> register(String email, String password) async {
    try {
      AuthResult authResult     = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser firebaseUser = authResult.user;
      await firebaseUser.sendEmailVerification();
      await Database.instance.createUserData(_userFromFirebase(firebaseUser));
      return _userFromFirebase(authResult.user);
    } catch(e) {
      _logger.v(e);
      showToast(e.message, true);
      return null;
    }
  }

  Future<User> login(String email, String password) async {
    try {
      AuthResult authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _userFromFirebase(authResult.user);
    } catch(e) {
      _logger.v(e);
      showToast(e.message, true);
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      showToast('email has been sent successfully', false);
    } catch(e) {
      _logger.v(e);
      showToast(e.message, true);
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch(e) {
      _logger.v(e);
      showToast(e.message, true);
    }
  }
}