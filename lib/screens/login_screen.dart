
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/services/auth_service.dart';
import '../components/custom_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: CustomButton(
          text: 'Sign in with Google',
          onPressed: () async {
            try {
              final user = await authService.signInWithGoogle();
              if (user != null && context.mounted) {
                context.go('/');
              } else if (user == null && context.mounted) {
                // Kullanıcı girişi iptal etti, sessizce devam et
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Giriş iptal edildi')),
                );
              }
            } catch (e) {
              // Hata durumunda kullanıcıya bildir
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Giriş hatası: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
