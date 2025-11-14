
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myapp/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/auth/services/firebase_auth_service.dart';
import 'package:myapp/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider'ı en üste ekleyerek tüm uygulamayı kapsamasını sağlıyoruz.
    return MultiProvider(
      providers: [
        // Tema durumunu yönetmek için
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        // AuthService'i tüm uygulama genelinde erişilebilir kılmak için
        Provider<AuthService>(create: (_) => FirebaseAuthService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Quiz App',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            // Uygulamanın başlangıç noktası
            home: const Scaffold(
              body: Center(child: Text('Please use lib/main.dart')),
            ), 
          );
        },
      ),
    );
  }
}
