// The Community tab: subject/sort filters above a stream of question,
// notes, and discussion posts, with the create-post entry point.
// Data comes from CommunityFeedCubit; unavailable features say so plainly.
import 'community_feed_page_imports.dart';

class CommunityFeedPage extends StatefulWidget {
  const CommunityFeedPage({
    super.key,
    required this.onOpenCreatePost,
    required this.onOpenProfile,
    this.onTabSelected,
  });

  /// Opens the create-post flow; the feed refreshes after it returns.
  final Future<void> Function() onOpenCreatePost;
  final VoidCallback onOpenProfile;

  /// Root tab navigation; when null the bottom nav is hidden.
  final ValueChanged<HomeNavTab>? onTabSelected;

  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage> {
  Future<void> _openCreatePost() async {
    await widget.onOpenCreatePost();
    if (!mounted) return;
    context.read<CommunityFeedCubit>().refresh();
  }

  void _notAvailable(String feature) {
    AppSnackBar.show(context, '$feature is not available yet.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommunityFeedTopBar(
        onOpenProfile: widget.onOpenProfile,
        onSearch: () => _notAvailable('Community search'),
        onOpenMessages: () => _notAvailable('Messages'),
      ),
      bottomNavigationBar: switch (widget.onTabSelected) {
        final onTab? => HomeBottomNav(
          currentTab: HomeNavTab.community,
          onTabSelected: (tab) {
            if (tab != HomeNavTab.community) onTab(tab);
          },
        ),
        null => null,
      },
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePost,
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedPencilEdit02,
          size: AppSizes.iconMd,
          color: context.onPrimary,
        ),
        label: AppText.label('New Post'),
      ),
      body: BlocBuilder<CommunityFeedCubit, CommunityFeedState>(
        builder: (context, state) {
          if (state.status == CommunityFeedStatus.loading) {
            return const AppLoader(message: 'Loading the community…');
          }
          final failure = state.failure;
          if (state.status == CommunityFeedStatus.failure) {
            return AppStateView.error(
              title: 'Could not load the feed',
              message: failure?.message,
              onAction: () => context.read<CommunityFeedCubit>().load(),
            );
          }
          return Column(
            children: [
              FeedFilterBar(
                subject: state.subject,
                onSubject: context.read<CommunityFeedCubit>().setSubject,
              ),
              Expanded(
                child: state.posts.isEmpty
                    ? AppStateView(
                        icon: PhosphorIconsRegular.chatTeardropText,
                        title: 'No ${state.subject} posts yet',
                        message: 'Try another subject or start a discussion.',
                        actionLabel: 'Show all subjects',
                        onAction: () => context
                            .read<CommunityFeedCubit>()
                            .setSubject(CommunitySubjects.all),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.huge,
                        ),
                        itemCount: state.posts.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          final post = state.posts[index];
                          return PostCard(
                            post: post,
                            onVote: (value) => context
                                .read<CommunityFeedCubit>()
                                .vote(post.id, value),
                            onToggleSaved: () => context
                                .read<CommunityFeedCubit>()
                                .toggleSaved(post.id),
                            onOpenQuestion: () =>
                                _notAvailable('Solving shared questions'),
                            onOpenDocument: () => _notAvailable('Opening PDFs'),
                            onMore: () => _notAvailable('Post options'),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
