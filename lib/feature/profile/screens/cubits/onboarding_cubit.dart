// Drives the Onboarding form: loads education boards, tracks field
// entries, and submits the draft with recoverable failure handling.
import 'cubits_imports.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({required this._profileRepository})
    : super(const OnboardingState());

  final ProfileRepository _profileRepository;

  Future<void> loadBoards() async {
    if (state.isLoadingBoards || state.boards.isNotEmpty) return;
    emit(state.copyWith(isLoadingBoards: true, boardsError: null));
    final result = await _profileRepository.getOnboardingBoards();
    if (isClosed) return;
    result.fold(
      (_) => emit(
        state.copyWith(
          isLoadingBoards: false,
          boardsError: 'Could not load education boards.',
        ),
      ),
      (boards) => emit(state.copyWith(isLoadingBoards: false, boards: boards)),
    );
  }

  void updateDisplayName(String value) =>
      emit(state.copyWith(displayName: value, actionError: null));

  void selectBatchYear(int year) =>
      emit(state.copyWith(batchYear: year, actionError: null));

  void selectBoard(OnboardingBoard board) =>
      emit(state.copyWith(board: board, actionError: null));

  void selectAcademicGroup(String value) =>
      emit(state.copyWith(academicGroup: value, actionError: null));

  void selectLearningPace(String value) =>
      emit(state.copyWith(learningPace: value, actionError: null));

  /// Preserves every entered field on failure so the student can retry.
  Future<void> submit() async {
    if (state.isSubmitting || !state.canSubmit || state.completed) return;
    emit(state.copyWith(isSubmitting: true, actionError: null));
    final draft = OnboardingDraft(
      displayName: state.displayName.trim(),
      batchYear: state.batchYear,
      board: state.board,
      academicGroup: state.academicGroup,
      learningPace: state.learningPace,
    );
    final result = await _profileRepository.completeOnboarding(draft);
    if (isClosed) return;
    result.fold(
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          actionError:
              'Could not save your profile. Check your connection and try '
              'again.',
        ),
      ),
      (_) => emit(state.copyWith(isSubmitting: false, completed: true)),
    );
  }
}
