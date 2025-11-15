
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
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
    // Firebase Console'daki Web client ID
    const String webClientId = '633516057345-lhnu1p91f2bq8m0js3f69jlkmtu8e7mp.apps.googleusercontent.com';
    
    if (kIsWeb) {
      // Web'de Google Sign-In için openid scope'u ve clientId gerekli
      return GoogleSignIn(
        clientId: webClientId,
        scopes: ['email', 'profile', 'openid'],
      );
    } else {
      // Mobil için serverClientId kullanılıyor
      return GoogleSignIn(
        serverClientId: webClientId,
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
        
        GoogleSignInAccount? googleUser;
        
        // Web'de önce sessiz giriş denemesi yap
        try {
          googleUser = await _googleSignIn.signInSilently();
          if (googleUser != null) {
            developer.log('Sessiz giriş başarılı: ${googleUser.email}', name: 'FirebaseAuthService');
          }
        } catch (e) {
          developer.log('Sessiz giriş başarısız, normal giriş deneniyor: $e', name: 'FirebaseAuthService');
        }
        
        // Sessiz giriş başarısızsa normal giriş yap
        googleUser ??= await _googleSignIn.signIn();

        if (googleUser == null) {
          developer.log('Google Sign-In kullanıcı tarafından iptal edildi', name: 'FirebaseAuthService');
          return null;
        }

        developer.log('Google kullanıcı hesabı alındı: ${googleUser.email}', name: 'FirebaseAuthService');
        
        // Web'de authentication bilgilerini almak için biraz bekle
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Authentication bilgilerini al
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        developer.log('İlk deneme - idToken: ${googleAuth.idToken != null}, accessToken: ${googleAuth.accessToken != null}', name: 'FirebaseAuthService');
        
        // Eğer idToken hala null ise, tekrar dene
        if (googleAuth.idToken == null) {
          developer.log('idToken null, tekrar deneniyor...', name: 'FirebaseAuthService');
          await Future.delayed(const Duration(milliseconds: 1000));
          googleAuth = await googleUser.authentication;
          developer.log('İkinci deneme - idToken: ${googleAuth.idToken != null}, accessToken: ${googleAuth.accessToken != null}', name: 'FirebaseAuthService');
        }
        
        // Eğer hala idToken null ise, signOut yapıp tekrar signIn yap
        if (googleAuth.idToken == null) {
          developer.log('idToken hala null, signOut ve tekrar signIn yapılıyor...', name: 'FirebaseAuthService');
          await _googleSignIn.signOut();
          await Future.delayed(const Duration(milliseconds: 500));
          
          final retryUser = await _googleSignIn.signIn();
          if (retryUser != null) {
            await Future.delayed(const Duration(milliseconds: 1000));
            googleAuth = await retryUser.authentication;
            developer.log('Retry sonrası - idToken: ${googleAuth.idToken != null}, accessToken: ${googleAuth.accessToken != null}', name: 'FirebaseAuthService');
          }
        }

        // idToken gereklidir
        if (googleAuth.idToken == null) {
          developer.log('idToken hala null, giriş yapılamıyor', name: 'FirebaseAuthService');
          throw Exception('Google Sign-In: idToken alınamadı. Lütfen Firebase Console\'da Google Sign-In yapılandırmasını kontrol edin.');
        }

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        developer.log('Credential oluşturuldu, Firebase Auth ile giriş yapılıyor...', name: 'FirebaseAuthService');

        final userCredential = await _firebaseAuth.signInWithCredential(credential);
        
        developer.log('Firebase Auth ile başarıyla giriş yapıldı: ${userCredential.user?.email}', name: 'FirebaseAuthService');
        
        return userCredential.user;
      }
      
      // Mobil için google_sign_in paketini kullan
      developer.log('Mobil platformunda Google Sign-In başlatılıyor', name: 'FirebaseAuthService');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Kullanıcı giriş akışını iptal etti.
        developer.log('Google Sign-In kullanıcı tarafından iptal edildi', name: 'FirebaseAuthService');
        return null;
      }

      developer.log('Google kullanıcı hesabı alındı: ${googleUser.email}', name: 'FirebaseAuthService');
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      developer.log('Google authentication bilgileri alındı. idToken: ${googleAuth.idToken != null}, accessToken: ${googleAuth.accessToken != null}', name: 'FirebaseAuthService');

      // idToken gereklidir
      if (googleAuth.idToken == null) {
        developer.log('idToken null, giriş yapılamıyor', name: 'FirebaseAuthService');
        throw Exception('Google Sign-In: idToken alınamadı');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      developer.log('Credential oluşturuldu, Firebase Auth ile giriş yapılıyor...', name: 'FirebaseAuthService');

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      developer.log('Firebase Auth ile başarıyla giriş yapıldı: ${userCredential.user?.email}', name: 'FirebaseAuthService');
      
      return userCredential.user;

    } on FirebaseAuthException catch (e, s) {
      developer.log('Google ile giriş sırasında Firebase hatası', name: 'FirebaseAuthService', error: e, stackTrace: s);
      if (kIsWeb) {
        developer.log('Hata kodu: ${e.code}, Mesaj: ${e.message}', name: 'FirebaseAuthService');
        developer.log('Stack trace: $s', name: 'FirebaseAuthService');
      }
      // Hata mesajını fırlat ki login screen'de gösterilebilsin
      throw Exception('Firebase Auth hatası: ${e.message ?? e.code}');
    } catch (e, s) {
      developer.log('Google ile giriş sırasında genel hata', name: 'FirebaseAuthService', error: e, stackTrace: s);
      if (kIsWeb) {
        developer.log('Hata detayı: $e', name: 'FirebaseAuthService');
        developer.log('Stack trace: $s', name: 'FirebaseAuthService');
      }
      // Hata mesajını fırlat ki login screen'de gösterilebilsin
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
  Future<User?> createUserWithEmailAndPassword(String email, String password, {String? displayName}) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      
      var user = userCredential.user;
      if (user != null) {
        // DisplayName'i güncelle
        if (displayName != null && displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
          await user.reload();
          user = _firebaseAuth.currentUser; // Güncellenmiş kullanıcıyı al
        }
        
        // Firestore'a kullanıcı bilgilerini kaydet
        await _saveUserToFirestore(user!, displayName ?? '');
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      if (kIsWeb) {
        developer.log('Kayıt hatası: ${e.code} - ${e.message}', name: 'FirebaseAuthService');
      }
      // Hata mesajını fırlat ki login screen'de gösterilebilsin
      throw Exception(_getSignUpErrorMessage(e.code));
    } catch (e) {
      if (kIsWeb) {
        developer.log('Kayıt genel hatası: $e', name: 'FirebaseAuthService');
      }
      rethrow;
    }
  }
  
  Future<void> _saveUserToFirestore(User user, String displayName) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('1users').doc(user.uid).set({
        'displayName': displayName.isNotEmpty ? displayName : user.email?.split('@')[0] ?? 'Kullanıcı',
        'email': user.email,
        'firstLogin': FieldValue.serverTimestamp(),
        'level_title': 'acemi',
      }, SetOptions(merge: true));
      
      developer.log('Kullanıcı Firestore\'a kaydedildi: ${user.uid}', name: 'FirebaseAuthService');
    } catch (e) {
      developer.log('Firestore\'a kullanıcı kaydedilirken hata: $e', name: 'FirebaseAuthService');
      // Firestore hatası kullanıcı kaydını engellemez, sadece loglarız
    }
  }

  String _getSignUpErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
      case 'email-already-in-use':
        return 'Bu email adresi zaten kullanılıyor.';
      case 'invalid-email':
        return 'Geçersiz email adresi.';
      case 'operation-not-allowed':
        return 'Email/şifre ile kayıt etkin değil.';
      default:
        return 'Kayıt yapılamadı. Lütfen tekrar deneyin.';
    }
  }

  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (kIsWeb) {
        developer.log('Email/Şifre ile giriş hatası: ${e.code} - ${e.message}', name: 'FirebaseAuthService');
      }
      // Hata mesajını fırlat ki login screen'de gösterilebilsin
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      if (kIsWeb) {
        developer.log('Email/Şifre ile giriş genel hatası: $e', name: 'FirebaseAuthService');
      }
      rethrow;
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bu email adresi ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Şifre hatalı.';
      case 'invalid-email':
        return 'Geçersiz email adresi.';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
      case 'operation-not-allowed':
        return 'Email/şifre ile giriş etkin değil.';
      default:
        return 'Giriş yapılamadı. Lütfen tekrar deneyin.';
    }
  }

  @override
  Stream<User?> get userStream => _firebaseAuth.authStateChanges();
}
