// In-memory implementation of HomeRepository providing realistic SSC student data.
// Simulates network latency and supports state updates for testing and previews.
import 'repo_imports.dart';

class InMemoryHomeRepository implements HomeRepository {
  InMemoryHomeRepository({StudentDashboard? initialData})
    : _dashboard = initialData ?? _defaultDashboard;

  StudentDashboard _dashboard;

  static final StudentDashboard _defaultDashboard = StudentDashboard(
    studentName: 'Siam',
    cohortTitle: 'SSC 2026 • Science Group',
    currentStreakDays: 7,
    chapterCoins: 120,
    dailyGoal: const DailyGoal(
      id: 'goal-1',
      subjectName: 'Physics',
      chapterTitle: 'Chapter 4: Work, Power & Energy',
      totalQuestions: 20,
      completedQuestions: 15,
      targetMinutes: 45,
      completedMinutes: 30,
    ),
    activeSession: const LearningSession(
      id: 'session-1',
      subjectName: 'General Science',
      chapterTitle: 'Chapter 3: Heart of the Living',
      progressPercentage: 65,
      lastStudiedText: 'Today, 10:30 AM',
      estimatedRemainingMinutes: 15,
    ),
    subjects: const [
      SubjectProgress(
        id: 'sub-1',
        subjectName: 'Physics',
        masteryPercentage: 78,
        totalChapters: 14,
        completedChapters: 9,
        weakTopicsCount: 2,
      ),
      SubjectProgress(
        id: 'sub-2',
        subjectName: 'Chemistry',
        masteryPercentage: 64,
        totalChapters: 12,
        completedChapters: 7,
        weakTopicsCount: 4,
      ),
      SubjectProgress(
        id: 'sub-3',
        subjectName: 'Higher Mathematics',
        masteryPercentage: 82,
        totalChapters: 14,
        completedChapters: 11,
        weakTopicsCount: 1,
      ),
      SubjectProgress(
        id: 'sub-4',
        subjectName: 'Biology',
        masteryPercentage: 70,
        totalChapters: 14,
        completedChapters: 8,
        weakTopicsCount: 3,
      ),
    ],
    recentActivities: const [
      StudyActivityItem(
        id: 'act-1',
        title: 'Board MCQ Practice',
        subtitle: 'Physics • Chapter 3: Force',
        timeAgo: '45 mins ago',
        scoreText: '18/20 (90%)',
        activityType: StudyActivityType.mcq,
      ),
      StudyActivityItem(
        id: 'act-2',
        title: 'Mistake Notebook Review',
        subtitle: 'Chemistry • Chemical Bonds',
        timeAgo: '2 hours ago',
        scoreText: '5 reviewed',
        activityType: StudyActivityType.notebook,
      ),
      StudyActivityItem(
        id: 'act-3',
        title: 'Diagnostic Test',
        subtitle: 'Higher Math • Vectors',
        timeAgo: 'Yesterday',
        scoreText: '85% Mastery',
        activityType: StudyActivityType.revision,
      ),
    ],
  );

  @override
  Future<Either<String, StudentDashboard>> getDashboard() async {
    return Right(_dashboard);
  }

  @override
  Future<Either<String, StudentDashboard>> incrementGoalProgress() async {
    final currentGoal = _dashboard.dailyGoal;
    final updatedCompleted = (currentGoal.completedQuestions + 1).clamp(
      0,
      currentGoal.totalQuestions,
    );
    final updatedGoal = DailyGoal(
      id: currentGoal.id,
      subjectName: currentGoal.subjectName,
      chapterTitle: currentGoal.chapterTitle,
      totalQuestions: currentGoal.totalQuestions,
      completedQuestions: updatedCompleted,
      targetMinutes: currentGoal.targetMinutes,
      completedMinutes: (currentGoal.completedMinutes + 2).clamp(
        0,
        currentGoal.targetMinutes,
      ),
    );
    _dashboard = _dashboard.copyWith(dailyGoal: updatedGoal);
    return Right(_dashboard);
  }
}
