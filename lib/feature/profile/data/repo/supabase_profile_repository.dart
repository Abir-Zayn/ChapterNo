// Supabase-backed ProfileRepository: onboarding gate reads, profile writes,
// honest zero-state reads, and settings upsert mirroring theme prefs locally.
import 'repo_imports.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository({
    required this._remoteClient,
    StartupPreferences? startupPreferences,
    this._crashLogger,
  }) : _startupPreferences = startupPreferences ?? const StartupPreferences();

  static const ProfileFailure _signInAgain = ProfileFailure(
    'Please sign in again.',
  );

  final ProfileRemoteClient _remoteClient;
  final StartupPreferences _startupPreferences;
  final AppCrashLogger? _crashLogger;

  @override
  Future<Either<ProfileFailure, bool>> getOnboardingStatus() async {
    final userId = _remoteClient.currentUserId;
    if (userId == null) return const Left(_signInAgain);
    return _guard(
      'get_onboarding_status',
      'Could not check your profile.',
      () async {
        final row = await _remoteClient.fetchStudentProfile(userId);
        return Right(row?['onboarding_completed_at'] != null);
      },
    );
  }

  @override
  Future<Either<ProfileFailure, Unit>> completeOnboarding(
    OnboardingDraft draft,
  ) async {
    final userId = _remoteClient.currentUserId;
    if (userId == null) return const Left(_signInAgain);
    final batchYear = draft.batchYear;
    final boardId = draft.board?.id;
    final academicGroup = draft.academicGroup;
    if (batchYear == null || boardId == null || academicGroup == null) {
      return const Left(ProfileFailure('Fill in every field before saving.'));
    }
    return _guard(
      'complete_onboarding',
      'Could not save your profile. Check your connection and try again.',
      () async {
        await _remoteClient.updateStudentProfile(userId, {
          'display_name': draft.displayName.trim(),
          'ssc_batch_year': batchYear,
          'board_id': boardId,
          'academic_group': academicGroup,
          'learning_pace': draft.learningPace,
          'onboarding_completed_at': DateTime.now().toUtc().toIso8601String(),
        });
        return const Right(unit);
      },
    );
  }

  @override
  Future<Either<ProfileFailure, List<OnboardingBoard>>> getOnboardingBoards() {
    return _guard(
      'get_onboarding_boards',
      'Could not load education boards.',
      () async {
        final rows = await _remoteClient.fetchEducationBoards();
        return Right(
          List<OnboardingBoard>.unmodifiable([
            for (final row in rows)
              OnboardingBoard(
                id: row['id'] as int,
                name: (row['name_en'] as String? ?? '').trim(),
              ),
          ]),
        );
      },
    );
  }

  @override
  Future<Either<ProfileFailure, StudentProfile>> getProfile() async {
    final userId = _remoteClient.currentUserId;
    if (userId == null) return const Left(_signInAgain);
    return _guard('get_profile', 'Could not load your profile.', () async {
      final row = await _remoteClient.fetchStudentProfile(userId);
      return Right(_honestProfile(userId, row));
    });
  }

  @override
  Future<Either<ProfileFailure, StudentProfile>> updateLearningPace(
    String pace,
  ) async {
    final userId = _remoteClient.currentUserId;
    if (userId == null) return const Left(_signInAgain);
    return _guard(
      'update_learning_pace',
      'Could not update your pace.',
      () async {
        await _remoteClient.updateStudentProfile(userId, {
          'learning_pace': _paceValueFromLabel(pace),
        });
        return getProfile();
      },
    );
  }

  @override
  Future<Either<ProfileFailure, LearningAnalytics>> getAnalytics(
    AnalyticsTimeframe timeframe,
  ) async {
    // shortcut: honest zero analytics until practice activity lands in
    // Step 2; the page renders its empty state when totalSolvedVolume is 0.
    return Right(_zeroAnalytics(timeframe));
  }

  @override
  Future<Either<ProfileFailure, AppSettings>> getSettings() async {
    final userId = _remoteClient.currentUserId;
    if (userId == null) return const Left(_signInAgain);
    return _guard('get_settings', 'Could not load your settings.', () async {
      final row = await _remoteClient.fetchStudentSettings(userId);
      return Right(
        AppSettings(
          notificationsEnabled: row?['notifications_enabled'] as bool? ?? true,
          soundEffectsEnabled: row?['sound_effects_enabled'] as bool? ?? true,
          hapticsEnabled: row?['haptics_enabled'] as bool? ?? false,
          learningTrack: _trackFromValue(row?['learning_track'] as String?),
          language: row?['app_language'] == 'bn'
              ? AppLanguage.bangla
              : AppLanguage.english,
          darkModeEnabled: row?['dark_mode_enabled'] as bool? ?? false,
        ),
      );
    });
  }

  @override
  Future<Either<ProfileFailure, AppSettings>> updateSettings(
    AppSettings settings,
  ) async {
    final userId = _remoteClient.currentUserId;
    if (userId == null) return const Left(_signInAgain);
    return _guard('update_settings', 'Could not save your settings.', () async {
      await _remoteClient.upsertStudentSettings({
        'user_id': userId,
        'notifications_enabled': settings.notificationsEnabled,
        'sound_effects_enabled': settings.soundEffectsEnabled,
        'haptics_enabled': settings.hapticsEnabled,
        'learning_track': _valueFromTrack(settings.learningTrack),
        'app_language': settings.language == AppLanguage.bangla ? 'bn' : 'en',
        'dark_mode_enabled': settings.darkModeEnabled,
      });
      // Mirror theme prefs locally so the next cold launch restores them
      // without waiting on the network; save() swallows its own failures.
      await _startupPreferences.save(
        darkModeEnabled: settings.darkModeEnabled,
        appLanguage: settings.language,
        logger: _crashLogger,
      );
      return Right(settings);
    });
  }

  /// Runs a remote call, mapping timeouts and remote errors to friendly
  /// failures so raw Supabase messages never reach the UI or logs.
  Future<Either<ProfileFailure, T>> _guard<T>(
    String stage,
    String message,
    Future<Either<ProfileFailure, T>> Function() action,
  ) async {
    try {
      return await action();
    } on TimeoutException {
      return Left(ProfileFailure('$message The request timed out.'));
    } on Object catch (error) {
      _crashLogger?.recordError(
        operation: 'supabase_profile_repository',
        stage: stage,
        error: error,
      );
      return Left(ProfileFailure(message));
    }
  }

  /// Honest profile for a signed-in student: Free plan and zero counters.
  /// Row values fill identity fields; missing rows read as defaults.
  StudentProfile _honestProfile(String userId, Map<String, dynamic>? row) {
    final displayName = (row?['display_name'] as String? ?? '').trim();
    final batchYear = row?['ssc_batch_year'] as int?;
    return StudentProfile(
      id: userId,
      fullName: displayName.isEmpty ? 'Student' : displayName,
      initials: _initialsOf(displayName),
      email: _remoteClient.currentUserEmail ?? '',
      targetExam: 'SSC ${batchYear ?? OnboardingDraft.batchYears.first}',
      academicGroup: _labelForValue(
        row?['academic_group'] as String?,
        OnboardingDraft.academicGroupOptions,
      ),
      learningPace: _labelForValue(
        row?['learning_pace'] as String?,
        OnboardingDraft.learningPaceOptions,
      ),
      membershipTier: 'Free',
      mcqsSolved: 0,
      mcqsTodayDelta: 0,
      accuracyPercent: 0,
      accuracyDeltaPercent: 0,
      cqsPracticed: 0,
      streakDays: 0,
      communityPostsCount: 0,
      communityNotesCount: 0,
      leaderboardRank: 0,
      plannedStudyCount: 0,
    );
  }

  String _initialsOf(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'S';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  String _labelForValue(String? value, List<OnboardingOption> options) {
    final fallback = options.first;
    if (value == null) return fallback.label;
    for (final option in options) {
      if (option.value == value) return option.label;
    }
    return fallback.label;
  }

  /// Maps UI pace labels to DB values; the 1990s-era 'Light' label and the
  /// spec's 'Casual' both store as 'casual'. Unknowns pass through and the
  /// DB CHECK rejects them.
  String _paceValueFromLabel(String label) {
    final normalized = label.trim().toLowerCase();
    return switch (normalized) {
      'light' || 'casual' => 'casual',
      'standard' => 'standard',
      'intensive' => 'intensive',
      _ => normalized,
    };
  }

  LearningTrack _trackFromValue(String? value) => switch (value) {
    'accelerated_revision' => LearningTrack.acceleratedRevision,
    'exam_sprint' => LearningTrack.examSprint,
    _ => LearningTrack.standardSsc,
  };

  String _valueFromTrack(LearningTrack track) => switch (track) {
    LearningTrack.standardSsc => 'standard_ssc',
    LearningTrack.acceleratedRevision => 'accelerated_revision',
    LearningTrack.examSprint => 'exam_sprint',
  };

  LearningAnalytics _zeroAnalytics(AnalyticsTimeframe timeframe) {
    return LearningAnalytics(
      timeframe: timeframe,
      cohortRankLabel: 'No cohort data yet',
      streakDays: 0,
      mcqsSolved: 0,
      mcqsDeltaLabel: 'No activity yet',
      accuracyPercent: 0,
      accuracyDeltaLabel: 'No activity yet',
      cqsPracticed: 0,
      cqsEvaluatedCount: 0,
      avgCqScore: 0,
      targetCqScore: 0,
      lastCqScore: 0,
      totalSolvedVolume: 0,
      focusTip: 'Complete a practice session to unlock focus insights.',
      weeklyVolume: const [],
      subjects: const [],
      totalTopics: 0,
      strongTopics: 0,
      inProgressTopics: 0,
      unexploredTopics: 0,
      priorityTopics: const [],
      recommendedMinutes: 0,
      recommendedTitle: 'Start your first practice session',
      recommendedDescription:
          'Your personalized plan appears once you practice.',
    );
  }
}
