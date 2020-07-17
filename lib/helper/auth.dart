import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:share_me/helper/utils.dart';

class Auth {

  Auth._privateConstructor();

  static final Auth instance = Auth._privateConstructor();
  final FirebaseAuth _auth   = FirebaseAuth.instance;
  final _logger = Logger();


  Future<FirebaseUser> register(String email, String password) async {
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user     = authResult.user;
      await user.sendEmailVerification();
      showToast('Verification email has been sent', false);
      return authResult.user;
    } catch(e) {
      _logger.v(e);
      showToast(e.message, true);
      return null;
    }
  }

  Future<FirebaseUser> login(String email, String password) async {
    try {
      AuthResult authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return authResult.user;
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
      await FirebaseAuth.instance.signOut();
    } catch(e) {
      _logger.v(e);
      showToast(e.message, true);
    }
  }
}