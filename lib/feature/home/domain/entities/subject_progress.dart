// Domain entity representing subject mastery and chapter progress.
// Surfaces weak topics that require student revision.
import 'entities_imports.dart';

class SubjectProgress extends Equatable {
  const SubjectProgress({
    required this.id,
    required this.subjectName,
    required this.masteryPercentage,
    required this.totalChapters,
    required this.completedChapters,
    required this.weakTopicsCount,
  });

  final String id;
  final String subjectName;
  final int masteryPercentage;
  final int totalChapters;
  final int completedChapters;
  final int weakTopicsCount;

  double get masteryRatio => (masteryPercentage / 100.0).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [
    id,
    subjectName,
    masteryPercentage,
    totalChapters,
    completedChapters,
    weakTopicsCount,
  ];
}
