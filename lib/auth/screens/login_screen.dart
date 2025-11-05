
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/common/widgets/custom_button.dart';
import 'package:myapp/common/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(Future<void> Function() loginMethod) async {
    try {
      await loginMethod();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(controller: _emailController, hintText: 'Email'),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              hintText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 32),
            CustomButton(
              onPressed: () => _login(() => authService.signInWithEmail(
                    _emailController.text,
                    _passwordController.text,
                  )),
              text: 'Sign In with Email',
            ),
            const SizedBox(height: 16),
            CustomButton(
              onPressed: () => authService.signInWithGoogle(),
              text: 'Sign In with Google',
            ),
            const SizedBox(height: 16),
            CustomButton(
              onPressed: () => authService.signInAnonymously(),
              text: 'Sign In Anonymously',
            ),
          ],
        ), 
      ),
    );
  }
}
