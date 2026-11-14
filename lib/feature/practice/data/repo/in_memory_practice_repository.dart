// In-memory implementation of PracticeRepository for offline support and testing.
// Pre-populated with realistic SSC student data matching the Stitch design.
import 'repo_imports.dart';

class InMemoryPracticeRepository implements PracticeRepository {
  InMemoryPracticeRepository({PracticeDashboardData? initialData})
    : _data = initialData ?? _defaultData;

  PracticeDashboardData _data;

  static const _defaultData = PracticeDashboardData(
    overview: PracticeOverviewMetrics(
      periodLabel: 'This Week',
      mcqsSolved: 120,
      accuracyPercentage: 82,
      accuracyDelta: '+4%',
      quizzesCompleted: 8,
    ),
    recentActivities: [
      RecentQuizActivity(
        id: 'quiz-phy-motion',
        subjectTitle: 'Physics',
        topicTitle: 'Motion',
        progressLabel: 'Topic MCQ • 16/20',
        status: QuizActivityStatus.completed,
        actionLabel: 'Review Results',
        subjectKey: 'physics',
      ),
      RecentQuizActivity(
        id: 'quiz-bio-cell',
        subjectTitle: 'Biology',
        topicTitle: 'Cell Division',
        progressLabel: 'Question 6 of 20',
        status: QuizActivityStatus.inProgress,
        actionLabel: 'Resume',
        subjectKey: 'biology',
      ),
    ],
    practiceModes: [
      PracticeModeItem(
        id: 'mode-topic-mcq',
        title: 'Topic MCQ',
        subtitle: 'Practice by chapter',
        modeType: PracticeModeType.topicMcq,
      ),
      PracticeModeItem(
        id: 'mode-board-mcq',
        title: 'Board MCQ',
        subtitle: 'Past exam questions',
        modeType: PracticeModeType.boardMcq,
      ),
      PracticeModeItem(
        id: 'mode-cq',
        title: 'CQ Practice',
        subtitle: 'Improve written answers',
        modeType: PracticeModeType.cqPractice,
      ),
      PracticeModeItem(
        id: 'mode-ranked',
        title: 'Ranked Quiz',
        subtitle: 'Challenge yourself',
        badge: 'Timed',
        modeType: PracticeModeType.rankedQuiz,
      ),
    ],
    milestone: DailyStreakMilestone(
      title: 'Daily streak active!',
      description: 'Solve 15 more MCQs today to reach your target milestone.',
      remainingMcqs: 15,
    ),
  );

  @override
  Future<Either<String, PracticeDashboardData>> getPracticeDashboard() async {
    return Right(_data);
  }

  @override
  Future<Either<String, PracticeDashboardData>> resumeQuiz(
    String quizId,
  ) async {
    final updatedActivities = _data.recentActivities.map((activity) {
      if (activity.id == quizId) {
        return RecentQuizActivity(
          id: activity.id,
          subjectTitle: activity.subjectTitle,
          topicTitle: activity.topicTitle,
          progressLabel: 'Question 7 of 20',
          status: QuizActivityStatus.inProgress,
          actionLabel: 'Resume',
          subjectKey: activity.subjectKey,
        );
      }
      return activity;
    }).toList();

    _data = _data.copyWith(recentActivities: updatedActivities);
    return Right(_data);
  }

  @override
  Future<Either<String, PracticeDashboardData>> reviewQuizResults(
    String quizId,
  ) async {
    return Right(_data);
  }
}
