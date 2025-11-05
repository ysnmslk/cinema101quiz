
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Web ve mobil için platform-specific yapılandırma
  // Web'de Google Sign-In için sadece clientId gereklidir
  // Android için serverClientId gereklidir
  final GoogleSignIn _googleSignIn = kIsWeb
      ? GoogleSignIn(
          // Web için sadece clientId kullanılır (serverClientId kullanılmaz)
          clientId: '633516057345-lhnu1p91f2bq8m0js3f69jlkmtu8e7mp.apps.googleusercontent.com',
          scopes: ['email', 'profile'],
        )
      : GoogleSignIn(
          // Android için serverClientId kullanılır
          serverClientId: '633516057345-lhnu1p91f2bq8m0js3f69jlkmtu8e7mp.apps.googleusercontent.com',
        );

  Stream<User?> get userStream => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } on FirebaseAuthException catch (e, s) {
      developer.log('Anonim giriş hatası', name: 'AuthService', error: e, stackTrace: s);
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        developer.log('Web platformunda Google Sign-In başlatılıyor', name: 'AuthService');
      }
      
      // google_sign_in: 6.2.1 versiyonu için doğru metot .signIn() metodudur.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Kullanıcı giriş akışını iptal etti.
        developer.log('Google Sign-In kullanıcı tarafından iptal edildi', name: 'AuthService');
        return null;
      }

      if (kIsWeb) {
        developer.log('Google kullanıcı hesabı alındı: ${googleUser.email}', name: 'AuthService');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (kIsWeb) {
        developer.log('Google authentication bilgileri alındı. accessToken: ${googleAuth.accessToken != null}, idToken: ${googleAuth.idToken != null}', name: 'AuthService');
      }

      // Web için idToken gereklidir, Android için hem accessToken hem idToken gerekir
      if (googleAuth.idToken == null) {
        developer.log('Google idToken alınamadı', name: 'AuthService');
        throw Exception('Google Sign-In: idToken alınamadı');
      }

      // Bu versiyon için kimlik bilgisi hem accessToken hem de idToken gerektirir.
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (kIsWeb) {
        developer.log('Firebase Auth ile başarıyla giriş yapıldı: ${userCredential.user?.email}', name: 'AuthService');
      }
      
      return userCredential.user;

    } on FirebaseAuthException catch (e, s) {
      developer.log('Google ile giriş sırasında Firebase hatası', name: 'AuthService', error: e, stackTrace: s);
      rethrow; 
    } catch (e, s) {
      developer.log('Google ile giriş sırasında genel hata', name: 'AuthService', error: e, stackTrace: s);
      rethrow; 
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e, s) {
      developer.log('E-posta ile giriş hatası', name: 'AuthService', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e, s) {
      developer.log('Kullanıcı oluşturma hatası', name: 'AuthService', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e, s) {
      developer.log('Oturum kapatma hatası', name: 'AuthService', error: e, stackTrace: s);
    }
  }
}
