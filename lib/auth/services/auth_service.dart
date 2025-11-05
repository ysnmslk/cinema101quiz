
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signUpWithEmail(String email, String password);
  Future<User?> signInWithGoogle();
  Future<User?> signInAnonymously();
  Future<void> signOut();
}
