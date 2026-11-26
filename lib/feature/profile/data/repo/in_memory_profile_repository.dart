// In-memory ProfileRepository test double and offline fallback with demo
// SSC student data. Production profile data uses SupabaseProfileRepository
// via bootstrap; mirrors the domain contract for local development.
import 'repo_imports.dart';

class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository({this.latency = const Duration(milliseconds: 120)});

  static const List<OnboardingBoard> _boards = [
    OnboardingBoard(id: 1, name: 'Dhaka Board'),
    OnboardingBoard(id: 2, name: 'Chittagong Board'),
    OnboardingBoard(id: 3, name: 'Rajshahi Board'),
    OnboardingBoard(id: 4, name: 'Cumilla Board'),
    OnboardingBoard(id: 5, name: 'Jashore Board'),
    OnboardingBoard(id: 6, name: 'Barishal Board'),
    OnboardingBoard(id: 7, name: 'Sylhet Board'),
    OnboardingBoard(id: 8, name: 'Dinajpur Board'),
    OnboardingBoard(id: 9, name: 'Mymensingh Board'),
    OnboardingBoard(id: 10, name: 'Madrasah Board'),
    OnboardingBoard(id: 11, name: 'Technical Board'),
  ];

  final Duration latency;

  bool _onboardingCompleted = false;

  StudentProfile _profile = const StudentProfile(
    id: 'student-demo-1',
    fullName: 'Tanvir Ahmed',
    initials: 'TA',
    email: 'tanvir.ssc27@chapterno.com',
    targetExam: 'SSC 2027',
    academicGroup: 'Science',
    learningPace: 'Standard',
    membershipTier: 'Plus Tier',
    mcqsSolved: 248,
    mcqsTodayDelta: 18,
    accuracyPercent: 82,
    accuracyDeltaPercent: 3,
    cqsPracticed: 12,
    streakDays: 7,
    communityPostsCount: 24,
    communityNotesCount: 8,
    leaderboardRank: 14,
    plannedStudyCount: 2,
  );

  AppSettings _settings = const AppSettings(
    notificationsEnabled: true,
    soundEffectsEnabled: true,
    hapticsEnabled: false,
    learningTrack: LearningTrack.standardSsc,
    language: AppLanguage.english,
    darkModeEnabled: false,
  );

  @override
  Future<Either<ProfileFailure, StudentProfile>> getProfile() async {
    await Future<void>.delayed(latency);
    return Right(_profile);
  }

  @override
  Future<Either<ProfileFailure, StudentProfile>> updateLearningPace(
    String pace,
  ) async {
    await Future<void>.delayed(latency);
    _profile = _profile.copyWith(learningPace: pace);
    return Right(_profile);
  }

  @override
  Future<Either<ProfileFailure, LearningAnalytics>> getAnalytics(
    AnalyticsTimeframe timeframe,
  ) async {
    await Future<void>.delayed(latency);
    return Right(_analyticsFor(timeframe));
  }

  @override
  Future<Either<ProfileFailure, AppSettings>> getSettings() async {
    await Future<void>.delayed(latency);
    return Right(_settings);
  }

  @override
  Future<Either<ProfileFailure, AppSettings>> updateSettings(
    AppSettings settings,
  ) async {
    await Future<void>.delayed(latency);
    _settings = settings;
    return Right(_settings);
  }

  @override
  Future<Either<ProfileFailure, bool>> getOnboardingStatus() async {
    await Future<void>.delayed(latency);
    return Right(_onboardingCompleted);
  }

  @override
  Future<Either<ProfileFailure, Unit>> completeOnboarding(
    OnboardingDraft draft,
  ) async {
    await Future<void>.delayed(latency);
    _onboardingCompleted = true;
    _profile = _profile.copyWith(
      learningPace: OnboardingDraft.labelForPace(draft.learningPace),
    );
    return const Right(unit);
  }

  @override
  Future<Either<ProfileFailure, List<OnboardingBoard>>>
  getOnboardingBoards() async {
    await Future<void>.delayed(latency);
    return Right(_boards);
  }

  LearningAnalytics _analyticsFor(AnalyticsTimeframe timeframe) {
    final multiplier = switch (timeframe) {
      AnalyticsTimeframe.days => 1,
      AnalyticsTimeframe.weeks => 1,
      AnalyticsTimeframe.months => 4,
      AnalyticsTimeframe.allTime => 12,
    };

    return LearningAnalytics(
      timeframe: timeframe,
      cohortRankLabel: 'Top 8% in SSC Science Cohort',
      streakDays: 14,
      mcqsSolved: 248 * multiplier,
      mcqsDeltaLabel: timeframe == AnalyticsTimeframe.days
          ? '+18 today'
          : '+${42 * multiplier} this ${timeframe.label.toLowerCase()}',
      accuracyPercent: timeframe == AnalyticsTimeframe.allTime ? 79 : 82,
      accuracyDeltaLabel: '3% vs last period',
      cqsPracticed: 12 * multiplier,
      cqsEvaluatedCount: 3 * multiplier,
      avgCqScore: 7.1,
      targetCqScore: 8.5,
      lastCqScore: 8.0,
      totalSolvedVolume: 142 * multiplier,
      focusTip: 'Thursdays showed your highest focus duration.',
      weeklyVolume: const [
        DailyStudyVolume(dayLabel: 'Mon', questionsSolved: 18),
        DailyStudyVolume(dayLabel: 'Tue', questionsSolved: 28),
        DailyStudyVolume(dayLabel: 'Wed', questionsSolved: 22),
        DailyStudyVolume(
          dayLabel: 'Thu',
          questionsSolved: 36,
          isHighlight: true,
        ),
        DailyStudyVolume(dayLabel: 'Fri', questionsSolved: 14),
        DailyStudyVolume(dayLabel: 'Sat', questionsSolved: 20),
        DailyStudyVolume(dayLabel: 'Sun', questionsSolved: 4),
      ],
      subjects: [
        SubjectPerformance(
          subject: 'Physics',
          solvedCount: 78 * multiplier,
          accuracyPercent: 84,
        ),
        SubjectPerformance(
          subject: 'Chemistry',
          solvedCount: 64 * multiplier,
          accuracyPercent: 76,
        ),
        SubjectPerformance(
          subject: 'Biology',
          solvedCount: 52 * multiplier,
          accuracyPercent: 81,
        ),
        SubjectPerformance(
          subject: 'Higher Math',
          solvedCount: 54 * multiplier,
          accuracyPercent: 68,
        ),
      ],
      totalTopics: 58,
      strongTopics: 14,
      inProgressTopics: 26,
      unexploredTopics: 18,
      priorityTopics: const [
        PriorityTopic(
          subject: 'Higher Math',
          accuracyPercent: 58,
          topicTitle: 'Trigonometry: Compound Angles',
          actionTag: 'Needs Revision',
        ),
        PriorityTopic(
          subject: 'Chemistry',
          accuracyPercent: 62,
          topicTitle: 'Chemical Bonding & Hybridization',
          actionTag: 'Practice',
        ),
        PriorityTopic(
          subject: 'Physics',
          accuracyPercent: 65,
          topicTitle: 'Kinematics: Relative Velocity Equations',
          actionTag: 'Formulas',
        ),
        PriorityTopic(
          subject: 'Biology',
          accuracyPercent: 68,
          topicTitle: 'Cell Division: Meiosis Stages',
          actionTag: 'Diagram Prep',
        ),
      ],
      recommendedMinutes: 15,
      recommendedTitle: 'Revise Higher Math: Trigonometry',
      recommendedDescription:
          'Tackle 10 adaptive questions targeting your lowest scoring topic (58% accuracy).',
    );
  }
}
