
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Paketler google_sign_in: 6.2.1 ve uyumlu firebase versiyonlarına düşürüldü.
  // Bu versiyon için Android'de 'serverClientId' hala gereklidir.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
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
      // google_sign_in: 6.2.1 versiyonu için doğru metot .signIn() metodudur.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Kullanıcı giriş akışını iptal etti.
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Bu versiyon için kimlik bilgisi hem accessToken hem de idToken gerektirir.
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
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
