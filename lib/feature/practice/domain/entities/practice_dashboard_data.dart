// Composite domain model representing the complete Practice Dashboard state.
// Aggregates overview metrics, recent quiz activities, modes, and streak data.
import 'entities_imports.dart';

class PracticeDashboardData {
  const PracticeDashboardData({
    required this.overview,
    required this.recentActivities,
    required this.practiceModes,
    required this.milestone,
  });

  final PracticeOverviewMetrics overview;
  final List<RecentQuizActivity> recentActivities;
  final List<PracticeModeItem> practiceModes;
  final DailyStreakMilestone milestone;

  PracticeDashboardData copyWith({
    PracticeOverviewMetrics? overview,
    List<RecentQuizActivity>? recentActivities,
    List<PracticeModeItem>? practiceModes,
    DailyStreakMilestone? milestone,
  }) {
    return PracticeDashboardData(
      overview: overview ?? this.overview,
      recentActivities: recentActivities ?? this.recentActivities,
      practiceModes: practiceModes ?? this.practiceModes,
      milestone: milestone ?? this.milestone,
    );
  }
}
