
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/services/auth_service.dart';
import '../components/custom_button.dart';
import '../common/widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUpMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen email ve şifre girin.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (user != null) {
          context.go('/');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email veya şifre hatalı. Lütfen tekrar deneyin.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        String errorMessage = 'Giriş yapılamadı. Lütfen tekrar deneyin.';
        if (e is Exception) {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        } else {
          errorMessage = e.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _signUpWithEmail() async {
    // Validasyonlar
    if (_displayNameController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen kullanıcı adınızı girin.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen email ve şifre girin.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (_passwordController.text.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şifre en az 6 karakter olmalıdır.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Şifre doğrulama kontrolü
    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şifreleriniz eşleşmiyor.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        displayName: _displayNameController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kayıt başarılı! Hoş geldiniz.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          context.go('/');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kayıt yapılamadı. Lütfen tekrar deneyin.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        String errorMessage = 'Kayıt yapılamadı. Lütfen tekrar deneyin.';
        if (e is Exception) {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        } else {
          errorMessage = e.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinema101'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo - Üstte
              Image.asset(
                'assets/cin_logo.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              // Hoşgeldiniz mesajı
              Text(
                "Cinema101'e Hoşgeldiniz",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Kullanıcı Adı (Sadece Üye Ol modunda)
              if (_isSignUpMode) ...[
                CustomTextField(
                  controller: _displayNameController,
                  hintText: 'Kullanıcı Adı',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16),
              ],
              // Email ve Şifre Formu
              CustomTextField(
                controller: _emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Şifre',
                obscureText: true,
              ),
              // Şifre Doğrulama (Sadece Üye Ol modunda)
              if (_isSignUpMode) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Şifre Tekrar',
                  obscureText: true,
                ),
              ],
              const SizedBox(height: 32),
              // Giriş Yap / Üye Ol Butonu
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: _isSignUpMode ? 'Üye Ol' : 'Mail ve Şifre ile Giriş Yap',
                        onPressed: _isSignUpMode ? _signUpWithEmail : _signInWithEmail,
                      ),
              ),
              const SizedBox(height: 16),
              // Mod Değiştirme Butonu
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: () {
                          setState(() {
                            _isSignUpMode = !_isSignUpMode;
                            // Form alanlarını temizle
                            _passwordController.clear();
                            _confirmPasswordController.clear();
                          });
                        },
                        child: Text(
                          _isSignUpMode
                              ? 'Zaten üye misiniz? Giriş Yap'
                              : 'Hesabınız yok mu? Üye Ol',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
              ),
              // Google ile Giriş Butonu (Sadece Mobilde)
              if (!kIsWeb && !_isSignUpMode) ...[
                const SizedBox(height: 16),
                const Text(
                  'veya',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const SizedBox.shrink()
                      : CustomButton(
                          text: 'Google ile Giriş Yap',
                          onPressed: () async {
                            final authService = Provider.of<AuthService>(context, listen: false);
                            try {
                              setState(() {
                                _isLoading = true;
                              });
                              
                              final user = await authService.signInWithGoogle();
                              
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                                
                                if (user != null) {
                                  context.go('/');
                                } else {
                                  // Kullanıcı girişi iptal etti
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Giriş iptal edildi.'),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              // Hata durumunda kullanıcıya bildir
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                                String errorMessage = 'Giriş yapılamadı. Lütfen tekrar deneyin.';
                                if (e is Exception) {
                                  errorMessage = e.toString().replaceFirst('Exception: ', '');
                                } else {
                                  errorMessage = e.toString();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
