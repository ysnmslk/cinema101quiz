
import 'package:flutter/foundation.dart'; // kIsWeb için eklendi
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;

class AppAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  User? get user => _user;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    // --- GELİŞTİRME ORTAMI ÇÖZÜMÜ ---
    // Eğer uygulama web üzerinde (Firebase Studio'da) çalışıyorsa, Google Sign-In
    // penceresi düzgün çalışmayacağı için anonim giriş yap.
    if (kIsWeb) {
      try {
        developer.log('Web ortamında anonim giriş yapılıyor...', name: 'AppAuthProvider');
        final UserCredential userCredential = await _auth.signInAnonymously();
        _user = userCredential.user;
        developer.log('Anonim giriş başarılı: ${_user?.uid}', name: 'AppAuthProvider');
        notifyListeners();
        return _user;
      } catch (e, s) {
        developer.log('Anonim giriş sırasında hata!', name: 'AppAuthProvider.Web', error: e, stackTrace: s);
        return null;
      }
    }
    // --- Gerçek Cihaz (Android vb.) için Standart Akış ---
    else {
      try {
        developer.log('Google ile giriş denemesi başlatıldı...', name: 'AppAuthProvider');
        
        final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();

        if (googleUser == null) {
          developer.log('Kullanıcı Google girişini iptal etti.', name: 'AppAuthProvider');
          return null;
        }

        developer.log('Google kullanıcısı başarıyla alındı: ${googleUser.displayName}', name: 'AppAuthProvider');

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        developer.log('Google kimlik doğrulaması başarıyla alındı.', name: 'AppAuthProvider');

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        developer.log('Firebase kimlik bilgisi oluşturuldu.', name: 'AppAuthProvider');

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        _user = userCredential.user;

        developer.log('Firebase ile giriş başarıyla tamamlandı: ${_user?.displayName}', name: 'AppAuthProvider');

        notifyListeners();
        return _user;

      } on FirebaseAuthException catch (e, s) {
          developer.log(
            'Firebase Kimlik Doğrulama Hatası!', 
            name: 'AppAuthProvider.FirebaseAuth',
            error: e,
            stackTrace: s,
          );
          return null;
      } catch (e, s) {
        developer.log(
          'Google ile Giriş sırasında beklenmedik bir hata oluştu!', 
          name: 'AppAuthProvider.General',
          error: e,
          stackTrace: s,
        );
        return null;
      }
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
