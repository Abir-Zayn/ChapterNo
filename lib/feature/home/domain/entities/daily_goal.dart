// Domain entity representing the student's daily study target.
// Tracks target and completed question counts, time, and progress.
import 'entities_imports.dart';

class DailyGoal extends Equatable {
  const DailyGoal({
    required this.id,
    required this.subjectName,
    required this.chapterTitle,
    required this.totalQuestions,
    required this.completedQuestions,
    required this.targetMinutes,
    required this.completedMinutes,
  });

  final String id;
  final String subjectName;
  final String chapterTitle;
  final int totalQuestions;
  final int completedQuestions;
  final int targetMinutes;
  final int completedMinutes;

  double get progressRatio => totalQuestions == 0
      ? 0.0
      : (completedQuestions / totalQuestions).clamp(0.0, 1.0);

  bool get isCompleted => completedQuestions >= totalQuestions;

  @override
  List<Object?> get props => [
    id,
    subjectName,
    chapterTitle,
    totalQuestions,
    completedQuestions,
    targetMinutes,
    completedMinutes,
  ];
}
