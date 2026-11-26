// Immutable state for the Onboarding flow: draft entries, board options,
// submission progress, and transient errors surfaced to the page.
import 'cubits_imports.dart';

class OnboardingState extends Equatable {
  const OnboardingState({
    this.displayName = '',
    this.batchYear,
    this.board,
    this.academicGroup,
    this.learningPace = 'standard',
    this.boards = const [],
    this.isLoadingBoards = false,
    this.boardsError,
    this.isSubmitting = false,
    this.actionError,
    this.completed = false,
  });

  static const Object _unset = Object();

  final String displayName;
  final int? batchYear;
  final OnboardingBoard? board;
  final String? academicGroup;
  final String learningPace;
  final List<OnboardingBoard> boards;
  final bool isLoadingBoards;
  final String? boardsError;
  final bool isSubmitting;
  final String? actionError;
  final bool completed;

  /// True when every required entry is present and nothing is in flight.
  bool get canSubmit =>
      !isSubmitting &&
      !completed &&
      OnboardingDraft.validateDisplayName(displayName) == null &&
      batchYear != null &&
      board != null &&
      academicGroup != null;

  OnboardingState copyWith({
    String? displayName,
    int? batchYear,
    OnboardingBoard? board,
    String? academicGroup,
    String? learningPace,
    List<OnboardingBoard>? boards,
    bool? isLoadingBoards,
    Object? boardsError = _unset,
    bool? isSubmitting,
    Object? actionError = _unset,
    bool? completed,
  }) {
    return OnboardingState(
      displayName: displayName ?? this.displayName,
      batchYear: batchYear ?? this.batchYear,
      board: board ?? this.board,
      academicGroup: academicGroup ?? this.academicGroup,
      learningPace: learningPace ?? this.learningPace,
      boards: boards ?? this.boards,
      isLoadingBoards: isLoadingBoards ?? this.isLoadingBoards,
      boardsError: boardsError == _unset
          ? this.boardsError
          : boardsError as String?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionError: actionError == _unset
          ? this.actionError
          : actionError as String?,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object?> get props => [
    displayName,
    batchYear,
    board,
    academicGroup,
    learningPace,
    boards,
    isLoadingBoards,
    boardsError,
    isSubmitting,
    actionError,
    completed,
  ];
}
