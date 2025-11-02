
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/auth/screens/login_screen.dart';
import 'package:myapp/home/screens/main_screen.dart'; // MainScreen'e yönlendir

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginScreen();
        }
        // Kullanıcı giriş yapmışsa, artık BottomNavBar içeren MainScreen'i göster.
        return const MainScreen(); 
      },
    );
  }
}
