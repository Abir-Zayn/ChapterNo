// Models an item in the student's recent practice quiz activity list.
// Tracks subject, topic, completion progress, and status action button.
enum QuizActivityStatus { completed, inProgress }

class RecentQuizActivity {
  const RecentQuizActivity({
    required this.id,
    required this.subjectTitle,
    required this.topicTitle,
    required this.progressLabel,
    required this.status,
    required this.actionLabel,
    required this.subjectKey,
  });

  final String id;
  final String subjectTitle;
  final String topicTitle;
  final String progressLabel;
  final QuizActivityStatus status;
  final String actionLabel;
  final String subjectKey;

  String get fullTitle => '$subjectTitle — $topicTitle';
  bool get isCompleted => status == QuizActivityStatus.completed;
}
