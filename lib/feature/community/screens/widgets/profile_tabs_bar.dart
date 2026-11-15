// Content tabs plus ordering control for the community profile dashboard.
// Tab labels carry their counts so the totals are visible before tapping.
import 'profile_tabs_bar_dependencies.dart';

class ProfileTabsBar extends StatelessWidget {
  const ProfileTabsBar({
    super.key,
    required this.tab,
    required this.sort,
    required this.stats,
    required this.onTab,
    required this.onSort,
    required this.showingLabel,
  });

  final CommunityProfileTab tab;
  final CommunityProfileSort sort;
  final CommunityProfileStats stats;
  final ValueChanged<CommunityProfileTab> onTab;
  final ValueChanged<CommunityProfileSort> onSort;

  /// Caption such as 'Showing 3 of 24'.
  final String showingLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          PillSegmentedControl(
            segments: [
              PillSegment(
                value: CommunityProfileTab.posts,
                label: 'Posts (${stats.posts})',
              ),
              PillSegment(
                value: CommunityProfileTab.questions,
                label: 'Questions (${stats.questions})',
              ),
              PillSegment(
                value: CommunityProfileTab.notes,
                label: 'Notes (${stats.notes})',
              ),
            ],
            selected: tab,
            onSelected: onTab,
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: PillSegmentedControl(
                  segments: const [
                    PillSegment(
                      value: CommunityProfileSort.newest,
                      label: 'Newest',
                      icon: PhosphorIconsRegular.clock,
                    ),
                    PillSegment(
                      value: CommunityProfileSort.top,
                      label: 'Top',
                      icon: PhosphorIconsRegular.trendUp,
                    ),
                  ],
                  selected: sort,
                  onSelected: onSort,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              AppText.caption(showingLabel, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
