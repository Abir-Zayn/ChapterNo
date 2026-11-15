// Immutable domain entities for Learning Analytics metrics, breakdowns,
// subject performance, and priority revision topics.
import 'entities_imports.dart';

enum AnalyticsTimeframe {
  days('Days'),
  weeks('Weeks'),
  months('Months'),
  allTime('All Time');

  const AnalyticsTimeframe(this.label);
  final String label;
}

class DailyStudyVolume extends Equatable {
  const DailyStudyVolume({
    required this.dayLabel,
    required this.questionsSolved,
    this.isHighlight = false,
  });

  final String dayLabel;
  final int questionsSolved;
  final bool isHighlight;

  @override
  List<Object?> get props => [dayLabel, questionsSolved, isHighlight];
}

class SubjectPerformance extends Equatable {
  const SubjectPerformance({
    required this.subject,
    required this.solvedCount,
    required this.accuracyPercent,
  });

  final String subject;
  final int solvedCount;
  final int accuracyPercent;

  @override
  List<Object?> get props => [subject, solvedCount, accuracyPercent];
}

class PriorityTopic extends Equatable {
  const PriorityTopic({
    required this.subject,
    required this.accuracyPercent,
    required this.topicTitle,
    required this.actionTag,
  });

  final String subject;
  final int accuracyPercent;
  final String topicTitle;
  final String actionTag;

  @override
  List<Object?> get props => [subject, accuracyPercent, topicTitle, actionTag];
}

class LearningAnalytics extends Equatable {
  LearningAnalytics({
    required this.timeframe,
    required this.cohortRankLabel,
    required this.streakDays,
    required this.mcqsSolved,
    required this.mcqsDeltaLabel,
    required this.accuracyPercent,
    required this.accuracyDeltaLabel,
    required this.cqsPracticed,
    required this.cqsEvaluatedCount,
    required this.avgCqScore,
    required this.targetCqScore,
    required this.lastCqScore,
    required this.totalSolvedVolume,
    required this.focusTip,
    required List<DailyStudyVolume> weeklyVolume,
    required List<SubjectPerformance> subjects,
    required this.totalTopics,
    required this.strongTopics,
    required this.inProgressTopics,
    required this.unexploredTopics,
    required List<PriorityTopic> priorityTopics,
    required this.recommendedMinutes,
    required this.recommendedTitle,
    required this.recommendedDescription,
  }) : weeklyVolume = List.unmodifiable(weeklyVolume),
       subjects = List.unmodifiable(subjects),
       priorityTopics = List.unmodifiable(priorityTopics);

  final AnalyticsTimeframe timeframe;
  final String cohortRankLabel;
  final int streakDays;
  final int mcqsSolved;
  final String mcqsDeltaLabel;
  final int accuracyPercent;
  final String accuracyDeltaLabel;
  final int cqsPracticed;
  final int cqsEvaluatedCount;
  final double avgCqScore;
  final double targetCqScore;
  final double lastCqScore;
  final int totalSolvedVolume;
  final String focusTip;
  final List<DailyStudyVolume> weeklyVolume;
  final List<SubjectPerformance> subjects;
  final int totalTopics;
  final int strongTopics;
  final int inProgressTopics;
  final int unexploredTopics;
  final List<PriorityTopic> priorityTopics;
  final int recommendedMinutes;
  final String recommendedTitle;
  final String recommendedDescription;

  @override
  List<Object?> get props => [
    timeframe,
    cohortRankLabel,
    streakDays,
    mcqsSolved,
    mcqsDeltaLabel,
    accuracyPercent,
    accuracyDeltaLabel,
    cqsPracticed,
    cqsEvaluatedCount,
    avgCqScore,
    targetCqScore,
    lastCqScore,
    totalSolvedVolume,
    focusTip,
    weeklyVolume,
    subjects,
    totalTopics,
    strongTopics,
    inProgressTopics,
    unexploredTopics,
    priorityTopics,
    recommendedMinutes,
    recommendedTitle,
    recommendedDescription,
  ];
}
