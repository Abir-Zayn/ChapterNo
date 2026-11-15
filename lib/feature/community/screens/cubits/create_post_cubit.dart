// Drives the create-post flow: type switching, categorization, sample
// attachments, validation, and publishing. Blocks repeat publishes, keeps
// a sensible default subject per type, and never emits after close.
import 'create_post_cubit_dependencies.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit({required this.repository})
    : super(const CreatePostState(subject: CommunitySubjects.physics));

  final CommunityRepository repository;

  /// Loads the sample attachments and chapter list once.
  Future<void> loadAttachments() async {
    if (!state.attachmentsLoading) return;
    final question = await repository.loadSampleQuestion();
    final document = await repository.loadSampleDocument();
    final chapters = await repository.loadChapters();
    if (isClosed) return;
    emit(
      state.copyWith(
        attachmentsLoading: false,
        question: question.fold((_) => null, (value) => value),
        document: document.fold((_) => null, (value) => value),
        chapters: chapters.fold((_) => const {}, (value) => value),
      ),
    );
  }

  /// Switches the post type and seeds a default subject when none was
  /// chosen yet: the sample question is a Physics item, the sample notes
  /// document belongs to Biology.
  void setType(CommunityPostKind type) {
    if (type == state.type || state.isPublishing) return;
    final subject = switch (type) {
      CommunityPostKind.notes => CommunitySubjects.biology,
      CommunityPostKind.question => CommunitySubjects.physics,
      CommunityPostKind.discussion =>
        state.subject ?? CommunitySubjects.physics,
    };
    emit(state.copyWith(type: type, subject: subject, clearChapter: true));
  }

  void setSubject(String subject) {
    if (state.isPublishing || subject == state.subject) return;
    // A chapter chosen for another subject no longer applies.
    final chapters = state.chapters[subject] ?? const <String>[];
    final keepChapter = chapters.contains(state.chapter);
    emit(
      state.copyWith(
        subject: subject,
        chapter: keepChapter ? state.chapter : null,
        clearChapter: !keepChapter,
      ),
    );
  }

  void setChapter(String chapter) {
    if (state.isPublishing || chapter == state.chapter) return;
    emit(state.copyWith(chapter: chapter));
  }

  /// Validates the draft and publishes it. Validation problems surface as
  /// issues without a repository round trip.
  Future<void> publish({required String title, required String body}) async {
    if (state.isPublishing) return;
    final draft = PostDraft(
      kind: state.type,
      title: title,
      body: body,
      subject: state.subject,
      chapter: state.chapter,
    );
    final issues = PostDraftValidator.issuesOf(draft);
    if (issues.isNotEmpty) {
      emit(state.copyWith(status: CreatePostStatus.failure, issues: issues));
      return;
    }
    emit(
      state.copyWith(
        status: CreatePostStatus.publishing,
        issues: const [],
        failure: null,
      ),
    );
    final result = await repository.publish(draft: draft);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(status: CreatePostStatus.failure, failure: failure),
      ),
      (_) => emit(state.copyWith(status: CreatePostStatus.success)),
    );
  }

  /// Returns to the form after a failed attempt, keeping every choice.
  void reset() {
    emit(
      state.copyWith(
        status: CreatePostStatus.idle,
        issues: const [],
        failure: null,
      ),
    );
  }
}
