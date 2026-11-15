// Public community profile dashboard: privacy-safe header, contribution
// stats, the Posts/Questions/Notes tabs with ordering, the student's own
// posts, and a note about what stays private.
import 'community_profile_page_imports.dart';

class CommunityProfilePage extends StatelessWidget {
  const CommunityProfilePage({super.key, required this.onOpenActivityLog});

  /// Opens the chronological community activity log.
  final VoidCallback onOpenActivityLog;

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
        title: AppText.title('My Community Profile'),
        actions: [
          AppIconButton(
            icon: PhosphorIconsRegular.clockCounterClockwise,
            tooltip: 'Activity log',
            onPressed: onOpenActivityLog,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: BlocBuilder<CommunityProfileCubit, CommunityProfileState>(
        builder: (context, state) {
          if (state.status == CommunityProfileStatus.loading) {
            return const AppLoader(message: 'Loading your profile…');
          }
          final failure = state.failure;
          if (state.status == CommunityProfileStatus.failure ||
              state.profile == null) {
            return AppStateView.error(
              title: 'Could not load your profile',
              message: failure?.message,
              onAction: () => context.read<CommunityProfileCubit>().load(),
            );
          }
          final profile = state.profile!;
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.huge,
                  ),
                  itemCount: state.posts.length + 3,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ProfileHeaderCard(
                        profile: profile,
                        onEdit: () =>
                            _notAvailable(context, 'Editing profiles'),
                      );
                    }
                    if (index == 1) {
                      return ProfileTabsBar(
                        tab: state.tab,
                        sort: state.sort,
                        stats: profile.stats,
                        onTab: context.read<CommunityProfileCubit>().setTab,
                        onSort: context.read<CommunityProfileCubit>().setSort,
                        showingLabel:
                            'Showing ${state.posts.length} of '
                            '${_tabTotal(profile, state.tab)}',
                      );
                    }
                    if (index <= state.posts.length + 1) {
                      final post = state.posts[index - 2];
                      return PostCard(
                        post: post,
                        showAuthor: false,
                        onVote: (value) => context
                            .read<CommunityProfileCubit>()
                            .vote(post.id, value),
                        onComments: () =>
                            _notAvailable(context, 'Conversations'),
                        onShare: () => _notAvailable(context, 'Sharing posts'),
                        onToggleSaved: () => context
                            .read<CommunityProfileCubit>()
                            .toggleSaved(post.id),
                        onOpenQuestion: () =>
                            _notAvailable(context, 'Solving shared questions'),
                        onOpenDocument: () =>
                            _notAvailable(context, 'Opening PDFs'),
                        onMore: () => _notAvailable(context, 'Post options'),
                      );
                    }
                    return const _PrivacyFooter();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static int _tabTotal(CommunityProfile profile, CommunityProfileTab tab) =>
      switch (tab) {
        CommunityProfileTab.posts => profile.stats.posts,
        CommunityProfileTab.questions => profile.stats.questions,
        CommunityProfileTab.notes => profile.stats.notes,
      };

  static void _notAvailable(BuildContext context, String feature) {
    AppSnackBar.show(context, '$feature is not available yet.');
  }
}

class _PrivacyFooter extends StatelessWidget {
  const _PrivacyFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            PhosphorIconsRegular.lockSimple,
            size: AppSizes.iconSm,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppText.caption(
          'Showing public contributions. Private practice history, chapter '
          'test scores, and diagnostic reports remain strictly confidential.',
          textAlign: TextAlign.center,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
