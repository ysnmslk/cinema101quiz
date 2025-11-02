
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  // DOKÜMANTASYONA DAYALI KESİN VE NİHAİ ÇÖZÜM
  Future<User?> signInWithGoogle() async {
    try {
      // HATA DÜZELTİLDİ: Metot .authenticate() olarak değiştirildi ve singleton instance kullanıldı.
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();

      if (googleUser == null) {
        // Kullanıcı akışı iptal etti
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // HATA DÜZELTİLDİ: Sadece idToken kullanılarak kimlik bilgisi oluşturuldu.
      final AuthCredential credential = GoogleAuthProvider.credential(
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
      // HATA DÜZELTİLDİ: Singleton instance kullanıldı.
      await GoogleSignIn.instance.signOut();
      await _auth.signOut();
    } catch (e, s) {
      developer.log('Oturum kapatma hatası', name: 'AuthService', error: e, stackTrace: s);
    }
  }
}
