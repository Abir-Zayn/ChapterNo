// Loads the Community feed and applies sort and subject filters. Ignores
// obsolete responses, guards emissions after close, and
// applies vote/save updates to the already-loaded list.
import 'community_feed_cubit_dependencies.dart';

class CommunityFeedCubit extends Cubit<CommunityFeedState> {
  CommunityFeedCubit({required this.repository})
    : super(const CommunityFeedState());

  final CommunityRepository repository;
  int _request = 0;

  /// Loads current filters and ignores responses superseded by newer loads.
  Future<void> load() async {
    final request = ++_request;
    emit(state.copyWith(status: CommunityFeedStatus.loading));
    final result = await repository.loadFeed(
      subject: state.subject,
      sort: state.sort,
    );
    if (isClosed || request != _request) return;
    result.fold(
      (failure) => emit(
        state.copyWith(status: CommunityFeedStatus.failure, failure: failure),
      ),
      (posts) => emit(
        state.copyWith(
          status: CommunityFeedStatus.ready,
          posts: posts,
          failure: null,
        ),
      ),
    );
  }

  /// Reloads with a new ordering; a no-op when the sort is unchanged.
  Future<void> setSort(CommunityFeedSort sort) async {
    if (sort == state.sort) return;
    emit(state.copyWith(sort: sort));
    await load();
  }

  /// Reloads the current filters, for example after publishing a post.
  Future<void> refresh() => load();

  /// Reloads with a new subject filter; a no-op when unchanged.
  Future<void> setSubject(String subject) async {
    if (subject == state.subject) return;
    emit(state.copyWith(subject: subject));
    await load();
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
}
