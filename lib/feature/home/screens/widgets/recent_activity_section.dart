// Section listing the student's recent practice sessions and test scores.
// Displays test types, completion timestamps, and score outcomes.
import 'home_widgets_imports.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({
    super.key,
    required this.activities,
    required this.onActivityTap,
  });

  final List<StudyActivityItem> activities;
  final ValueChanged<StudyActivityItem> onActivityTap;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText.title('Recent Practice', fontWeight: FontWeight.w600),
        const SizedBox(height: AppSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _ActivityTile(
              activity: activity,
              onTap: () => onActivityTap(activity),
            );
          },
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity, required this.onTap});

  final StudyActivityItem activity;
  final VoidCallback onTap;

  IconData _iconForType(StudyActivityType type) => switch (type) {
    StudyActivityType.mcq => PhosphorIconsRegular.listChecks,
    StudyActivityType.cq => PhosphorIconsRegular.penNib,
    StudyActivityType.notebook => PhosphorIconsRegular.notebook,
    StudyActivityType.revision => PhosphorIconsRegular.chartLineUp,
  };

  Color _colorForType(StudyActivityType type) => switch (type) {
    StudyActivityType.mcq => AppColors.info,
    StudyActivityType.cq => AppColors.success,
    StudyActivityType.notebook => AppColors.error,
    StudyActivityType.revision => AppColors.warning,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(activity.activityType);
    final icon = _iconForType(activity.activityType);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: AppSizes.iconMd),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.label(activity.title, fontWeight: FontWeight.w600),
                const SizedBox(height: 2),
                AppText.caption(
                  activity.subtitle,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText.label(
                activity.scoreText,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 2),
              AppText.caption(activity.timeAgo, color: AppColors.textDisabled),
            ],
          ),
        ],
      ),
    );
  }
}
