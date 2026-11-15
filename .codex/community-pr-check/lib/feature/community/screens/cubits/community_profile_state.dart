// State of the community profile dashboard: the public profile, the active
// tab and ordering, and that tab's posts.
import 'cubits_imports.dart';

enum CommunityProfileStatus { initial, loading, ready, failure }

class CommunityProfileState extends Equatable {
  const CommunityProfileState({
    this.status = CommunityProfileStatus.initial,
    this.profile,
    this.tab = CommunityProfileTab.posts,
    this.sort = CommunityProfileSort.newest,
    this.posts = const [],
    this.failure,
  });

  final CommunityProfileStatus status;
  final CommunityProfile? profile;
  final CommunityProfileTab tab;
  final CommunityProfileSort sort;
  final List<CommunityPost> posts;
  final CommunityFailure? failure;

  @override
  List<Object?> get props => [status, profile, tab, sort, posts, failure];

  CommunityProfileState copyWith({
    CommunityProfileStatus? status,
    CommunityProfile? profile,
    CommunityProfileTab? tab,
    CommunityProfileSort? sort,
    List<CommunityPost>? posts,
    CommunityFailure? failure,
  }) => CommunityProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    tab: tab ?? this.tab,
    sort: sort ?? this.sort,
    posts: posts ?? this.posts,
    failure: failure ?? this.failure,
  );
}
