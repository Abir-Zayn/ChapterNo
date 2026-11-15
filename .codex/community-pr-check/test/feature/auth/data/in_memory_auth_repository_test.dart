// Verifies the temporary in-memory auth repository's account rules.
import 'package:chapter_no/feature/auth/data/repo/in_memory_auth_repository.dart';
import 'package:chapter_no/feature/auth/domain/entities/auth_failure.dart';
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
    expect(first.isRight(), isTrue);
    final session = await repository.restoreSession();
    expect(session.getOrElse(() => null)?.email, 'student@example.com');

    final second = await repository.signUp(
      email: 'student@example.com',
      password: 'other-password',
      dateOfBirth: dateOfBirth,
    );
    expect(
      second,
      const Left<AuthFailure, void>(AuthFailure.emailAlreadyInUse),
    );
  });

  test('sign in needs a matching account and password', () async {
    await signUp();
    final unknown = await repository.signIn(
      email: 'nobody@example.com',
      password: 'password1',
    );
    final wrong = await repository.signIn(
      email: 'student@example.com',
      password: 'wrong',
    );
    final ok = await repository.signIn(
      email: ' student@example.com ',
      password: 'password1',
    );
    expect(unknown.isLeft(), isTrue);
    expect(
      wrong,
      const Left<AuthFailure, void>(AuthFailure.invalidCredentials),
    );
    expect(ok.isRight(), isTrue);
  });

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
