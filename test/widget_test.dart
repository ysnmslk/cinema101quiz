import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/auth/services/auth_service.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:provider/provider.dart';

// Simple test AuthService implementation without mocks
class TestAuthService implements AuthService {
  @override
  Stream<User?> get userStream => Stream.value(null);
  
  @override
  User? get currentUser => null;
  
  @override
  Future<User?> signInAnonymously() async => null;
  
  @override
  Future<User?> signInWithGoogle() async => null;
  
  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async => null;
  
  @override
  Future<User?> createUserWithEmailAndPassword(String email, String password) async => null;
  
  @override
  Future<void> signOut() async {}
}

void main() {
  testWidgets('LoginScreen displays title and button', (WidgetTester tester) async {
    // Build the widget with test AuthService
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<AuthService>(
          create: (_) => TestAuthService(),
          child: const LoginScreen(),
        ),
      ),
    );

    // Verify that the AppBar title is displayed
    expect(find.text('Login'), findsOneWidget);
    
    // Verify that a button is present (CustomButton might render as ElevatedButton)
    expect(find.byType(ElevatedButton), findsWidgets);
  });

  testWidgets('LoginScreen has Google sign in button text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<AuthService>(
          create: (_) => TestAuthService(),
          child: const LoginScreen(),
        ),
      ),
    );

    // Verify that the Google sign in button text is displayed
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}
