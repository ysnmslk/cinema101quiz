
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/auth/services/auth_service.dart';


class MockAuthService extends Mock implements AuthService {}

void main() {
  testWidgets('LoginScreen has a title and a button', (WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<AuthService>(
        create: (_) => MockAuthService(),
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
