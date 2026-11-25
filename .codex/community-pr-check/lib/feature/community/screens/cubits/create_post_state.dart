// State of the create-post flow: selected type, categorization choices,
// sample attachments, and the publish outcome. Typed text lives in the form
// controllers so entered work survives validation failures.
import 'cubits_imports.dart';

enum CreatePostStatus { idle, publishing, success, failure }

class CreatePostState extends Equatable {
  const CreatePostState({
    this.type = CommunityPostKind.discussion,
    this.status = CreatePostStatus.idle,
    this.attachmentsLoading = true,
    this.question,
    this.document,
    this.chapters = const {},
    this.subject,
    this.chapter,
    this.issues = const [],
    this.failure,
  });

  final CommunityPostKind type;
  final CreatePostStatus status;

  /// While sample attachments load, forms show their loading state.
  final bool attachmentsLoading;
  final PostQuestion? question;
  final PostDocument? document;

  /// Chapter labels per subject for notes posts.
  final Map<String, List<String>> chapters;

  /// Chosen subject for discussion and notes posts.
  final String? subject;

  /// Chosen chapter for notes posts.
  final String? chapter;

  /// Validation issues from the last publish attempt, when it failed.
  final List<PostDraftIssue> issues;
  final CommunityFailure? failure;

  bool get isPublishing => status == CreatePostStatus.publishing;

  @override
  List<Object?> get props => [
    type,
    status,
    attachmentsLoading,
    question,
    document,
    chapters,
    subject,
    chapter,
    issues,
    failure,
  ];

  CreatePostState copyWith({
    CommunityPostKind? type,
    CreatePostStatus? status,
    bool? attachmentsLoading,
    PostQuestion? question,
    PostDocument? document,
    Map<String, List<String>>? chapters,
    String? subject,
    String? chapter,
    bool clearChapter = false,
    List<PostDraftIssue>? issues,
    CommunityFailure? failure,
  }) => CreatePostState(
    type: type ?? this.type,
    status: status ?? this.status,
    attachmentsLoading: attachmentsLoading ?? this.attachmentsLoading,
    question: question ?? this.question,
    document: document ?? this.document,
    chapters: chapters ?? this.chapters,
    subject: subject ?? this.subject,
    chapter: clearChapter ? null : chapter ?? this.chapter,
    issues: issues ?? this.issues,
    failure: failure ?? this.failure,
  );
}
