// Widget tests for the login, sign-up, and forgot-password pages:
// validation, loading, failure feedback, success callbacks, and layout
// on a narrow screen with enlarged text.
import 'dart:async';

import 'package:chapter_no/feature/auth/domain/entities/auth_failure.dart';
import 'package:chapter_no/feature/auth/domain/entities/auth_user.dart';
import 'package:chapter_no/feature/auth/screens/cubits/forgot_password_cubit.dart';
import 'package:chapter_no/feature/auth/screens/cubits/login_cubit.dart';
import 'package:chapter_no/feature/auth/screens/cubits/sign_up_cubit.dart';
import 'package:chapter_no/feature/auth/screens/forgot_password_page.dart';
import 'package:chapter_no/feature/auth/screens/login_page.dart';
import 'package:chapter_no/feature/auth/screens/sign_up_page.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mock_auth_repository.dart';
import '../../../helpers/pump_page.dart';

void main() {
  const user = AuthUser(id: '1', email: 'student@example.com');
  late MockAuthRepository repository;

  setUpAll(registerAuthFallbacks);
  setUp(() => repository = MockAuthRepository());

  Finder field(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(Column)).first;

  Future<void> enter(WidgetTester tester, String label, String text) =>
      tester.enterText(
        find.descendant(of: field(label), matching: find.byType(TextField)),
        text,
      );

  group('LoginPage', () {
    var loggedIn = 0;

    Widget page() => BlocProvider(
      create: (_) => LoginCubit(authRepository: repository),
      child: LoginPage(
        onLoggedIn: () => loggedIn++,
        onForgotPassword: () {},
        onSignUp: () {},
      ),
    );

    void stubSignIn(Future<Either<AuthFailure, AuthUser>> Function() answer) {
      when(
        () => repository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => answer());
    }

    setUp(() => loggedIn = 0);

    testWidgets('shows validation errors and does not call the repository', (
      tester,
    ) async {
      await tester.pumpPage(page());
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pump();

      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
      verifyNever(
        () => repository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('disables the form while submitting, then reports success', (
      tester,
    ) async {
      final pending = Completer<Either<AuthFailure, AuthUser>>();
      stubSignIn(() => pending.future);
      await tester.pumpPage(page());
      await enter(tester, 'Email', 'student@example.com');
      await enter(tester, 'Password', 'password1');
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Log in'),
      );
      expect(button.onPressed, isNull);

      pending.complete(const Right(user));
      await tester.pump();
      expect(loggedIn, 1);
    });

    testWidgets('explains a failure and keeps the entered email', (
      tester,
    ) async {
      stubSignIn(() async => const Left(AuthFailure.invalidCredentials));
      await tester.pumpPage(page());
      await enter(tester, 'Email', 'student@example.com');
      await enter(tester, 'Password', 'wrong-password');
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Email or password is incorrect'), findsOne);
      expect(find.text('student@example.com'), findsOneWidget);
      expect(loggedIn, 0);
    });
  });

  group('SignUpPage', () {
    Widget page() => BlocProvider(
      create: (_) => SignUpCubit(authRepository: repository),
      child: SignUpPage(
        today: DateTime(2026, 11, 12),
        onSignedUp: () {},
        onLogIn: () {},
        onOpenTerms: () {},
        onOpenPrivacy: () {},
      ),
    );

    testWidgets('requires date of birth, email, and a long enough password', (
      tester,
    ) async {
      await tester.pumpPage(page());
      await enter(tester, 'Password', 'short');
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Create account'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pump();

      expect(find.text('Select your date of birth.'), findsOneWidget);
      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(find.text('Use at least 8 characters.'), findsOneWidget);
      verifyNever(
        () => repository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          dateOfBirth: any(named: 'dateOfBirth'),
        ),
      );
    });

    testWidgets('submits the picked date of birth with the form', (
      tester,
    ) async {
      when(
        () => repository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          dateOfBirth: any(named: 'dateOfBirth'),
        ),
      ).thenAnswer((_) async => const Right(user));
      await tester.pumpPage(page());

      await tester.tap(
        find.descendant(
          of: field('Date of birth'),
          matching: find.byType(TextField),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await enter(tester, 'Email', 'student@example.com');
      await enter(tester, 'Password', 'password1');
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Create account'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pump();

      verify(
        () => repository.signUp(
          email: 'student@example.com',
          password: 'password1',
          dateOfBirth: DateTime(2011, 11, 12),
        ),
      ).called(1);
    });

    testWidgets('fits a narrow screen with 1.5x text without overflow', (
      tester,
    ) async {
      await tester.pumpPage(page(), size: const Size(320, 568), textScale: 1.5);
      expect(tester.takeException(), isNull);
      expect(find.text('Create account'), findsWidgets);
    });
  });

  group('ForgotPasswordPage', () {
    var backToLogin = 0;

    Widget page() => BlocProvider(
      create: (_) => ForgotPasswordCubit(authRepository: repository),
      child: ForgotPasswordPage(onBackToLogin: () => backToLogin++),
    );

    void stubReset(Either<AuthFailure, Unit> result) {
      when(
        () => repository.sendPasswordReset(email: any(named: 'email')),
      ).thenAnswer((_) async => result);
    }

    setUp(() => backToLogin = 0);

    testWidgets('rejects an invalid email before sending', (tester) async {
      await tester.pumpPage(page());
      await enter(tester, 'Email', 'not-an-email');
      await tester.tap(find.text('Send reset link'));
      await tester.pump();

      expect(find.text('Enter a valid email address.'), findsOneWidget);
      verifyNever(
        () => repository.sendPasswordReset(email: any(named: 'email')),
      );
    });

    testWidgets('shows the confirmation and can return to the form', (
      tester,
    ) async {
      stubReset(const Right(unit));
      await tester.pumpPage(page());
      await enter(tester, 'Email', 'student@example.com');
      await tester.tap(find.text('Send reset link'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Check your email'), findsOneWidget);
      expect(find.textContaining('student@example.com'), findsOneWidget);

      await tester.tap(find.text('Back to log in'));
      expect(backToLogin, 1);

      await tester.tap(find.text('Use a different email'));
      await tester.pump();
      expect(find.text('Forgot password?'), findsOneWidget);
    });

    testWidgets('stays on the form and explains when sending fails', (
      tester,
    ) async {
      stubReset(const Left(AuthFailure.unavailable));
      await tester.pumpPage(page());
      await enter(tester, 'Email', 'student@example.com');
      await tester.tap(find.text('Send reset link'));
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('not available yet'), findsOneWidget);
      expect(find.text('Check your email'), findsNothing);
    });
  });
}
