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
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        title: AppText.headline('Community'),
        actions: [
          CommunityIconButton(
            icon: HugeIcons.strokeRoundedSearch01,
            tooltip: 'Search community',
            onPressed: () => _notAvailable('Community search'),
          ),
          CommunityIconButton(
            icon: HugeIcons.strokeRoundedNotification01,
            tooltip: 'Notifications',
            onPressed: () => _notAvailable('Notifications'),
          ),
          const SizedBox(width: AppSpacing.sm),
          Semantics(
            button: true,
            label: 'My community profile',
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: widget.onOpenProfile,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: const CommunityAvatar(initials: 'AR'),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
        ],
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
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedPencilEdit02,
          size: AppSizes.iconMd,
          color: AppColors.onPrimary,
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
                sort: state.sort,
                subject: state.subject,
                onSort: context.read<CommunityFeedCubit>().setSort,
                onSubject: context.read<CommunityFeedCubit>().setSubject,
                onMoreFilters: () => _notAvailable('More feed filters'),
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
                            onComments: () => _notAvailable('Conversations'),
                            onShare: () => _notAvailable('Sharing posts'),
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
