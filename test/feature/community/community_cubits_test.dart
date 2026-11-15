// Exercises initial loads, local publishing, and stale-response handling.
// Uses deterministic fixtures and controlled responses without live services.
import 'community_cubits_test_dependencies.dart';

void main() {
  test('initial loads leave loading and profile tabs work', () async {
    final repo = InMemoryCommunityRepository(latency: Duration.zero);
    final feed = CommunityFeedCubit(repository: repo);
    final profile = CommunityProfileCubit(repository: repo);
    final activity = ActivityLogCubit(repository: repo);
    addTearDown(feed.close);
    addTearDown(profile.close);
    addTearDown(activity.close);
    await Future.wait([feed.load(), profile.load(), activity.load()]);
    expect(feed.state.status, CommunityFeedStatus.ready);
    expect(profile.state.status, CommunityProfileStatus.ready);
    expect(activity.state.status, ActivityLogStatus.ready);
    await profile.setTab(CommunityProfileTab.notes);
    expect(
      profile.state.posts.every((post) => post.kind == CommunityPostKind.notes),
      isTrue,
    );
    activity.setFilter(ActivityFilter.notes);
    expect(
      activity.state.groups
          .expand((g) => g.entries)
          .every((e) => e.kind == ActivityKind.notesShared),
      isTrue,
    );
  });

  for (final kind in CommunityPostKind.values) {
    test('publishes $kind locally and adds activity', () async {
      final repo = InMemoryCommunityRepository(latency: Duration.zero);
      final cubit = CreatePostCubit(repository: repo);
      addTearDown(cubit.close);
      await cubit.loadAttachments();
      cubit.setType(kind);
      if (kind == CommunityPostKind.notes) {
        cubit.setChapter(cubit.state.chapters[cubit.state.subject]!.first);
      }
      await cubit.publish(
        title: 'A useful sample learning post',
        body: 'Sample explanation',
      );
      expect(cubit.state.status, CreatePostStatus.success);
      final posts = (await repo.loadFeed(
        subject: CommunitySubjects.all,
        sort: CommunityFeedSort.latest,
      )).getOrElse(() => []);
      expect(posts.first.kind, kind);
      final entries = (await repo.loadActivity()).getOrElse(() => []);
      expect(entries.first.summary, posts.first.title);
    });
  }

  test('latest filter wins when an older request finishes last', () async {
    final repo = ControlledFeedRepository();
    final cubit = CommunityFeedCubit(repository: repo);
    addTearDown(cubit.close);
    final first = cubit.load();
    final second = cubit.setSubject(CommunitySubjects.biology);
    repo.requests[1].complete(const Right([]));
    await second;
    repo.requests[0].complete(const Left(CommunityFailure.network));
    await first;
    expect(cubit.state.status, CommunityFeedStatus.ready);
    expect(cubit.state.subject, CommunitySubjects.biology);
  });

  test('failure supports retry and pending load tolerates close', () async {
    final repo = ControlledFeedRepository();
    final cubit = CommunityFeedCubit(repository: repo);
    final first = cubit.load();
    repo.requests[0].complete(const Left(CommunityFailure.network));
    await first;
    expect(cubit.state.status, CommunityFeedStatus.failure);
    final retry = cubit.load();
    repo.requests[1].complete(const Right([]));
    await retry;
    expect(cubit.state.status, CommunityFeedStatus.ready);
    final pending = cubit.load();
    await cubit.close();
    repo.requests[2].complete(const Right([]));
    await pending;
  });
}

class ControlledFeedRepository extends InMemoryCommunityRepository {
  final requests = <Completer<Either<CommunityFailure, List<CommunityPost>>>>[];
  @override
  Future<Either<CommunityFailure, List<CommunityPost>>> loadFeed({
    required String subject,
    required CommunityFeedSort sort,
  }) {
    final response = Completer<Either<CommunityFailure, List<CommunityPost>>>();
    requests.add(response);
    return response.future;
  }
}
