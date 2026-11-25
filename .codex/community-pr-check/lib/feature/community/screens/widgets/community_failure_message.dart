// Maps community failures and draft issues to short learner-facing copy.
// Keeps wording in one place so every community screen explains errors alike.
import 'community_failure_message_dependencies.dart';

extension CommunityFailureMessage on CommunityFailure {
  String get message => switch (this) {
    CommunityFailure.network =>
      'No internet connection. Check your connection and try again.',
    CommunityFailure.unavailable =>
      'This is not available yet. Please try again later.',
    CommunityFailure.unknown => 'Something went wrong. Please try again.',
  };
}

extension PostDraftIssueMessage on PostDraftIssue {
  String get message => switch (this) {
    PostDraftIssue.emptyTitle => 'Add a title before publishing.',
    PostDraftIssue.shortTitle =>
      'Make the title a little more descriptive first.',
    PostDraftIssue.longTitle => 'Shorten the title to 120 characters or less.',
    PostDraftIssue.missingSubject => 'Pick a subject for your post.',
    PostDraftIssue.missingChapter => 'Pick a chapter for your notes.',
  };
}
