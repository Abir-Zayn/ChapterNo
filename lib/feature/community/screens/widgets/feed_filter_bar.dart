// Sticky filter bar above the feed: sort segmented control with a filter
// action, and the horizontally scrolling subject pills.
import 'feed_filter_bar_dependencies.dart';

class FeedFilterBar extends StatelessWidget {
  const FeedFilterBar({
    super.key,
    required this.sort,
    required this.subject,
    required this.onSort,
    required this.onSubject,
    this.onMoreFilters,
  });

  final CommunityFeedSort sort;
  final String subject;
  final ValueChanged<CommunityFeedSort> onSort;
  final ValueChanged<String> onSubject;
  final VoidCallback? onMoreFilters;

  static const List<PillSegment<CommunityFeedSort>> _sorts = [
    PillSegment(value: CommunityFeedSort.forYou, label: 'For You'),
    PillSegment(value: CommunityFeedSort.latest, label: 'Latest'),
    PillSegment(value: CommunityFeedSort.top, label: 'Top'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: PillSegmentedControl(
                  segments: _sorts,
                  selected: sort,
                  onSelected: onSort,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppIconButton(
                icon: PhosphorIconsRegular.funnel,
                tooltip: 'More feed filters',
                variant: AppIconButtonVariant.tonal,
                onPressed: onMoreFilters,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SubjectPillBar(
            subjects: const [
              CommunitySubjects.all,
              ...CommunitySubjects.selectable,
            ],
            selected: subject,
            onSelected: onSubject,
          ),
        ],
      ),
    );
  }
}
