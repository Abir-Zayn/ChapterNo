// Unit tests for ProfileCubit, LearningAnalyticsCubit, and SettingsCubit.
// Verifies loading, error recovery, stale-response guarding, and sign-out.
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:chapter_no/feature/auth/domain/entities/auth_failure.dart';
import 'package:chapter_no/feature/auth/domain/repositories/auth_repository.dart';
import 'package:chapter_no/feature/profile/data/repo/in_memory_profile_repository.dart';
import 'package:chapter_no/feature/profile/domain/entities/app_settings.dart';
import 'package:chapter_no/feature/profile/domain/entities/learning_analytics.dart';
import 'package:chapter_no/feature/profile/domain/entities/profile_failure.dart';
import 'package:chapter_no/feature/profile/domain/repositories/profile_repository.dart';
import 'package:chapter_no/feature/profile/screens/cubits/learning_analytics_cubit.dart';
import 'package:chapter_no/feature/profile/screens/cubits/learning_analytics_state.dart';
import 'package:chapter_no/feature/profile/screens/cubits/profile_cubit.dart';
import 'package:chapter_no/feature/profile/screens/cubits/profile_state.dart';
import 'package:chapter_no/feature/profile/screens/cubits/settings_cubit.dart';
import 'package:chapter_no/feature/profile/screens/cubits/settings_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late InMemoryProfileRepository repo;

  setUpAll(() {
    registerFallbackValue(AnalyticsTimeframe.weeks);
    registerFallbackValue(
      const AppSettings(
        notificationsEnabled: true,
        soundEffectsEnabled: true,
        hapticsEnabled: false,
        learningTrack: LearningTrack.standardSsc,
        language: AppLanguage.english,
        darkModeEnabled: false,
      ),
    );
  });

  setUp(() {
    repo = InMemoryProfileRepository(latency: Duration.zero);
  });

  group('ProfileCubit', () {
    blocTest<ProfileCubit, ProfileState>(
      'emits loading then loaded when profile loads successfully',
      build: () => ProfileCubit(profileRepository: repo),
      act: (cubit) => cubit.load(),
      expect: () => [isA<ProfileLoading>(), isA<ProfileLoaded>()],
    );

    blocTest<ProfileCubit, ProfileState>(
      'preserves loaded profile and sets actionError when pace update fails',
      build: () {
        final mockRepo = _MockProfileRepository();
        when(
          mockRepo.getProfile,
        ).thenAnswer((_) async => (await repo.getProfile()));
        when(
          () => mockRepo.updateLearningPace(any()),
        ).thenAnswer((_) async => const Left(ProfileFailure('Update failed')));
        return ProfileCubit(profileRepository: mockRepo);
      },
      act: (cubit) async {
        await cubit.load();
        await cubit.updateLearningPace('Intensive');
      },
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileLoaded>(),
        isA<ProfileLoaded>().having((s) => s.isUpdating, 'isUpdating', true),
        isA<ProfileLoaded>()
            .having((s) => s.isUpdating, 'isUpdating', false)
            .having((s) => s.actionError, 'actionError', 'Update failed'),
      ],
    );
  });

  group('LearningAnalyticsCubit', () {
    test('ignores stale timeframe response when switching rapidly', () async {
      final mockRepo = _MockProfileRepository();
      final daysCompleter =
          Completer<Either<ProfileFailure, LearningAnalytics>>();
      final monthsResult = await repo.getAnalytics(AnalyticsTimeframe.months);
      final daysResult = await repo.getAnalytics(AnalyticsTimeframe.days);

      when(
        () => mockRepo.getAnalytics(AnalyticsTimeframe.days),
      ).thenAnswer((_) => daysCompleter.future);
      when(
        () => mockRepo.getAnalytics(AnalyticsTimeframe.months),
      ).thenAnswer((_) async => monthsResult);

      final cubit = LearningAnalyticsCubit(profileRepository: mockRepo);
      addTearDown(cubit.close);

      final first = cubit.selectTimeframe(AnalyticsTimeframe.days);
      final second = cubit.selectTimeframe(AnalyticsTimeframe.months);
      await second;
      daysCompleter.complete(daysResult);
      await first;

      expect(cubit.state, isA<LearningAnalyticsLoaded>());
      final loaded = cubit.state as LearningAnalyticsLoaded;
      expect(loaded.analytics.timeframe, AnalyticsTimeframe.months);
    });
  });

  group('SettingsCubit', () {
    blocTest<SettingsCubit, SettingsState>(
      'sets signedOut=true only when authRepository.signOut succeeds',
      build: () {
        final auth = _MockAuthRepository();
        when(auth.signOut).thenAnswer((_) async => const Right(unit));
        return SettingsCubit(profileRepository: repo, authRepository: auth);
      },
      act: (cubit) async {
        await cubit.load();
        await cubit.signOut();
      },
      expect: () => [
        isA<SettingsLoading>(),
        isA<SettingsLoaded>(),
        isA<SettingsLoaded>().having((s) => s.isSigningOut, 'signingOut', true),
        isA<SettingsLoaded>().having((s) => s.signedOut, 'signedOut', true),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'retains SettingsLoaded with actionError when signOut fails',
      build: () {
        final auth = _MockAuthRepository();
        when(
          auth.signOut,
        ).thenAnswer((_) async => const Left(AuthFailure.network));
        return SettingsCubit(profileRepository: repo, authRepository: auth);
      },
      act: (cubit) async {
        await cubit.load();
        await cubit.signOut();
      },
      expect: () => [
        isA<SettingsLoading>(),
        isA<SettingsLoaded>(),
        isA<SettingsLoaded>().having((s) => s.isSigningOut, 'signingOut', true),
        isA<SettingsLoaded>()
            .having((s) => s.signedOut, 'signedOut', false)
            .having(
              (s) => s.actionError,
              'actionError',
              'Could not sign out. Please try again.',
            ),
      ],
    );
  });
}
