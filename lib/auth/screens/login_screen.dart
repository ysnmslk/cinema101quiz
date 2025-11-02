
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/auth/services/auth_service.dart'; // Sadece auth_service'i import ediyoruz.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  // DÜZELTME: Bu metot artık doğrudan AuthService'i çağıracak.
  void _login(Future<void> Function() loginMethod) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      await loginMethod();
      // Başarılı girişten sonra navigasyon, AuthWrapper tarafından yönetilecek.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giriş başarısız oldu: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // DÜZELTME: AuthService'i Provider ile alıyoruz.
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const FlutterLogo(size: 100),
              const SizedBox(height: 48.0),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.g_mobiledata), // Google ikonu
                      // DÜZELTME: AuthService'deki doğru metodu çağırıyoruz.
                      onPressed: () => _login(authService.signInWithGoogle),
                      label: const Text('Google ile Giriş Yap'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_outline),
                      // DÜZELTME: AuthService'deki doğru metodu çağırıyoruz.
                      onPressed: () => _login(authService.signInAnonymously),
                      label: const Text('Anonim Olarak Devam Et'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
