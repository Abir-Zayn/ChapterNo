// Relative and calendar date labels for community screens. Pure functions
// so tests can pin the clock; English-only for the current design phase.
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

/// Compact relative label, for example '25m ago' or '2d ago'.
String formatCommunityTimeAgo(DateTime at, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final difference = reference.difference(at);
  if (difference.isNegative || difference.inSeconds < 45) return 'just now';
  final minutes = difference.inMinutes;
  if (minutes < 60) return '${minutes}m ago';
  final hours = difference.inHours;
  if (hours < 24) return '${hours}h ago';
  final days = difference.inDays;
  if (days < 7) return '${days}d ago';
  if (days < 30) return '${days ~/ 7}w ago';
  return formatCommunityShortDate(at);
}

/// Short calendar label, for example 'Jul 21'.
String formatCommunityShortDate(DateTime value) =>
    '${_months[value.month - 1]} ${value.day}';

/// Full calendar label, for example 'Jul 21, 2026'.
String formatCommunityFullDate(DateTime value) =>
    '${_months[value.month - 1]} ${value.day}, ${value.year}';
