// Domain contract for loading and updating Profile, Analytics, and Settings.
// Implemented by data repositories; presentation depends only on this.
import 'repositories_imports.dart';

abstract class ProfileRepository {
  Future<Either<ProfileFailure, StudentProfile>> getProfile();

  Future<Either<ProfileFailure, StudentProfile>> updateLearningPace(
    String pace,
  );

  Future<Either<ProfileFailure, LearningAnalytics>> getAnalytics(
    AnalyticsTimeframe timeframe,
  );

  Future<Either<ProfileFailure, AppSettings>> getSettings();

  Future<Either<ProfileFailure, AppSettings>> updateSettings(
    AppSettings settings,
  );
}
