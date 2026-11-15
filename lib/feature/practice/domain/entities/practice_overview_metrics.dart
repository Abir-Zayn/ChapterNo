// Represents high-level student practice metrics over a given period.
// Displayed in the "Your Practice Overview" glanceable metric cards.
class PracticeOverviewMetrics {
  const PracticeOverviewMetrics({
    required this.periodLabel,
    required this.mcqsSolved,
    required this.accuracyPercentage,
    this.accuracyDelta = '+4%',
    required this.quizzesCompleted,
  });

  final String periodLabel;
  final int mcqsSolved;
  final int accuracyPercentage;
  final String? accuracyDelta;
  final int quizzesCompleted;

  PracticeOverviewMetrics copyWith({
    String? periodLabel,
    int? mcqsSolved,
    int? accuracyPercentage,
    String? accuracyDelta,
    int? quizzesCompleted,
  }) {
    return PracticeOverviewMetrics(
      periodLabel: periodLabel ?? this.periodLabel,
      mcqsSolved: mcqsSolved ?? this.mcqsSolved,
      accuracyPercentage: accuracyPercentage ?? this.accuracyPercentage,
      accuracyDelta: accuracyDelta ?? this.accuracyDelta,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
    );
  }
}
