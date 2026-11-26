// Controllable per-user FakeProfileRepository enforcing honest zero-state
// Step 1 defaults ('Free' tier, 0 stats, rank 0), onboarding tracking, and
// transient user-cache isolation across shared-device sign-outs.
import 'e2e_profile_fake_imports.dart';

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({required this.authRepository, this.prefs});

  final FakeAuthRepository authRepository;
  final FakeAppPrefsStore? prefs;

  final Map<String, StudentProfile> _profiles = {};
  final Map<String, AppSettings> _settings = {};
  final Map<String, bool> _onboardingDone = {};
  final Map<String, String> _boards = {};
  final Map<String, String?> _usernames = {};

  String? _cachedUserId;
  StudentProfile? _cachedProfile;
  AppSettings? _cachedSettings;

  ProfileFailure? nextOnboardingFailure;
  ProfileFailure? nextCompleteOnboardingFailure;
  ProfileFailure? nextProfileFailure;
  ProfileFailure? nextAnalyticsFailure;
  ProfileFailure? nextSettingsFailure;
  ProfileFailure? nextPaceFailure;
  ProfileFailure? nextUpdateSettingsFailure;

  Completer<Either<ProfileFailure, StudentProfile>>? profileCompleter;
  Completer<Either<ProfileFailure, Unit>>? completeOnboardingCompleter;

  /// Shell-only side channel: optional username handle validated with the
  /// profile submission. The real contract has no username field.
  String? pendingUsername;

  int flushCount = 0;
  int clearCacheCount = 0;
  int completeOnboardingCalls = 0;

  String get _uid => authRepository.currentUser?.id ?? 'anonymous';

  void seedUserProfile({
    required String userId,
    required String email,
    String fullName = 'Student',
    String targetExam = 'SSC 2027',
    String academicGroup = 'Science',
    String learningPace = 'Standard',
    int leaderboardRank = 0,
    bool onboarded = true,
    AppSettings? settings,
  }) {
    _profiles[userId] = _buildProfile(
      id: userId,
      fullName: fullName,
      email: email,
      targetExam: targetExam,
      academicGroup: academicGroup,
      learningPace: learningPace,
      leaderboardRank: leaderboardRank,
    );
    _onboardingDone[userId] = onboarded;
    if (settings != null) _settings[userId] = settings;
  }

  @override
  Future<Either<ProfileFailure, bool>> getOnboardingStatus() async {
    final failure = nextOnboardingFailure;
    nextOnboardingFailure = null;
    if (failure != null) return Left(failure);
    return Right(_onboardingDone[_uid] ?? false);
  }

  @override
  Future<Either<ProfileFailure, Unit>> completeOnboarding(
    OnboardingDraft draft,
  ) async {
    completeOnboardingCalls++;
    if (completeOnboardingCompleter != null) {
      return completeOnboardingCompleter!.future;
    }
    final failure = nextCompleteOnboardingFailure;
    nextCompleteOnboardingFailure = null;
    if (failure != null) return Left(failure);

    final trimmed = draft.displayName.trim();
    if (trimmed.length < 2 || trimmed.length > 60) {
      return const Left(ProfileFailure('Display name must be 2 to 60 chars.'));
    }
    if (draft.batchYear == null ||
        draft.board == null ||
        draft.academicGroup == null) {
      return const Left(ProfileFailure('Fill in every field before saving.'));
    }
    final username = pendingUsername;
    pendingUsername = null;
    if (username != null &&
        username.isNotEmpty &&
        !RegExp(r'^[a-z0-9_]{3,24}$').hasMatch(username)) {
      return const Left(ProfileFailure('Invalid username handle.'));
    }

    final groupLabel = OnboardingDraft.academicGroupOptions
        .firstWhere(
          (o) => o.value == draft.academicGroup,
          orElse: () => OnboardingDraft.academicGroupOptions.first,
        )
        .label;
    final profile = _buildProfile(
      id: _uid,
      fullName: trimmed,
      email: authRepository.currentUser?.email ?? '',
      targetExam: 'SSC ${draft.batchYear}',
      academicGroup: groupLabel,
      learningPace: OnboardingDraft.labelForPace(draft.learningPace),
    );
    _profiles[_uid] = profile;
    _onboardingDone[_uid] = true;
    // shortcut: board code rides in OnboardingBoard.name until Wave 4 swaps
    // in the real picker backed by education_board ids.
    _boards[_uid] = draft.board!.name;
    _usernames[_uid] = (username != null && username.isNotEmpty)
        ? username
        : null;
    _cachedUserId = _uid;
    _cachedProfile = profile;
    return const Right(unit);
  }

  @override
  Future<Either<ProfileFailure, List<OnboardingBoard>>> getOnboardingBoards() {
    return Future.value(
      const Right([
        OnboardingBoard(id: 1, name: 'Dhaka Board'),
        OnboardingBoard(id: 2, name: 'Chittagong Board'),
      ]),
    );
  }

  String? boardForUser(String userId) => _boards[userId];
  String? usernameForUser(String userId) => _usernames[userId];
  StudentProfile? get cachedProfile => _cachedProfile;
  AppSettings? get cachedSettings => _cachedSettings;

  Future<void> flushPendingSettings() async => flushCount++;

  Future<void> clearCachedUserData() async {
    clearCacheCount++;
    _cachedUserId = null;
    _cachedProfile = null;
    _cachedSettings = null;
  }

  @override
  Future<Either<ProfileFailure, StudentProfile>> getProfile() async {
    if (profileCompleter != null) return profileCompleter!.future;
    final failure = nextProfileFailure;
    nextProfileFailure = null;
    if (failure != null) return Left(failure);
    final profile = _profiles[_uid] ?? _zeroProfile(_uid);
    _cachedUserId = _uid;
    _cachedProfile = profile;
    return Right(profile);
  }

  @override
  Future<Either<ProfileFailure, StudentProfile>> updateLearningPace(
    String pace,
  ) async {
    final failure = nextPaceFailure;
    nextPaceFailure = null;
    if (failure != null) return Left(failure);
    final current = _profiles[_uid] ?? _zeroProfile(_uid);
    final updated = current.copyWith(learningPace: pace);
    _profiles[_uid] = updated;
    if (_cachedUserId == _uid) _cachedProfile = updated;
    return Right(updated);
  }

  @override
  Future<Either<ProfileFailure, LearningAnalytics>> getAnalytics(
    AnalyticsTimeframe timeframe,
  ) async {
    final failure = nextAnalyticsFailure;
    nextAnalyticsFailure = null;
    if (failure != null) return Left(failure);
    return Right(_emptyAnalytics(timeframe));
  }

  @override
  Future<Either<ProfileFailure, AppSettings>> getSettings() async {
    final failure = nextSettingsFailure;
    nextSettingsFailure = null;
    if (failure != null) return Left(failure);
    final settings = _settings[_uid] ?? _defaultSettings();
    _cachedUserId = _uid;
    _cachedSettings = settings;
    return Right(settings);
  }

  @override
  Future<Either<ProfileFailure, AppSettings>> updateSettings(
    AppSettings settings,
  ) async {
    final failure = nextUpdateSettingsFailure;
    nextUpdateSettingsFailure = null;
    if (failure != null) return Left(failure);
    _settings[_uid] = settings;
    _cachedUserId = _uid;
    _cachedSettings = settings;
    prefs?.darkModeEnabled = settings.darkModeEnabled;
    prefs?.language = settings.language;
    return Right(settings);
  }

  StudentProfile _buildProfile({
    required String id,
    required String fullName,
    required String email,
    required String targetExam,
    required String academicGroup,
    required String learningPace,
    int leaderboardRank = 0,
  }) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : fullName.substring(0, 1).toUpperCase();
    return StudentProfile(
      id: id,
      fullName: fullName,
      initials: initials,
      email: email,
      targetExam: targetExam,
      academicGroup: academicGroup,
      learningPace: learningPace,
      membershipTier: 'Free',
      mcqsSolved: 0,
      mcqsTodayDelta: 0,
      accuracyPercent: 0,
      accuracyDeltaPercent: 0,
      cqsPracticed: 0,
      streakDays: 0,
      communityPostsCount: 0,
      communityNotesCount: 0,
      leaderboardRank: leaderboardRank,
      plannedStudyCount: 0,
    );
  }

  StudentProfile _zeroProfile(String id) => _buildProfile(
    id: id,
    fullName: 'New Student',
    email: authRepository.currentUser?.email ?? '',
    targetExam: 'SSC 2027',
    academicGroup: 'Science',
    learningPace: 'Standard',
  );

  AppSettings _defaultSettings() => const AppSettings(
    notificationsEnabled: true,
    soundEffectsEnabled: true,
    hapticsEnabled: true,
    learningTrack: LearningTrack.standardSsc,
    language: AppLanguage.english,
    darkModeEnabled: false,
  );

  LearningAnalytics _emptyAnalytics(AnalyticsTimeframe timeframe) {
    return LearningAnalytics(
      timeframe: timeframe,
      cohortRankLabel: 'Unranked',
      streakDays: 0,
      mcqsSolved: 0,
      mcqsDeltaLabel: 'No activity yet',
      accuracyPercent: 0,
      accuracyDeltaLabel: 'Complete a session',
      cqsPracticed: 0,
      cqsEvaluatedCount: 0,
      avgCqScore: 0,
      targetCqScore: 8,
      lastCqScore: 0,
      totalSolvedVolume: 0,
      focusTip: 'Complete your first practice session to unlock insights.',
      weeklyVolume: const [],
      subjects: const [],
      totalTopics: 0,
      strongTopics: 0,
      inProgressTopics: 0,
      unexploredTopics: 0,
      priorityTopics: const [],
      recommendedMinutes: 15,
      recommendedTitle: 'Start your first practice',
      recommendedDescription:
          'Attempt a short MCQ quiz to measure baseline accuracy.',
    );
  }
}
