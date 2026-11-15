// State of the community activity log: the active filter plus the entries
// grouped into day sections, and per-filter counts for the filter sheet.
// Grouping labels are derived at load time from the entry timestamps.
import 'cubits_imports.dart';

enum ActivityLogStatus { initial, loading, ready, failure }

/// One chronological section of the log, such as Today or Yesterday.
class ActivityDayGroup extends Equatable {
  const ActivityDayGroup({
    required this.label,
    required this.subtitle,
    required this.entries,
  });

  final String label;
  final String subtitle;
  final List<ActivityEntry> entries;

  @override
  List<Object?> get props => [label, subtitle, entries];
}

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class ActivityLogState extends Equatable {
  const ActivityLogState({
    this.status = ActivityLogStatus.initial,
    this.filter = ActivityFilter.all,
    this.groups = const [],
    this.counts = const {},
    this.failure,
  });

  final ActivityLogStatus status;
  final ActivityFilter filter;
  final List<ActivityDayGroup> groups;

  /// How many entries each filter option would show.
  final Map<ActivityFilter, int> counts;
  final CommunityFailure? failure;

  @override
  List<Object?> get props => [status, filter, groups, counts, failure];

  ActivityLogState copyWith({
    ActivityLogStatus? status,
    ActivityFilter? filter,
    List<ActivityDayGroup>? groups,
    Map<ActivityFilter, int>? counts,
    CommunityFailure? failure,
  }) => ActivityLogState(
    status: status ?? this.status,
    filter: filter ?? this.filter,
    groups: groups ?? this.groups,
    counts: counts ?? this.counts,
    failure: failure ?? this.failure,
  );

  /// Groups [entries] into day sections relative to [now], newest first.
  static List<ActivityDayGroup> groupByDay(
    List<ActivityEntry> entries,
    DateTime now,
  ) {
    final sorted = entries.toList()..sort((a, b) => b.at.compareTo(a.at));
    final groups = <ActivityDayGroup>[];
    final startOfDay = DateTime(now.year, now.month, now.day);
    for (final entry in sorted) {
      final day = DateTime(entry.at.year, entry.at.month, entry.at.day);
      final dayDiff = startOfDay.difference(day).inDays;
      final last = groups.isEmpty ? null : groups.last;
      final sameDay =
          last != null && _dayKey(last.entries.last.at) == _dayKey(entry.at);
      if (sameDay) {
        groups[groups.length - 1] = ActivityDayGroup(
          label: last.label,
          subtitle: last.subtitle,
          entries: [...last.entries, entry],
        );
        continue;
      }
      final label = switch (dayDiff) {
        0 => 'Today',
        1 => 'Yesterday',
        >= 2 && <= 6 => 'Earlier This Week',
        _ => _fullDate(day),
      };
      groups.add(
        ActivityDayGroup(label: label, subtitle: '', entries: [entry]),
      );
    }
    return [for (final group in groups) _withSubtitle(group)];
  }

  static ActivityDayGroup _withSubtitle(ActivityDayGroup group) {
    if (group.label == 'Today') {
      final n = group.entries.length;
      return ActivityDayGroup(
        label: group.label,
        subtitle: '$n ${n == 1 ? 'action' : 'actions'}',
        entries: group.entries,
      );
    }
    final newest = group.entries.first.at;
    final oldest = group.entries.last.at;
    final sameDay = _dayKey(newest) == _dayKey(oldest);
    return ActivityDayGroup(
      label: group.label,
      subtitle: sameDay
          ? _fullDate(DateTime(newest.year, newest.month, newest.day))
          : '${_shortDate(DateTime(oldest.year, oldest.month, oldest.day))} '
                '– ${oldest.day}',
      entries: group.entries,
    );
  }

  static String _dayKey(DateTime value) =>
      '${value.year}-${value.month}-${value.day}';

  static String _shortDate(DateTime value) =>
      '${_months[value.month - 1]} ${value.day}';

  static String _fullDate(DateTime value) =>
      '${_months[value.month - 1]} ${value.day}, ${value.year}';
}
