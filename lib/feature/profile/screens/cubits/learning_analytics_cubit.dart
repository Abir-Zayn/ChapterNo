// Manages Learning Analytics loading and timeframe switching.
// Ignores stale async responses when the student switches filters rapidly.
import 'cubits_imports.dart';
import 'learning_analytics_state.dart';

class LearningAnalyticsCubit extends Cubit<LearningAnalyticsState> {
  LearningAnalyticsCubit({required this._profileRepository})
    : super(const LearningAnalyticsInitial());

  final ProfileRepository _profileRepository;
  int _requestToken = 0;

  Future<void> load([
    AnalyticsTimeframe timeframe = AnalyticsTimeframe.weeks,
  ]) async {
    final token = ++_requestToken;
    final current = state;
    if (current is LearningAnalyticsLoaded) {
      emit(current.copyWith(isRefreshing: true, clearActionError: true));
    } else {
      emit(LearningAnalyticsLoading(timeframe));
    }

    final result = await _profileRepository.getAnalytics(timeframe);
    if (isClosed || token != _requestToken) return;

    result.fold((failure) {
      final latest = state;
      if (latest is LearningAnalyticsLoaded) {
        emit(
          latest.copyWith(isRefreshing: false, actionError: failure.message),
        );
      } else {
        emit(
          LearningAnalyticsError(
            timeframe: timeframe,
            message: failure.message,
          ),
        );
      }
    }, (analytics) => emit(LearningAnalyticsLoaded(analytics: analytics)));
  }

  Future<void> selectTimeframe(AnalyticsTimeframe timeframe) {
    return load(timeframe);
  }
}
