// Immutable state hierarchy for the Learning Analytics screen.
// Tracks selected timeframe, loaded analytics, and recoverable errors.
import 'cubits_imports.dart';

sealed class LearningAnalyticsState extends Equatable {
  const LearningAnalyticsState();

  @override
  List<Object?> get props => [];
}

final class LearningAnalyticsInitial extends LearningAnalyticsState {
  const LearningAnalyticsInitial();
}

final class LearningAnalyticsLoading extends LearningAnalyticsState {
  const LearningAnalyticsLoading(this.timeframe);

  final AnalyticsTimeframe timeframe;

  @override
  List<Object?> get props => [timeframe];
}

final class LearningAnalyticsLoaded extends LearningAnalyticsState {
  const LearningAnalyticsLoaded({
    required this.analytics,
    this.isRefreshing = false,
    this.actionError,
  });

  final LearningAnalytics analytics;
  final bool isRefreshing;
  final String? actionError;

  LearningAnalyticsLoaded copyWith({
    LearningAnalytics? analytics,
    bool? isRefreshing,
    String? actionError,
    bool clearActionError = false,
  }) {
    return LearningAnalyticsLoaded(
      analytics: analytics ?? this.analytics,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [analytics, isRefreshing, actionError];
}

final class LearningAnalyticsError extends LearningAnalyticsState {
  const LearningAnalyticsError({
    required this.timeframe,
    required this.message,
  });

  final AnalyticsTimeframe timeframe;
  final String message;

  @override
  List<Object?> get props => [timeframe, message];
}
