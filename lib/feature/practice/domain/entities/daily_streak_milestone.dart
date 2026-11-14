// Models the daily streak encouragement and milestone progress indicator.
// Surfaces target milestone status and motivational messaging.
class DailyStreakMilestone {
  const DailyStreakMilestone({
    required this.title,
    required this.description,
    required this.remainingMcqs,
  });

  final String title;
  final String description;
  final int remainingMcqs;
}
