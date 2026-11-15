// Contract for community data access, implemented by data-layer repos.
// Presentation depends on this interface only, so the in-memory demo
// repository can later be swapped for a real backend without UI changes.
import 'community_repository_dependencies.dart';

abstract interface class CommunityRepository {
  /// Posts for the Community feed, filtered by [CommunitySubjects.all] or a
  /// concrete subject and ordered by [sort].
  Future<Either<CommunityFailure, List<CommunityPost>>> loadFeed({
    required String subject,
    required CommunityFeedSort sort,
  });

  Future<Either<CommunityFailure, CommunityProfile>> loadProfile();

  /// The signed-in student's own posts for the profile dashboard tabs.
  Future<Either<CommunityFailure, List<CommunityPost>>> loadProfilePosts({
    required CommunityProfileTab tab,
    required CommunityProfileSort sort,
  });

  Future<Either<CommunityFailure, List<ActivityEntry>>> loadActivity();

  /// A question the student can attach to a practice-question post.
  Future<Either<CommunityFailure, PostQuestion>> loadSampleQuestion();

  /// A document the student can attach to a notes post.
  Future<Either<CommunityFailure, PostDocument>> loadSampleDocument();

  /// Chapter labels per subject, used when categorizing notes posts.
  Future<Either<CommunityFailure, Map<String, List<String>>>> loadChapters();

  /// Publishes a draft and returns the created post.
  Future<Either<CommunityFailure, CommunityPost>> publish({
    required PostDraft draft,
  });

  /// Replaces the caller's vote on a post and returns the updated post.
  Future<Either<CommunityFailure, CommunityPost>> vote({
    required String postId,
    required VoteValue value,
  });

  /// Saves or unsaves a post and returns the updated post.
  Future<Either<CommunityFailure, CommunityPost>> setSaved({
    required String postId,
    required bool saved,
  });
}
