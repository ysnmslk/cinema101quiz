
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/auth/screens/login_screen.dart';
import 'package:myapp/home/screens/home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Kullanıcı oturum açmış
        if (snapshot.hasData) {
          return const HomeScreen(); // Ana ekrana yönlendir
        }
        // Kullanıcı oturum açmamış
        else {
          return const LoginScreen(); // Giriş ekranına yönlendir
        }
      },
    );
  }
}
