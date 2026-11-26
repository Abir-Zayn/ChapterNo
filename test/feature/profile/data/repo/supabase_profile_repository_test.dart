// Verifies SupabaseProfileRepository against a mocked remote client:
// onboarding gate reads/writes, honest zero-state, settings mapping, and
// friendly error handling that never leaks raw Supabase messages.
import 'supabase_profile_repository_test_imports.dart';

class _MockProfileRemoteClient extends Mock implements ProfileRemoteClient {}

void main() {
  late _MockProfileRemoteClient client;
  late SupabaseProfileRepository repository;

  setUpAll(() => registerFallbackValue(<String, Object>{}));

  setUp(() {
    client = _MockProfileRemoteClient();
    when(() => client.currentUserId).thenReturn('user-1');
    when(() => client.currentUserEmail).thenReturn('student@example.com');
    repository = SupabaseProfileRepository(remoteClient: client);
  });

  T rightOrFail<T>(Either<ProfileFailure, T> result) => result.fold(
    (failure) => throw StateError(failure.message),
    (value) => value,
  );

  ProfileFailure failureOrFail<T>(Either<ProfileFailure, T> result) =>
      result.fold(
        (failure) => failure,
        (_) => throw StateError('expected a failure'),
      );

  group('onboarding gate', () {
    test('reads the gate from the completion timestamp', () async {
      when(
        () => client.fetchStudentProfile('user-1'),
      ).thenAnswer((_) async => null);
      expect(await repository.getOnboardingStatus(), const Right(false));

      when(() => client.fetchStudentProfile('user-1')).thenAnswer(
        (_) async => {'onboarding_completed_at': '2026-11-01T00:00:00Z'},
      );
      expect(await repository.getOnboardingStatus(), const Right(true));
    });

    test('writes every onboarding field with a UTC completion stamp', () async {
      when(
        () => client.updateStudentProfile('user-1', any()),
      ).thenAnswer((_) async {});
      final result = await repository.completeOnboarding(
        const OnboardingDraft(
          displayName: ' Tanvir Ahmed ',
          batchYear: 2027,
          board: OnboardingBoard(id: 3, name: 'Cumilla Board'),
          academicGroup: 'science',
          learningPace: 'intensive',
        ),
      );
      expect(result, const Right(unit));
      final values =
          verify(
                () => client.updateStudentProfile('user-1', captureAny()),
              ).captured.single
              as Map<String, Object>;
      expect(values['display_name'], 'Tanvir Ahmed');
      expect(values['ssc_batch_year'], 2027);
      expect(values['board_id'], 3);
      expect(values['academic_group'], 'science');
      expect(values['learning_pace'], 'intensive');
      expect(values['onboarding_completed_at'] as String, endsWith('Z'));
    });

    test('maps education board rows for the onboarding sheet', () async {
      when(() => client.fetchEducationBoards()).thenAnswer(
        (_) async => [
          {'id': 1, 'name_en': 'Dhaka Board'},
          {'id': 2, 'name_en': ' Chittagong Board '},
        ],
      );
      final boards = rightOrFail(await repository.getOnboardingBoards());
      expect(boards, const [
        OnboardingBoard(id: 1, name: 'Dhaka Board'),
        OnboardingBoard(id: 2, name: 'Chittagong Board'),
      ]);
    });
  });

  group('honest reads', () {
    test('serves a Free zero-state profile from a stored row', () async {
      when(() => client.fetchStudentProfile('user-1')).thenAnswer(
        (_) async => const {
          'display_name': 'Tanvir Ahmed',
          'ssc_batch_year': 2027,
          'board_id': 3,
          'academic_group': 'science',
          'learning_pace': 'intensive',
        },
      );
      final profile = rightOrFail(await repository.getProfile());
      expect(profile.fullName, 'Tanvir Ahmed');
      expect(profile.initials, 'TA');
      expect(profile.email, 'student@example.com');
      expect(profile.targetExam, 'SSC 2027');
      expect(profile.membershipTier, 'Free');
      expect(profile.learningPace, 'Intensive');
      expect(profile.academicGroup, 'Science');
      expect(profile.mcqsSolved, 0);
      expect(profile.leaderboardRank, 0);
    });

    test('analytics stay zero until real activity exists', () async {
      for (final timeframe in AnalyticsTimeframe.values) {
        final analytics = rightOrFail(await repository.getAnalytics(timeframe));
        expect(analytics.timeframe, timeframe);
        expect(analytics.totalSolvedVolume, 0);
        expect(analytics.mcqsSolved, 0);
        expect(analytics.subjects, isEmpty);
        expect(analytics.priorityTopics, isEmpty);
        expect(analytics.cohortRankLabel, 'No cohort data yet');
      }
    });
  });

  group('settings', () {
    test('falls back to defaults, then maps a stored row', () async {
      when(
        () => client.fetchStudentSettings('user-1'),
      ).thenAnswer((_) async => null);
      final defaults = rightOrFail(await repository.getSettings());
      expect(defaults.notificationsEnabled, isTrue);
      expect(defaults.soundEffectsEnabled, isTrue);
      expect(defaults.hapticsEnabled, isFalse);
      expect(defaults.learningTrack, LearningTrack.standardSsc);
      expect(defaults.language, AppLanguage.english);
      expect(defaults.darkModeEnabled, isFalse);

      when(() => client.fetchStudentSettings('user-1')).thenAnswer(
        (_) async => const {
          'notifications_enabled': false,
          'sound_effects_enabled': false,
          'haptics_enabled': true,
          'learning_track': 'exam_sprint',
          'app_language': 'bn',
          'dark_mode_enabled': true,
        },
      );
      final stored = rightOrFail(await repository.getSettings());
      expect(stored.notificationsEnabled, isFalse);
      expect(stored.hapticsEnabled, isTrue);
      expect(stored.learningTrack, LearningTrack.examSprint);
      expect(stored.language, AppLanguage.bangla);
      expect(stored.darkModeEnabled, isTrue);
    });

    test('upserts settings and mirrors theme prefs locally', () async {
      SharedPreferences.setMockInitialValues(const {});
      when(() => client.upsertStudentSettings(any())).thenAnswer((_) async {});
      final settings = AppSettings(
        notificationsEnabled: true,
        soundEffectsEnabled: true,
        hapticsEnabled: false,
        learningTrack: LearningTrack.acceleratedRevision,
        language: AppLanguage.bangla,
        darkModeEnabled: true,
      );
      final result = await repository.updateSettings(settings);
      expect(result, Right(settings));

      final values =
          verify(
                () => client.upsertStudentSettings(captureAny()),
              ).captured.single
              as Map<String, Object>;
      expect(values['user_id'], 'user-1');
      expect(values['learning_track'], 'accelerated_revision');
      expect(values['app_language'], 'bn');
      expect(values['dark_mode_enabled'], isTrue);

      final snapshot = await const StartupPreferences().load();
      expect(snapshot.initialDarkMode, isTrue);
      expect(snapshot.appLanguage, AppLanguage.bangla);
    });

    test('stores the legacy Light pace label as casual', () async {
      when(
        () => client.updateStudentProfile('user-1', any()),
      ).thenAnswer((_) async {});
      when(
        () => client.fetchStudentProfile('user-1'),
      ).thenAnswer((_) async => null);
      await repository.updateLearningPace('Light');
      final values =
          verify(
                () => client.updateStudentProfile('user-1', captureAny()),
              ).captured.single
              as Map<String, Object>;
      expect(values['learning_pace'], 'casual');
    });
  });

  group('failures', () {
    test('never leaks raw Supabase errors to the UI', () async {
      when(() => client.fetchStudentProfile('user-1')).thenThrow(
        PostgrestException(message: 'row-level security violation xyz-secret'),
      );
      final failure = failureOrFail(await repository.getProfile());
      expect(failure.message, 'Could not load your profile.');
      expect(failure.message.contains('xyz-secret'), isFalse);
    });

    test('explains timeouts in plain language', () async {
      when(
        () => client.fetchStudentProfile('user-1'),
      ).thenThrow(TimeoutException('request timed out'));
      final failure = failureOrFail(await repository.getProfile());
      expect(failure.message, startsWith('Could not load your profile.'));
      expect(failure.message, contains('timed out'));
    });

    test('requires a signed-in user for gated reads', () async {
      when(() => client.currentUserId).thenReturn(null);
      final failure = failureOrFail(await repository.getOnboardingStatus());
      expect(failure.message, 'Please sign in again.');
      verifyNever(() => client.fetchStudentProfile(any()));
    });
  });
}
