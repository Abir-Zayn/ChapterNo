// Validates a post draft before publishing. Rules live here so the form
// and the Cubit enforce identical limits, and titles stay readable.
import 'post_draft_validator_dependencies.dart';

enum PostDraftIssue {
  emptyTitle,
  shortTitle,
  longTitle,
  missingSubject,
  missingChapter,
}

abstract final class PostDraftValidator {
  static const int titleMinLength = 8;
  static const int titleMaxLength = 120;
  static const int bodyMaxLength = 2000;

  /// All issues blocking [draft] from being published, in field order.
  static List<PostDraftIssue> issuesOf(PostDraft draft) {
    final issues = <PostDraftIssue>[];
    final title = draft.title.trim();

    if (title.isEmpty) {
      issues.add(PostDraftIssue.emptyTitle);
    } else if (title.length < titleMinLength) {
      issues.add(PostDraftIssue.shortTitle);
    } else if (title.length > titleMaxLength) {
      issues.add(PostDraftIssue.longTitle);
    }

    final subject = draft.subject?.trim();
    switch (draft.kind) {
      case CommunityPostKind.discussion:
        if (subject == null || subject.isEmpty) {
          issues.add(PostDraftIssue.missingSubject);
        }
      case CommunityPostKind.notes:
        if (subject == null || subject.isEmpty) {
          issues.add(PostDraftIssue.missingSubject);
        }
        final chapter = draft.chapter?.trim();
        if (chapter == null || chapter.isEmpty) {
          issues.add(PostDraftIssue.missingChapter);
        }
      case CommunityPostKind.question:
        // The attached practice question supplies the categorization.
        break;
    }
    return issues;
  }

  /// Field-level error for the title input, or null when acceptable.
  static String? titleFieldError(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return 'Add a title so classmates know the topic.';
    if (title.length < titleMinLength) {
      return 'Make the title a little more descriptive ($titleMinLength+ characters).';
    }
    if (title.length > titleMaxLength) {
      return 'Keep the title within $titleMaxLength characters.';
    }
    return null;
  }

  /// Field-level error for the optional body, or null when acceptable.
  static String? bodyFieldError(String? value) {
    if ((value?.trim().length ?? 0) > bodyMaxLength) {
      return 'Keep the description within $bodyMaxLength characters.';
    }
    return null;
  }

  /// Whether [subject] is an offerable choice for creating a post.
  static bool isSelectableSubject(String subject) =>
      CommunitySubjects.selectable.contains(subject);
}
