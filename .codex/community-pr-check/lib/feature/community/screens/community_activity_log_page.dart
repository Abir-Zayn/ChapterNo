// Chronological community activity log grouped into day sections, with a
// category filter applied through a bottom sheet. Unavailable destinations
// such as opening an activity's post say so plainly.
import 'community_activity_log_page_imports.dart';

class CommunityActivityLogPage extends StatelessWidget {
  const CommunityActivityLogPage({super.key});

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
        title: AppText.title('Activity Log'),
      ),
      body: BlocBuilder<ActivityLogCubit, ActivityLogState>(
        builder: (context, state) {
          if (state.status == ActivityLogStatus.loading) {
            return const AppLoader(message: 'Loading your activity…');
          }
          final failure = state.failure;
          if (state.status == ActivityLogStatus.failure) {
            return AppStateView.error(
              title: 'Could not load your activity',
              message: failure?.message,
              onAction: () => context.read<ActivityLogCubit>().load(),
            );
          }
          return Column(
            children: [
              _FilterSummaryBar(
                filterLabel: _filterLabel(state.filter),
                isFiltered: state.filter != ActivityFilter.all,
                onFilter: () => showActivityFilterSheet(
                  context,
                  current: state.filter,
                  counts: state.counts,
                  onApply: context.read<ActivityLogCubit>().setFilter,
                ),
                onClear: () => context.read<ActivityLogCubit>().setFilter(
                  ActivityFilter.all,
                ),
              ),
              Expanded(
                child: state.groups.isEmpty
                    ? AppStateView(
                        icon: PhosphorIconsRegular.magnifyingGlass,
                        title: 'No Activity Found',
                        message:
                            'There are no logged community activities for '
                            'this category yet.',
                        actionLabel: 'Show All Activity',
                        onAction: () => context
                            .read<ActivityLogCubit>()
                            .setFilter(ActivityFilter.all),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                        itemCount: state.groups.length,
                        itemBuilder: (context, index) {
                          final group = state.groups[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ActivityGroupHeader(group: group),
                              for (final entry in group.entries)
                                ActivityRow(
                                  entry: entry,
                                  onTap: () => _notAvailable(
                                    context,
                                    'Opening the related post',
                                  ),
                                ),
                            ],
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

  static String _filterLabel(ActivityFilter filter) => switch (filter) {
    ActivityFilter.all => 'All Activity',
    ActivityFilter.posts => 'Posts Published',
    ActivityFilter.comments => 'Comments',
    ActivityFilter.questions => 'Shared Questions',
    ActivityFilter.notes => 'Shared Notes',
    ActivityFilter.upvotes => 'Upvotes',
  };

  static void _notAvailable(BuildContext context, String feature) {
    AppSnackBar.show(context, '$feature is not available yet.');
  }
}

class _FilterSummaryBar extends StatelessWidget {
  const _FilterSummaryBar({
    required this.filterLabel,
    required this.isFiltered,
    required this.onFilter,
    required this.onClear,
  });

  final String filterLabel;
  final bool isFiltered;
  final VoidCallback onFilter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs + 2,
              children: [
                AppText.caption('Filtered by:', color: AppColors.textSecondary),
                AppText.caption(
                  filterLabel,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          AppButton(
            label: 'Filter',
            variant: AppButtonVariant.outline,
            icon: PhosphorIconsRegular.funnel,
            onPressed: onFilter,
          ),
          if (isFiltered)
            AppIconButton(
              icon: PhosphorIconsRegular.x,
              tooltip: 'Clear filter',
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}
