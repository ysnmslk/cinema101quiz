
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/login_screen.dart';
import '../../home/screens/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Doğrudan FirebaseAuth'dan dinle
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          // Kullanıcı giriş yapmışsa ana ekrana yönlendir
          return const HomeScreen();
        } else {
          // Kullanıcı giriş yapmamışsa giriş ekranını göster
          return const LoginScreen();
        }
      },
    );
  }
}
