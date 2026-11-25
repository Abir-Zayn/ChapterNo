// State of the Community feed: status, active filters, and visible posts.
// Immutable with value equality; a failure keeps the last filters so retry
// repeats the same query.
import 'cubits_imports.dart';

enum CommunityFeedStatus { initial, loading, ready, failure }

class CommunityFeedState extends Equatable {
  const CommunityFeedState({
    this.status = CommunityFeedStatus.initial,
    this.sort = CommunityFeedSort.forYou,
    this.subject = CommunitySubjects.all,
    this.posts = const [],
    this.failure,
  });

  final CommunityFeedStatus status;
  final CommunityFeedSort sort;

  /// [CommunitySubjects.all] or a concrete subject.
  final String subject;
  final List<CommunityPost> posts;
  final CommunityFailure? failure;

  bool get isFiltering => subject != CommunitySubjects.all;

  @override
  List<Object?> get props => [status, sort, subject, posts, failure];

  CommunityFeedState copyWith({
    CommunityFeedStatus? status,
    CommunityFeedSort? sort,
    String? subject,
    List<CommunityPost>? posts,
    CommunityFailure? failure,
  }) => CommunityFeedState(
    status: status ?? this.status,
    sort: sort ?? this.sort,
    subject: subject ?? this.subject,
    posts: posts ?? this.posts,
    failure: failure ?? this.failure,
  );
}
