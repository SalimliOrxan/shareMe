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
    return user != null ? User(uid: user.uid, email: user.email, isEmailVerified: user.isEmailVerified) : null;
  }

  Stream<User>get user{
    return _auth.onAuthStateChanged.map(_userFromFirebase);
  }

  Future<User> register(User user) async {
    try {
      AuthResult authResult     = await _auth.createUserWithEmailAndPassword(email: user.email, password: user.password);
      FirebaseUser firebaseUser = authResult.user;
      await firebaseUser.sendEmailVerification();
      user.uid = firebaseUser.uid;
      await Database.instance.createUserData(user);
      return _userFromFirebase(firebaseUser);
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
      showToast('Email has been sent successfully', false);
    } catch(e) {
      _logger.v(e);
      showToast(e.message, true);
    }
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    try {
      bool access = await hasAccess(oldPassword);
      if(access){
        FirebaseUser user = await _auth.currentUser();
        await user.updatePassword(newPassword);
        showToast('Password has been updated successfully', false);
      }
    } catch(e) {
      _logger.v(e);
      showToast(e.message, true);
    }
  }

  Future<void> updateEmail(String email, String password) async {
    try {
      bool access = await hasAccess(password);
      if(access){
        FirebaseUser user = await _auth.currentUser();
        await user.updateEmail(email);
        showToast('Email has been updated successfully', false);
      }
    } catch(e) {
      _logger.v(e);
      showToast(e.message, true);
    }
  }

  Future<bool> hasAccess(String password) async {
    try {
      FirebaseUser user = await _auth.currentUser();
      AuthCredential credential = EmailAuthProvider.getCredential(
        email: user.email,
        password: password,
      );
      AuthResult authResult = await user.reauthenticateWithCredential(credential);
      return authResult != null;
    } catch(e) {
      _logger.v(e);
      showToast(e.message, true);
      return false;
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