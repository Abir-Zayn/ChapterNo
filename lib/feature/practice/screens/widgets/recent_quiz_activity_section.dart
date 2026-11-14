// Section listing recent quiz sessions with completion states and resume actions.
// Matches the Stitch design with subject-tinted icons and status badges.
import 'practice_widgets_imports.dart';

class RecentQuizActivitySection extends StatelessWidget {
  const RecentQuizActivitySection({
    super.key,
    required this.activities,
    this.onViewAll,
    this.onActionTap,
  });

  final List<RecentQuizActivity> activities;
  final VoidCallback? onViewAll;
  final ValueChanged<RecentQuizActivity>? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: AppText.title(
                'Recent Quiz Activity',
                fontWeight: FontWeight.w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: const AppText.label(
                'View All',
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _ActivityCard(
              activity: activity,
              onTap: () => onActionTap?.call(activity),
            );
          },
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity, required this.onTap});

  final RecentQuizActivity activity;
  final VoidCallback onTap;

  (Color, Color, IconData) _resolveSubjectTheme() {
    switch (activity.subjectKey.toLowerCase()) {
      case 'physics':
        return (
          AppColors.accentMoss,
          const Color(0xFFE5F4ED),
          PhosphorIconsRegular.lightning,
        );
      case 'biology':
        return (
          AppColors.success,
          AppColors.successSoft,
          PhosphorIconsRegular.dna,
        );
      default:
        return (
          AppColors.info,
          AppColors.infoSoft,
          PhosphorIconsRegular.bookOpen,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final (accentColor, softBg, iconData) = _resolveSubjectTheme();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm + 4),
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth <= 320;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: softBg,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        iconData,
                        color: accentColor,
                        size: AppSizes.iconMd,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.label(
                            activity.fullTitle,
                            fontWeight: FontWeight.w600,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Expanded(
                                child: AppText.caption(
                                  activity.progressLabel,
                                  color: AppColors.textSecondary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              _StatusBadge(status: activity.status),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: _ActionButton(
                    label: activity.actionLabel,
                    isPrimary: activity.status == QuizActivityStatus.inProgress,
                    onPressed: onTap,
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: softBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  iconData,
                  color: accentColor,
                  size: AppSizes.iconMd,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.label(
                      activity.fullTitle,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    AppText.caption(
                      activity.progressLabel,
                      color: AppColors.textSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    _StatusBadge(status: activity.status),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _ActionButton(
                label: activity.actionLabel,
                isPrimary: activity.status == QuizActivityStatus.inProgress,
                onPressed: onTap,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final QuizActivityStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bgColor, textColor) = switch (status) {
      QuizActivityStatus.completed => (
        'Completed',
        AppColors.successSoft,
        AppColors.success,
      ),
      QuizActivityStatus.inProgress => (
        'In Progress',
        AppColors.warningSoft,
        AppColors.warning,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: AppText.caption(
        label,
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.primary : AppColors.surfaceSunken,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          alignment: Alignment.center,
          child: AppText.caption(
            label,
            color: isPrimary ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
