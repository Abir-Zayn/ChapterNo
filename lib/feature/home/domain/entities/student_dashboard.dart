// Composite domain entity holding all student dashboard metrics and models.
// Provides streak count, coin balance, active targets, and learning state.
import 'entities_imports.dart';

class StudentDashboard extends Equatable {
  const StudentDashboard({
    required this.studentName,
    required this.cohortTitle,
    required this.currentStreakDays,
    required this.chapterCoins,
    required this.dailyGoal,
    required this.activeSession,
    required this.subjects,
    required this.recentActivities,
  });

  final String studentName;
  final String cohortTitle;
  final int currentStreakDays;
  final int chapterCoins;
  final DailyGoal dailyGoal;
  final LearningSession activeSession;
  final List<SubjectProgress> subjects;
  final List<StudyActivityItem> recentActivities;

  StudentDashboard copyWith({
    String? studentName,
    String? cohortTitle,
    int? currentStreakDays,
    int? chapterCoins,
    DailyGoal? dailyGoal,
    LearningSession? activeSession,
    List<SubjectProgress>? subjects,
    List<StudyActivityItem>? recentActivities,
  }) {
    return StudentDashboard(
      studentName: studentName ?? this.studentName,
      cohortTitle: cohortTitle ?? this.cohortTitle,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      chapterCoins: chapterCoins ?? this.chapterCoins,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      activeSession: activeSession ?? this.activeSession,
      subjects: subjects ?? this.subjects,
      recentActivities: recentActivities ?? this.recentActivities,
    );
  }

  @override
  List<Object?> get props => [
    studentName,
    cohortTitle,
    currentStreakDays,
    chapterCoins,
    dailyGoal,
    activeSession,
    subjects,
    recentActivities,
  ];
}
