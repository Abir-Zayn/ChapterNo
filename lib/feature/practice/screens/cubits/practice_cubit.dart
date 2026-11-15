// Manages state and asynchronous actions for the Practice Dashboard.
// Loads practice metrics, handles quiz resumption and review triggers.
import 'cubits_imports.dart';

class PracticeCubit extends Cubit<PracticeState> {
  PracticeCubit({required this._practiceRepository})
    : super(const PracticeInitial());

  final PracticeRepository _practiceRepository;

  Future<void> loadDashboard() async {
    emit(const PracticeLoading());
    final result = await _practiceRepository.getPracticeDashboard();
    if (isClosed) return;

    result.fold(
      (failure) => emit(PracticeError(message: failure)),
      (data) => emit(PracticeLoaded(data: data)),
    );
  }

  Future<void> refreshDashboard() async {
    final result = await _practiceRepository.getPracticeDashboard();
    if (isClosed) return;

    result.fold(
      (failure) => emit(PracticeError(message: failure)),
      (data) => emit(PracticeLoaded(data: data)),
    );
  }

  Future<void> resumeQuiz(String quizId) async {
    final result = await _practiceRepository.resumeQuiz(quizId);
    if (isClosed) return;

    result.fold(
      (failure) => emit(PracticeError(message: failure)),
      (data) => emit(PracticeLoaded(data: data)),
    );
  }

  Future<void> reviewResults(String quizId) async {
    final result = await _practiceRepository.reviewQuizResults(quizId);
    if (isClosed) return;

    result.fold(
      (failure) => emit(PracticeError(message: failure)),
      (data) => emit(PracticeLoaded(data: data)),
    );
  }
}
