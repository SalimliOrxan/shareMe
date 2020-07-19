import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:share_me/helper/utils.dart';
import 'package:share_me/models/user.dart';

class Auth {

  Auth._privateConstructor();

  static final Auth instance = Auth._privateConstructor();
  final FirebaseAuth auth    = FirebaseAuth.instance;
  final _logger = Logger();


  User _userFromFirebase(FirebaseUser user){
    return user != null ? User(uid: user.uid, isEmailVerified: user.isEmailVerified) : null;
  }

  Stream<User>get user{
    return auth.onAuthStateChanged.map(_userFromFirebase);
  }

  Future<User> register(String email, String password) async {
    try {
      AuthResult authResult = await auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user     = authResult.user;
      await user.sendEmailVerification();
      return _userFromFirebase(authResult.user);
    } catch(e) {
      _logger.v(e);
      showToast(e.message, true);
      return null;
    }
  }

  Future<User> login(String email, String password) async {
    try {
      AuthResult authResult = await auth.signInWithEmailAndPassword(email: email, password: password);
      return _userFromFirebase(authResult.user);
    } catch(e) {
      _logger.v(e);
      showToast(e.message, true);
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      showToast('email has been sent successfully', false);
    } catch(e) {
      _logger.v(e);
      showToast(e.message, true);
    }
  }

  Future<void> logout() async {
    try {
      await auth.signOut();
    } catch(e) {
      _logger.v(e);
      showToast(e.message, true);
    }
  }
}