// One entry in a student's community activity log.
import 'package:equatable/equatable.dart';

/// What kind of community action an entry records.
enum ActivityKind {
  postPublished,
  commented,
  upvoted,
  questionShared,
  notesShared,
}

/// Which community actions the activity log shows.
enum ActivityFilter { all, posts, comments, questions, notes, upvotes }

class ActivityEntry extends Equatable {
  const ActivityEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.summary,
    required this.subject,
    required this.at,
    this.detail,
  });

  final String id;
  final ActivityKind kind;

  /// Short action name, for example 'Post Published'.
  final String title;

  /// One-line description of the content the action touched.
  final String summary;

  /// Subject chip label for the entry.
  final String subject;

  /// Extra context such as reply counts or vote totals.
  final String? detail;
  final DateTime at;

  @override
  List<Object?> get props => [id, kind, title, summary, subject, detail, at];
}
