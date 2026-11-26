// Widget and presentation tests for SignUpPage email-verification outcomes
// and learner-safe AuthFailureMessage mappings.
import 'package:chapter_no/feature/auth/domain/entities/auth_failure.dart';
import 'package:chapter_no/feature/auth/domain/entities/auth_user.dart';
import 'package:chapter_no/feature/auth/domain/entities/sign_up_outcome.dart';
import 'package:chapter_no/feature/auth/screens/cubits/sign_up_cubit.dart';
import 'package:chapter_no/feature/auth/screens/sign_up_page.dart';
import 'package:chapter_no/feature/auth/screens/widgets/auth_failure_message.dart';
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

  Future<void> fillAndSubmitSignUp(WidgetTester tester) async {
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
    await tester.pump();
  }

  testWidgets(
    'SignUpPage shows calm verification prompt without calling onSignedUp',
    (tester) async {
      var signedUpCalls = 0;
      var loginCalls = 0;
      var verificationCalls = 0;
      when(
        () => repository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          dateOfBirth: any(named: 'dateOfBirth'),
        ),
      ).thenAnswer(
        (_) async => const Right(
          SignUpOutcome.verificationRequired('student@example.com'),
        ),
      );

      await tester.pumpPage(
        BlocProvider(
          create: (_) => SignUpCubit(authRepository: repository),
          child: SignUpPage(
            today: DateTime(2026, 11, 12),
            onSignedUp: () => signedUpCalls++,
            onLogIn: () => loginCalls++,
            onOpenTerms: () {},
            onOpenPrivacy: () {},
            onVerificationRequired: () => verificationCalls++,
          ),
        ),
      );

      await fillAndSubmitSignUp(tester);

      expect(signedUpCalls, 0);
      expect(verificationCalls, 1);
      expect(find.text('Verify your email'), findsOneWidget);
      expect(find.textContaining('student@example.com'), findsOneWidget);

      await tester.tap(find.text('Go to log in'));
      expect(loginCalls, 1);

      await tester.tap(find.text('Use a different email'));
      await tester.pump();
      expect(find.text('Create account'), findsWidgets);
    },
  );

  testWidgets('SignUpPage calls onSignedUp when session is immediate', (
    tester,
  ) async {
    var signedUpCalls = 0;
    when(
      () => repository.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        dateOfBirth: any(named: 'dateOfBirth'),
      ),
    ).thenAnswer((_) async => Right(SignUpOutcome.authenticated(user)));

    await tester.pumpPage(
      BlocProvider(
        create: (_) => SignUpCubit(authRepository: repository),
        child: SignUpPage(
          today: DateTime(2026, 11, 12),
          onSignedUp: () => signedUpCalls++,
          onLogIn: () {},
          onOpenTerms: () {},
          onOpenPrivacy: () {},
        ),
      ),
    );

    await fillAndSubmitSignUp(tester);
    expect(signedUpCalls, 1);
  });

  test('AuthFailureMessage provides user-safe copy for every AuthFailure', () {
    for (final failure in AuthFailure.values) {
      final copy = failure.message;
      expect(copy, isNotEmpty);
      expect(copy.toLowerCase(), isNot(contains('supabase')));
      expect(copy.toLowerCase(), isNot(contains('exception')));
    }
    expect(AuthFailure.emailNotConfirmed.message, contains('Confirm'));
    expect(AuthFailure.rateLimited.message, contains('Too many attempts'));
    expect(AuthFailure.weakPassword.message, contains('stronger password'));
  });
}
