import 'package:firebase_auth/firebase_auth.dart';

/// Abstract interface for authentication services
abstract class AuthService {
  /// Stream of authentication state changes
  Stream<User?> get userStream;
  
  /// Current authenticated user
  User? get currentUser;
  
  /// Sign in anonymously
  Future<User?> signInAnonymously();
  
  /// Sign in with Google
  Future<User?> signInWithGoogle();
  
  /// Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password);
  
  /// Create a new user with email and password
  Future<User?> createUserWithEmailAndPassword(String email, String password);
  
  /// Sign out the current user
  Future<void> signOut();
}
