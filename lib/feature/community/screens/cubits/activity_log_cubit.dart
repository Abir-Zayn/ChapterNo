// Loads the activity history once and re-derives the visible groups when
// the student changes the filter. No repository round trip on filtering,
// and no emissions after close.
import 'activity_log_cubit_dependencies.dart';

class ActivityLogCubit extends Cubit<ActivityLogState> {
  ActivityLogCubit({required this.repository, DateTime Function()? now})
    : _now = now ?? DateTime.now,
      super(const ActivityLogState());

  final CommunityRepository repository;
  final DateTime Function() _now;

  List<ActivityEntry> _entries = const [];

  Future<void> load() async {
    if (state.status == ActivityLogStatus.loading) return;
    emit(state.copyWith(status: ActivityLogStatus.loading));
    final result = await repository.loadActivity();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(status: ActivityLogStatus.failure, failure: failure),
      ),
      (entries) {
        _entries = entries;
        emit(
          state.copyWith(
            status: ActivityLogStatus.ready,
            counts: _countsFor(entries),
            groups: _groupsFor(state.filter),
            failure: null,
          ),
        );
      },
    );
  }

  /// Switches the visible category and re-derives the groups in place.
  void setFilter(ActivityFilter filter) {
    if (filter == state.filter || state.status == ActivityLogStatus.loading) {
      return;
    }
    emit(state.copyWith(filter: filter, groups: _groupsFor(filter)));
  }

  List<ActivityDayGroup> _groupsFor(ActivityFilter filter) =>
      ActivityLogState.groupByDay(
        _entries.where((entry) => _matches(entry.kind, filter)).toList(),
        _now(),
      );

  static bool _matches(ActivityKind kind, ActivityFilter filter) =>
      switch (filter) {
        ActivityFilter.all => true,
        ActivityFilter.posts => kind == ActivityKind.postPublished,
        ActivityFilter.comments => kind == ActivityKind.commented,
        ActivityFilter.questions => kind == ActivityKind.questionShared,
        ActivityFilter.notes => kind == ActivityKind.notesShared,
        ActivityFilter.upvotes => kind == ActivityKind.upvoted,
      };

  static Map<ActivityFilter, int> _countsFor(List<ActivityEntry> entries) => {
    for (final filter in ActivityFilter.values)
      filter: entries.where((entry) => _matches(entry.kind, filter)).length,
  };
}
