// Domain entity representing a recent learning activity or practice test.
// Records test type, score, date, and performance indicators.
import 'entities_imports.dart';

enum StudyActivityType { mcq, cq, notebook, revision }

class StudyActivityItem extends Equatable {
  const StudyActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.scoreText,
    required this.activityType,
  });

  final String id;
  final String title;
  final String subtitle;
  final String timeAgo;
  final String scoreText;
  final StudyActivityType activityType;

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    timeAgo,
    scoreText,
    activityType,
  ];
}
