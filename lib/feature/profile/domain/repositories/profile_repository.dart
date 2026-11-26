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

  /// Light gate read: true only when onboarding_completed_at is set.
  Future<Either<ProfileFailure, bool>> getOnboardingStatus();

  /// Persists the onboarding draft and stamps onboarding_completed_at.
  Future<Either<ProfileFailure, Unit>> completeOnboarding(
    OnboardingDraft draft,
  );

  /// Active education boards for the onboarding board selector.
  Future<Either<ProfileFailure, List<OnboardingBoard>>> getOnboardingBoards();
}
