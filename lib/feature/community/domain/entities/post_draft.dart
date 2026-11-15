// The publish intent for a new community post, before it exists.
// Text a student typed plus the categorization they chose; attachments are
// associated server-side by the repository, never trusted from the client.
import 'post_draft_dependencies.dart';

class PostDraft extends Equatable {
  const PostDraft({
    required this.kind,
    required this.title,
    required this.body,
    this.subject,
    this.chapter,
  });

  final CommunityPostKind kind;

  /// Trimmed or raw title as typed; validation trims before checking.
  final String title;

  /// Optional commentary or description.
  final String body;

  /// Required for discussion and notes posts.
  final String? subject;

  /// Required for notes posts.
  final String? chapter;

  @override
  List<Object?> get props => [kind, title, body, subject, chapter];
}
