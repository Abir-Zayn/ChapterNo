// Domain entity representing an ongoing or in-progress learning session.
// Allows the student to quickly resume where they left off.
import 'entities_imports.dart';

class LearningSession extends Equatable {
  const LearningSession({
    required this.id,
    required this.subjectName,
    required this.chapterTitle,
    required this.progressPercentage,
    required this.lastStudiedText,
    required this.estimatedRemainingMinutes,
  });

  final String id;
  final String subjectName;
  final String chapterTitle;
  final int progressPercentage;
  final String lastStudiedText;
  final int estimatedRemainingMinutes;

  double get progressRatio => (progressPercentage / 100.0).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [
    id,
    subjectName,
    chapterTitle,
    progressPercentage,
    lastStudiedText,
    estimatedRemainingMinutes,
  ];
}
