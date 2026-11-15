// Contract for fetching and updating student home dashboard data.
// Isolates business operations from remote or local storage implementations.
import 'repositories_imports.dart';

abstract interface class HomeRepository {
  /// Fetches the current student's dashboard metrics, goals, and history.
  Future<Either<String, StudentDashboard>> getDashboard();

  /// Updates the progress of the active daily target.
  Future<Either<String, StudentDashboard>> incrementGoalProgress();
}
