// Verifies state transitions of the login, sign-up, forgot-password, and
// splash Cubits against a mocked AuthRepository.
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:chapter_no/feature/auth/domain/entities/auth_failure.dart';
import 'package:chapter_no/feature/auth/domain/entities/auth_user.dart';
import 'package:chapter_no/feature/auth/screens/cubits/auth_form_state.dart';
import 'package:chapter_no/feature/auth/screens/cubits/forgot_password_cubit.dart';
import 'package:chapter_no/feature/auth/screens/cubits/login_cubit.dart';
import 'package:chapter_no/feature/auth/screens/cubits/sign_up_cubit.dart';
import 'package:chapter_no/feature/auth/screens/cubits/splash_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_auth_repository.dart';

void main() {
  const user = AuthUser(id: '1', email: 'student@example.com');
  late MockAuthRepository repository;

  setUpAll(registerAuthFallbacks);
  setUp(() => repository = MockAuthRepository());

  group('LoginCubit', () {
    blocTest<LoginCubit, AuthFormState>(
      'emits submitting then success, trimming the email',
      setUp: () => when(
        () => repository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Right(user)),
      build: () => LoginCubit(authRepository: repository),
      act: (cubit) => cubit.submit(email: ' a@b.co ', password: 'secret'),
      expect: () => const [AuthFormState.submitting(), AuthFormState.success()],
      verify: (_) => verify(
        () => repository.signIn(email: 'a@b.co', password: 'secret'),
      ).called(1),
    );

    blocTest<LoginCubit, AuthFormState>(
      'emits the failure returned by the repository',
      setUp: () => when(
        () => repository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Left(AuthFailure.invalidCredentials)),
      build: () => LoginCubit(authRepository: repository),
      act: (cubit) => cubit.submit(email: 'a@b.co', password: 'x'),
      expect: () => const [
        AuthFormState.submitting(),
        AuthFormState.failed(AuthFailure.invalidCredentials),
      ],
    );

    test('ignores a second submit while one is running', () async {
      final pending = Completer<Either<AuthFailure, AuthUser>>();
      when(
        () => repository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => pending.future);
      final cubit = LoginCubit(authRepository: repository);
      addTearDown(cubit.close);

      final first = cubit.submit(email: 'a@b.co', password: 'x');
      await cubit.submit(email: 'a@b.co', password: 'x');
      pending.complete(const Right(user));
      await first;

      verify(() => repository.signIn(email: 'a@b.co', password: 'x')).called(1);
    });

    test('does not emit after being closed mid-request', () async {
      final pending = Completer<Either<AuthFailure, AuthUser>>();
      when(
        () => repository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => pending.future);
      final cubit = LoginCubit(authRepository: repository);

      final submit = cubit.submit(email: 'a@b.co', password: 'x');
      await cubit.close();
      pending.complete(const Right(user));

      await expectLater(submit, completes);
    });
  });

  blocTest<SignUpCubit, AuthFormState>(
    'SignUpCubit emits failure when the email is already used',
    setUp: () => when(
      () => repository.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        dateOfBirth: any(named: 'dateOfBirth'),
      ),
    ).thenAnswer((_) async => const Left(AuthFailure.emailAlreadyInUse)),
    build: () => SignUpCubit(authRepository: repository),
    act: (cubit) => cubit.submit(
      email: 'a@b.co',
      password: 'password1',
      dateOfBirth: DateTime(2010),
    ),
    expect: () => const [
      AuthFormState.submitting(),
      AuthFormState.failed(AuthFailure.emailAlreadyInUse),
    ],
  );

  blocTest<ForgotPasswordCubit, AuthFormState>(
    'ForgotPasswordCubit emits success and can reset to the form',
    setUp: () => when(
      () => repository.sendPasswordReset(email: any(named: 'email')),
    ).thenAnswer((_) async => const Right(unit)),
    build: () => ForgotPasswordCubit(authRepository: repository),
    act: (cubit) async {
      await cubit.submit(email: 'a@b.co');
      cubit.reset();
    },
    expect: () => const [
      AuthFormState.submitting(),
      AuthFormState.success(),
      AuthFormState(),
    ],
  );

  group('SplashCubit', () {
    SplashCubit build() =>
        SplashCubit(authRepository: repository, minimumDisplay: Duration.zero);

    blocTest<SplashCubit, SplashStatus>(
      'routes to signed out when there is no session',
      setUp: () => when(
        repository.restoreSession,
      ).thenAnswer((_) async => const Right(null)),
      build: build,
      act: (cubit) => cubit.start(),
      expect: () => const [SplashStatus.signedOut],
    );

    blocTest<SplashCubit, SplashStatus>(
      'routes to signed in when a session exists',
      setUp: () => when(
        repository.restoreSession,
      ).thenAnswer((_) async => const Right(user)),
      build: build,
      act: (cubit) => cubit.start(),
      expect: () => const [SplashStatus.signedIn],
    );

    blocTest<SplashCubit, SplashStatus>(
      'treats a failed session check as signed out',
      setUp: () => when(
        repository.restoreSession,
      ).thenAnswer((_) async => const Left(AuthFailure.network)),
      build: build,
      act: (cubit) => cubit.start(),
      expect: () => const [SplashStatus.signedOut],
    );
  });
}
