import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository{
  const AuthRepository(this._auth);
  final FirebaseAuth _auth;

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get authStateChange => _auth.idTokenChanges();

  Future<void> signUpWithEmailAndPassword(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw FirebaseAuthException(code: e.code, message: 'Weak Password, Use a stronger Password');
      } else if (e.code == 'email-already-in-use') {
        throw FirebaseAuthException(code: e.code, message: 'Email already in use');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<User?> signInWithEmailAndPassword(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailAddress,
          password: password
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw FirebaseAuthException(message: 'User not found', code: e.code);
      } else if (e.code == 'wrong-password') {
        throw FirebaseAuthException(message: 'Wrong Password', code: e.code);
      }
    }
    return null;
  }
}