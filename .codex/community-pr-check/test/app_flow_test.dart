// End-to-end widget test of the signed-out flow through the real router:
// splash, welcome, login, forgot password, terms, and unavailable sign-in.
import 'package:chapter_no/app.dart';
import 'package:chapter_no/feature/auth/data/repo/in_memory_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> launch(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 900);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChapterNoApp(
        authRepository: InMemoryAuthRepository(latency: Duration.zero),
      ),
    );
    expect(find.text('ChapterNo'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  testWidgets('splash leads a signed-out student to welcome', (tester) async {
    await launch(tester);
    expect(find.text('Sign up with email'), findsOneWidget);
  });

  testWidgets('welcome to login to forgot password and back', (tester) async {
    await launch(tester);

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.text('Send reset link'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('login with an unknown account shows an error, not home', (
    tester,
  ) async {
    await launch(tester);
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'nobody@example.com');
    await tester.enterText(fields.at(1), 'password1');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Email or password is incorrect'), findsOne);
    expect(find.text('You are signed in'), findsNothing);
  });

  testWidgets('Google sign-in says it is not available yet', (tester) async {
    await launch(tester);
    await tester.tap(find.text('Continue with Google'));
    await tester.pump();

    expect(find.text('Google sign-in is not available yet.'), findsOneWidget);
  });
}
