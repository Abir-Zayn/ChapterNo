// Overview card displaying glanceable weekly practice statistics.
// Highlights MCQs solved, accuracy with growth delta, and completed quizzes.
import 'practice_widgets_imports.dart';

class PracticeOverviewCard extends StatelessWidget {
  const PracticeOverviewCard({super.key, required this.metrics});

  final PracticeOverviewMetrics metrics;

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
                'Your Practice Overview',
                fontWeight: FontWeight.w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AppText.caption(
                    metrics.periodLabel,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: PhosphorIconsRegular.checkCircle,
                  iconColor: AppColors.primary,
                  value: '${metrics.mcqsSolved}',
                  label: 'MCQs Solved',
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _MetricTile(
                  value: '${metrics.accuracyPercentage}%',
                  deltaBadge: metrics.accuracyDelta,
                  label: 'Accuracy',
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _MetricTile(
                  icon: PhosphorIconsRegular.sealCheck,
                  iconColor: AppColors.warning,
                  value: '${metrics.quizzesCompleted}',
                  label: 'Quizzes',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    this.icon,
    this.iconColor,
    required this.value,
    this.deltaBadge,
    required this.label,
  });

  final IconData? icon;
  final Color? iconColor;
  final String value;
  final String? deltaBadge;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: 4),
                ],
                AppText(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                if (deltaBadge != null) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successSoft,
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                    ),
                    child: AppText.caption(
                      deltaBadge!,
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          AppText.caption(
            label,
            color: AppColors.textSecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
