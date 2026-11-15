// Represents a selectable practice mode card in "Start a Practice".
// Covers Topic MCQ, Board MCQ, CQ Practice, and Ranked Quiz.
enum PracticeModeType { topicMcq, boardMcq, cqPractice, rankedQuiz }

class PracticeModeItem {
  const PracticeModeItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.modeType,
    this.badge,
    this.isAvailable = true,
  });

  final String id;
  final String title;
  final String subtitle;
  final PracticeModeType modeType;
  final String? badge;
  final bool isAvailable;
}
