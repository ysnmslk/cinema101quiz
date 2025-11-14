
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/auth/services/firebase_auth_service.dart';
import 'package:myapp/profile/services/firebase_firestore_service.dart';
import 'package:myapp/profile/services/firestore_service.dart';
import 'package:myapp/quiz/screens/add_quiz_screen.dart';
import 'package:myapp/quiz/services/firebase_quiz_service.dart';
import 'package:myapp/quiz/services/quiz_service.dart';
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/profile_screen.dart';
import 'package:myapp/screens/quiz_screen.dart';
import 'package:myapp/settings/screens/settings_screen.dart';
import 'package:myapp/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AuthService>(
          create: (_) => FirebaseAuthService(),
        ),
        Provider<QuizService>(
          create: (_) => FirebaseQuizService(),
        ),
        Provider<FirestoreService>(
          create: (_) => FirebaseFirestoreService(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final authService = Provider.of<AuthService>(context, listen: false);
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Quiz App',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: _createRouter(authService),
          );
        },
      ),
    );
  }
}

GoRouter _createRouter(AuthService authService) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authService.userStream),
    redirect: (context, state) {
      final bool loggedIn = authService.currentUser != null;
      final bool loggingIn = state.matchedLocation == '/login';

      // Kullanıcı giriş yapmamışsa ve giriş sayfasında değilse, giriş sayfasına yönlendir
      if (!loggedIn) {
        return '/login';
      }

      // Kullanıcı giriş yapmışsa ve giriş sayfasına gitmeye çalışıyorsa, ana sayfaya yönlendir
      if (loggingIn) {
        return '/';
      }

      return null; // Başka bir yönlendirme gerekmiyor
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'quiz/:id',
            builder: (context, state) => QuizScreen(quizId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'add-quiz',
            builder: (context, state) => const AddQuizScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
}

// GoRouter'ı kimlik doğrulama durumu değişikliklerinde yenilemek için kullanılır
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
