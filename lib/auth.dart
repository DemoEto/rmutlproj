import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get AuthStateChanges => _firebaseAuth.authStateChanges();
  
  // Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    }) async {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  }

  // Register with email and password
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    }) async {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
