
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/login/providers/auth_provider.dart';
import 'package:myapp/login/screens/login_screen.dart';
import 'package:myapp/home/screens/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // KULLANIM GÜNCELLENDİ
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);

    return StreamBuilder<User?>(
      stream: authProvider.authStateChanges, // Oturum durumunu dinle
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
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
