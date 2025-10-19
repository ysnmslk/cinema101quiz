
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/login/providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Uygulamaya Hoş Geldiniz',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                // HATA DÜZELTİLDİ: AppAuthProvider kullanılıyor
                final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
                authProvider.signInWithGoogle();
              },
              icon: Image.asset(
                'assets/images/google_logo.png', // Bu dosyanın assets/images altına eklenmesi gerekiyor
                height: 24.0,
              ),
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
