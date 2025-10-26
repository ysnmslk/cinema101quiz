
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) {
          setState(() {
            _isSigningIn = false;
          });
        }
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Kullanıcı bilgilerini Firestore'a kaydet
        final usersCollection = FirebaseFirestore.instance.collection('1users');
        final userDoc = usersCollection.doc(user.uid);

        final userData = {
          'uid': user.uid,
          'displayName': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
          'lastLogin': FieldValue.serverTimestamp(),
        };

        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          // Yeni kullanıcı, varsayılan alanları ekle
          userData['createdAt'] = FieldValue.serverTimestamp();
          userData['firstLogin'] = FieldValue.serverTimestamp(); 
          userData['level_title'] = 'Yeni Üye'; 
          userData['total_score'] = 0; 
        }

        await userDoc.set(userData, SetOptions(merge: true));
      }

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Giriş hatası: ${e.message}")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Beklenmedik bir hata oluştu: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
      ),
      body: Center(
        child: _isSigningIn
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Uygulamaya Hoş Geldiniz',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: const Icon(Icons.login),
                    label: const Text('Google ile Giriş Yap'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      minimumSize: const Size(250, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
