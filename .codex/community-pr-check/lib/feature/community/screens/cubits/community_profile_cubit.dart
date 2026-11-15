// Loads the public profile and the posts for the active dashboard tab.
// Tab and sort changes reload that list; a failure keeps the last profile
// and filters so retry repeats the same query.
import 'community_profile_cubit_dependencies.dart';

class CommunityProfileCubit extends Cubit<CommunityProfileState> {
  CommunityProfileCubit({required this.repository})
    : super(const CommunityProfileState());

  final CommunityRepository repository;

  /// Loads the profile and the posts for the current tab together.
  Future<void> load() async {
    if (state.status == CommunityProfileStatus.loading) return;
    emit(state.copyWith(status: CommunityProfileStatus.loading));
    final (profileResult, postsResult) = await (
      repository.loadProfile(),
      repository.loadProfilePosts(tab: state.tab, sort: state.sort),
    ).wait;
    if (isClosed) return;
    profileResult.fold(
      (failure) => emit(
        state.copyWith(
          status: CommunityProfileStatus.failure,
          failure: failure,
        ),
      ),
      (profile) => emit(state.copyWith(profile: profile)),
    );
    if (state.status == CommunityProfileStatus.failure) return;
    postsResult.fold(
      (failure) => emit(
        state.copyWith(
          status: CommunityProfileStatus.failure,
          failure: failure,
        ),
      ),
      (posts) => emit(
        state.copyWith(
          status: CommunityProfileStatus.ready,
          posts: posts,
          failure: null,
        ),
      ),
    );
  }

  /// Switches the dashboard tab and reloads its posts.
  Future<void> setTab(CommunityProfileTab tab) async {
    if (tab == state.tab || state.status == CommunityProfileStatus.loading) {
      return;
    }
    emit(state.copyWith(tab: tab));
    await _reloadPosts();
  }

  /// Changes the ordering and reloads the current tab.
  Future<void> setSort(CommunityProfileSort sort) async {
    if (sort == state.sort || state.status == CommunityProfileStatus.loading) {
      return;
    }
    emit(state.copyWith(sort: sort));
    await _reloadPosts();
  }

  /// Replaces the caller's vote on one post and patches the loaded list.
  Future<void> vote(String postId, VoteValue value) async {
    final result = await repository.vote(postId: postId, value: value);
    if (isClosed) return;
    result.fold(
      (_) {},
      (updated) => emit(
        state.copyWith(
          posts: [
            for (final post in state.posts)
              post.id == updated.id ? updated : post,
          ],
        ),
      ),
    );
  }

  /// Saves or unsaves one post and patches the loaded list.
  Future<void> toggleSaved(String postId) async {
    final current = state.posts.where((post) => post.id == postId).firstOrNull;
    if (current == null) return;
    final result = await repository.setSaved(
      postId: postId,
      saved: !current.saved,
    );
    if (isClosed) return;
    result.fold(
      (_) {},
      (updated) => emit(
        state.copyWith(
          posts: [
            for (final post in state.posts)
              post.id == updated.id ? updated : post,
          ],
        ),
      ),
    );
  }

  Future<void> _reloadPosts() async {
    emit(state.copyWith(status: CommunityProfileStatus.loading));
    final result = await repository.loadProfilePosts(
      tab: state.tab,
      sort: state.sort,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CommunityProfileStatus.failure,
          failure: failure,
        ),
      ),
      (posts) => emit(
        state.copyWith(status: CommunityProfileStatus.ready, posts: posts),
      ),
    );
  }
}
