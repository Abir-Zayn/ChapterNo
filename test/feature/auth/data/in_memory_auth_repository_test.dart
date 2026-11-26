// Verifies the temporary in-memory auth repository's account rules.
import 'package:chapter_no/feature/auth/data/repo/in_memory_auth_repository.dart';
import 'package:chapter_no/feature/auth/domain/entities/auth_failure.dart';
import 'package:chapter_no/feature/auth/domain/entities/auth_user.dart';
import 'package:chapter_no/feature/auth/domain/entities/sign_up_outcome.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryAuthRepository repository;
  final dateOfBirth = DateTime(2010, 1, 1);

  setUp(() => repository = InMemoryAuthRepository(latency: Duration.zero));

  Future<void> signUp() => repository.signUp(
    email: 'Student@Example.com',
    password: 'password1',
    dateOfBirth: dateOfBirth,
  );

  test('starts with no session', () async {
    expect(
      await repository.restoreSession(),
      const Right<AuthFailure, void>(null),
    );
  });

  test('sign up creates a session and rejects a duplicate email', () async {
    final first = await repository.signUp(
      email: 'Student@Example.com',
      password: 'password1',
      dateOfBirth: dateOfBirth,
    );
    expect(
      first,
      Right<AuthFailure, SignUpOutcome>(
        SignUpOutcome.authenticated(
          const AuthUser(
            id: 'student@example.com',
            email: 'student@example.com',
          ),
        ),
      ),
    );
    final session = await repository.restoreSession();
    expect(session.getOrElse(() => null)?.email, 'student@example.com');

    final second = await repository.signUp(
      email: 'student@example.com',
      password: 'other-password',
      dateOfBirth: dateOfBirth,
    );
    expect(
      second,
      const Left<AuthFailure, SignUpOutcome>(AuthFailure.emailAlreadyInUse),
    );
  });

  test(
    'sign in accepts any credentials and falls back when email is empty',
    () async {
      final withEmail = await repository.signIn(
        email: ' student@example.com ',
        password: '',
      );
      expect(withEmail.isRight(), isTrue);
      expect(
        (await repository.restoreSession()).getOrElse(() => null)?.email,
        'student@example.com',
      );

      final empty = await repository.signIn(email: '  ', password: '');
      expect(empty.isRight(), isTrue);
      expect(
        (await repository.restoreSession()).getOrElse(() => null)?.email,
        'student@chapterno.app',
      );
    },
  );

  test('sign out clears the session', () async {
    await signUp();
    await repository.signOut();
    final session = await repository.restoreSession();
    expect(session.getOrElse(() => null), isNull);
  });

  test('password reset is reported as unavailable, not as sent', () async {
    final result = await repository.sendPasswordReset(
      email: 'student@example.com',
    );
    expect(result, const Left<AuthFailure, Unit>(AuthFailure.unavailable));
  });
}
