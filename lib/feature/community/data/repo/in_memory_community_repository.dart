// Temporary CommunityRepository that keeps all community content in memory
// for this app run. Used until a real backend is connected: nothing is
// persisted, and every payload originates from the sample fixtures.
import 'in_memory_community_repository_dependencies.dart';

class InMemoryCommunityRepository implements CommunityRepository {
  InMemoryCommunityRepository({
    this.latency = const Duration(milliseconds: 400),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  /// Simulated round trip so loading states are visible during review.
  final Duration latency;
  final DateTime Function() _now;

  List<CommunityPost>? _posts;
  List<ActivityEntry>? _activity;
  int _publishedCount = 0;

  void _ensureSeeded() {
    if (_posts != null) return;
    final now = _now();
    _posts = [
      ...CommunityPostFixtures.feedPosts(now),
      ...CommunityPostFixtures.profilePosts(now),
    ];
    _activity = CommunityFixtures.activity(now);
  }

  Future<void> _simulate() => Future<void>.delayed(latency);

  @override
  Future<Either<CommunityFailure, List<CommunityPost>>> loadFeed({
    required String subject,
    required CommunityFeedSort sort,
  }) async {
    await _simulate();
    _ensureSeeded();
    var posts = List<CommunityPost>.of(_posts!);
    if (subject != CommunitySubjects.all) {
      posts = posts.where((post) => post.subject == subject).toList();
    }
    posts = switch (sort) {
      CommunityFeedSort.forYou => posts,
      CommunityFeedSort.latest =>
        posts.toList()..sort((a, b) => b.postedAt.compareTo(a.postedAt)),
      CommunityFeedSort.top =>
        posts.toList()..sort((a, b) => b.score.compareTo(a.score)),
    };
    return Right(posts);
  }

  @override
  Future<Either<CommunityFailure, CommunityProfile>> loadProfile() async {
    await _simulate();
    return const Right(CommunityFixtures.profile);
  }

  @override
  Future<Either<CommunityFailure, List<CommunityPost>>> loadProfilePosts({
    required CommunityProfileTab tab,
    required CommunityProfileSort sort,
  }) async {
    await _simulate();
    _ensureSeeded();
    var posts = _posts!.where((post) => post.author.isMe).toList();
    posts = switch (tab) {
      CommunityProfileTab.posts => posts,
      CommunityProfileTab.questions =>
        posts.where((post) => post.kind == CommunityPostKind.question).toList(),
      CommunityProfileTab.notes =>
        posts.where((post) => post.kind == CommunityPostKind.notes).toList(),
    };
    posts = switch (sort) {
      CommunityProfileSort.newest =>
        posts.toList()..sort((a, b) => b.postedAt.compareTo(a.postedAt)),
      CommunityProfileSort.top =>
        posts.toList()..sort((a, b) => b.score.compareTo(a.score)),
    };
    return Right(posts);
  }

  @override
  Future<Either<CommunityFailure, List<ActivityEntry>>> loadActivity() async {
    await _simulate();
    _ensureSeeded();
    return Right(List<ActivityEntry>.of(_activity!));
  }

  @override
  Future<Either<CommunityFailure, PostQuestion>> loadSampleQuestion() async {
    await _simulate();
    return const Right(CommunityFixtures.sampleQuestion);
  }

  @override
  Future<Either<CommunityFailure, PostDocument>> loadSampleDocument() async {
    await _simulate();
    return const Right(CommunityFixtures.sampleDocument);
  }

  @override
  Future<Either<CommunityFailure, Map<String, List<String>>>> loadChapters() {
    return Future.value(const Right(CommunityFixtures.chapters));
  }

  @override
  Future<Either<CommunityFailure, CommunityPost>> publish({
    required PostDraft draft,
  }) async {
    await _simulate();
    _ensureSeeded();
    final question = draft.kind == CommunityPostKind.question
        ? CommunityFixtures.sampleQuestion
        : null;
    final document = draft.kind == CommunityPostKind.notes
        ? CommunityFixtures.sampleDocument
        : null;
    final subject =
        draft.subject ??
        switch (draft.kind) {
          CommunityPostKind.question =>
            CommunityFixtures.sampleQuestion.subject,
          _ => CommunitySubjects.biology,
        };
    final topic =
        draft.chapter ??
        switch (draft.kind) {
          CommunityPostKind.question => CommunityFixtures.sampleQuestion.topic,
          CommunityPostKind.notes => 'Cell Division',
          CommunityPostKind.discussion => subject,
        };
    final post = CommunityPost(
      id: 'published-${++_publishedCount}',
      author: CommunityFixtures.me,
      kind: draft.kind,
      subject: subject,
      topic: topic,
      title: draft.title.trim(),
      body: draft.body.trim().isEmpty ? null : draft.body.trim(),
      question: question,
      document: document,
      postedAt: _now(),
      score: 0,
      commentCount: 0,
    );
    _posts = [post, ..._posts!];
    _activity = [
      ActivityEntry(
        id: 'activity-${post.id}',
        kind: switch (draft.kind) {
          CommunityPostKind.question => ActivityKind.questionShared,
          CommunityPostKind.notes => ActivityKind.notesShared,
          CommunityPostKind.discussion => ActivityKind.postPublished,
        },
        title: switch (draft.kind) {
          CommunityPostKind.question => 'Question Shared',
          CommunityPostKind.notes => 'Notes Shared',
          CommunityPostKind.discussion => 'Post Published',
        },
        summary: post.title,
        subject: post.subject,
        at: post.postedAt,
      ),
      ..._activity!,
    ];
    return Right(post);
  }

  @override
  Future<Either<CommunityFailure, CommunityPost>> vote({
    required String postId,
    required VoteValue value,
  }) async {
    await _simulate();
    _ensureSeeded();
    final index = _posts!.indexWhere((post) => post.id == postId);
    if (index == -1) {
      return const Left(CommunityFailure.unavailable);
    }
    final current = _posts![index];
    // Tapping the active direction clears the vote.
    final next = current.myVote == value ? VoteValue.none : value;
    final score =
        current.score + _contribution(next) - _contribution(current.myVote);
    final updated = current.copyWith(score: score, myVote: next);
    _posts![index] = updated;
    return Right(updated);
  }

  @override
  Future<Either<CommunityFailure, CommunityPost>> setSaved({
    required String postId,
    required bool saved,
  }) async {
    await _simulate();
    _ensureSeeded();
    final index = _posts!.indexWhere((post) => post.id == postId);
    if (index == -1) {
      return const Left(CommunityFailure.unavailable);
    }
    final updated = _posts![index].copyWith(saved: saved);
    _posts![index] = updated;
    return Right(updated);
  }

  static int _contribution(VoteValue value) => switch (value) {
    VoteValue.up => 1,
    VoteValue.down => -1,
    VoteValue.none => 0,
  };
}
