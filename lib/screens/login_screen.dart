
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
            final user = await authService.signInWithGoogle();
            if (user != null) {
              // ignore: use_build_context_synchronously
              context.go('/home');
            }
          },
        ),
      ),
    );
  }
}
