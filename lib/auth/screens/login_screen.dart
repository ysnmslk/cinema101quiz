
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myapp/auth/services/auth_service.dart'; // AuthService importu


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                'Uygulamaya Hoş Geldiniz',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Başlamak için lütfen giriş yapın.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
                label: const Text('Google ile Giriş Yap'),
                onPressed: () {
                  // Butona basıldığında giriş işlemini başlat
                  authService.signInWithGoogle();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // Butonun genişliğini ayarla
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
