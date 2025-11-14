
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myapp/auth/services/auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;
  
  // Web ve mobil için platform-specific yapılandırma
  // Google Sign-In 7.2.0+ için constructor parametreleri gerekli
  late final GoogleSignIn _googleSignIn = _createGoogleSignIn();

  FirebaseAuthService({FirebaseAuth? auth}) : _firebaseAuth = auth ?? FirebaseAuth.instance;
  
  GoogleSignIn _createGoogleSignIn() {
    if (kIsWeb) {
      return GoogleSignIn(
        clientId: '633516057345-lhnu1p91f2bq8m0js3f69jlkmtu8e7mp.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
    } else {
      return GoogleSignIn(
        serverClientId: '633516057345-lhnu1p91f2bq8m0js3f69jlkmtu8e7mp.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
    }
  }

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException {
      return null;
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        developer.log('Web platformunda Google Sign-In başlatılıyor', name: 'FirebaseAuthService');
      }
      
      // google_sign_in: 6.2.1 versiyonu için doğru metot .signIn() metodudur.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Kullanıcı giriş akışını iptal etti.
        developer.log('Google Sign-In kullanıcı tarafından iptal edildi', name: 'FirebaseAuthService');
        return null;
      }

      if (kIsWeb) {
        developer.log('Google kullanıcı hesabı alındı: ${googleUser.email}', name: 'FirebaseAuthService');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (kIsWeb) {
        developer.log('Google authentication bilgileri alındı. idToken: ${googleAuth.idToken != null}', name: 'FirebaseAuthService');
      }

      // idToken gereklidir
      if (googleAuth.idToken == null) {
        developer.log('Google idToken alınamadı', name: 'FirebaseAuthService');
        throw Exception('Google Sign-In: idToken alınamadı');
      }

      // Google Sign-In 7.0+ versiyonlarında accessToken kaldırılmıştır
      // Firebase Auth için sadece idToken yeterlidir
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (kIsWeb) {
        developer.log('Firebase Auth ile başarıyla giriş yapıldı: ${userCredential.user?.email}', name: 'FirebaseAuthService');
      }
      
      return userCredential.user;

    } on FirebaseAuthException catch (e, s) {
      developer.log('Google ile giriş sırasında Firebase hatası', name: 'FirebaseAuthService', error: e, stackTrace: s);
      rethrow; 
    } catch (e, s) {
      developer.log('Google ile giriş sırasında genel hata', name: 'FirebaseAuthService', error: e, stackTrace: s);
      rethrow; 
    }
  }

  @override
  Future<User?> signInAnonymously() async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInAnonymously();
      return userCredential.user;
    } on FirebaseAuthException {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException {
      return null;
    }
  }

  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException {
      return null;
    }
  }

  @override
  Stream<User?> get userStream => _firebaseAuth.authStateChanges();
}
