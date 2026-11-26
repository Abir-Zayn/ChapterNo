// Verifies SplashCubit launch routing: signed-out welcome, onboarding
// gate enforcement, transient profile failure retry, and close safety.
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:chapter_no/feature/auth/domain/entities/auth_failure.dart';
import 'package:chapter_no/feature/auth/domain/entities/auth_user.dart';
import 'package:chapter_no/feature/auth/screens/cubits/splash_cubit.dart';
import 'package:chapter_no/feature/profile/domain/entities/profile_failure.dart';
import 'package:chapter_no/feature/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_auth_repository.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  const user = AuthUser(id: '1', email: 'student@example.com');
  late MockAuthRepository authRepository;
  late _MockProfileRepository profileRepository;

  setUpAll(registerAuthFallbacks);
  setUp(() {
    authRepository = MockAuthRepository();
    profileRepository = _MockProfileRepository();
  });

  SplashCubit build() => SplashCubit(
    authRepository: authRepository,
    profileRepository: profileRepository,
    minimumDisplay: Duration.zero,
  );

  group('SplashCubit', () {
    blocTest<SplashCubit, SplashStatus>(
      'routes to signed out when there is no session',
      setUp: () => when(
        authRepository.restoreSession,
      ).thenAnswer((_) async => const Right(null)),
      build: build,
      act: (cubit) => cubit.start(),
      expect: () => const [SplashStatus.signedOut],
      verify: (_) => verifyNever(() => profileRepository.getOnboardingStatus()),
    );

    blocTest<SplashCubit, SplashStatus>(
      'routes signed-in students without a completed profile to onboarding',
      setUp: () {
        when(
          authRepository.restoreSession,
        ).thenAnswer((_) async => const Right(user));
        when(
          profileRepository.getOnboardingStatus,
        ).thenAnswer((_) async => const Right(false));
      },
      build: build,
      act: (cubit) => cubit.start(),
      expect: () => const [SplashStatus.needsOnboarding],
    );

    blocTest<SplashCubit, SplashStatus>(
      'routes signed-in students with a completed profile home',
      setUp: () {
        when(
          authRepository.restoreSession,
        ).thenAnswer((_) async => const Right(user));
        when(
          profileRepository.getOnboardingStatus,
        ).thenAnswer((_) async => const Right(true));
      },
      build: build,
      act: (cubit) => cubit.start(),
      expect: () => const [SplashStatus.ready],
    );

    blocTest<SplashCubit, SplashStatus>(
      'treats a failed session check as signed out',
      setUp: () => when(
        authRepository.restoreSession,
      ).thenAnswer((_) async => const Left(AuthFailure.network)),
      build: build,
      act: (cubit) => cubit.start(),
      expect: () => const [SplashStatus.signedOut],
    );

    blocTest<SplashCubit, SplashStatus>(
      'falls back to the onboarding gate without a profile repository',
      setUp: () => when(
        authRepository.restoreSession,
      ).thenAnswer((_) async => const Right(user)),
      build: () => SplashCubit(
        authRepository: authRepository,
        minimumDisplay: Duration.zero,
      ),
      act: (cubit) => cubit.start(),
      expect: () => const [SplashStatus.needsOnboarding],
    );

    blocTest<SplashCubit, SplashStatus>(
      'keeps the session and offers retry when the gate check fails '
      'transiently',
      setUp: () {
        when(
          authRepository.restoreSession,
        ).thenAnswer((_) async => const Right(user));
        when(
          profileRepository.getOnboardingStatus,
        ).thenAnswer((_) async => const Left(ProfileFailure('offline')));
      },
      build: build,
      act: (cubit) async {
        await cubit.start();
        when(
          profileRepository.getOnboardingStatus,
        ).thenAnswer((_) async => const Right(true));
        await cubit.retry();
      },
      expect: () => const [
        SplashStatus.profileLoadFailed,
        SplashStatus.checking,
        SplashStatus.ready,
      ],
      verify: (_) => verifyNever(() => authRepository.signOut()),
    );

    blocTest<SplashCubit, SplashStatus>(
      'signs the student out from the profile failure screen on request',
      setUp: () {
        when(
          authRepository.restoreSession,
        ).thenAnswer((_) async => const Right(user));
        when(
          profileRepository.getOnboardingStatus,
        ).thenAnswer((_) async => const Left(ProfileFailure('offline')));
        when(authRepository.signOut).thenAnswer((_) async => const Right(unit));
      },
      build: build,
      act: (cubit) async {
        await cubit.start();
        await cubit.signOutFromProfileFailure();
      },
      expect: () => const [
        SplashStatus.profileLoadFailed,
        SplashStatus.signedOut,
      ],
    );

    test('ignores a gate result that arrives after close', () async {
      when(
        authRepository.restoreSession,
      ).thenAnswer((_) async => const Right(user));
      final gate = Completer<Either<ProfileFailure, bool>>();
      when(
        profileRepository.getOnboardingStatus,
      ).thenAnswer((_) => gate.future);

      final cubit = build();
      final startFuture = cubit.start();
      await cubit.close();
      gate.complete(const Right(true));
      await startFuture;
    });
  });
}
