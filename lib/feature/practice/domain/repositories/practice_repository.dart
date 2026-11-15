// Repository contract defining practice dashboard operations.
// Provides dashboard metrics retrieval and quiz action handling.
import 'repositories_imports.dart';

abstract interface class PracticeRepository {
  Future<Either<String, PracticeDashboardData>> getPracticeDashboard();
  Future<Either<String, PracticeDashboardData>> resumeQuiz(String quizId);
  Future<Either<String, PracticeDashboardData>> reviewQuizResults(
    String quizId,
  );
}
