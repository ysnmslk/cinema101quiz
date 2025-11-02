import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // HATA 1 & 2 ÇÖZÜMÜ:
  // 'serverClientId' parametresi web içindir. Mobil platformlarda
  // GoogleSignIn() yapıcısı parametresiz çağrılmalıdır.
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get userStream => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } on FirebaseAuthException catch (e, s) {
      developer.log('Anonim giriş hatası', name: 'AuthService', error: e, stackTrace: s);
      // UI katmanının hatayı yönetebilmesi için rethrow eklemeyi düşünebilirsiniz.
      rethrow; 
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Hata 2 (signIn) artık çözülmüş olmalı.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Kullanıcı giriş akışını iptal etti.
        return null;
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // HATA 3 ÇÖZÜMÜ:
      // google_sign_in v6+ (ve 7.x) 'de token'lar nullable (String?) tipindedir.
      // Firebase'e göndermeden önce null kontrolü yapılmalıdır.
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        // Token alınamazsa hata fırlat.
        developer.log('Google auth tokens are null', name: 'AuthService');
        throw FirebaseAuthException(
          code: 'google-sign-in-token-null',
          message: 'Google authentication tokens are null.',
        );
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken, // Artık null değil
        idToken: idToken,     // Artık null değil
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;

    } on FirebaseAuthException catch (e, s) {
      developer.log('Google ile giriş sırasında Firebase hatası', name: 'AuthService', error: e, stackTrace: s);
      rethrow; // Hatayı UI katmanının işlemesi için yeniden fırlat.
    } catch (e, s) {
      developer.log('Google ile giriş sırasında genel hata', name: 'AuthService', error: e, stackTrace: s);
      rethrow; // Hatayı UI katmanının işlemesi için yeniden fırlat.
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
      // Farklı hesap seçimine izin vermek için Google'dan da çıkış yap.
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e, s) {
      developer.log('Oturum kapatma hatası', name: 'AuthService', error: e, stackTrace: s);
    }
  }
}