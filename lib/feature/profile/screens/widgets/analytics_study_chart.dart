// Weekly study volume bar chart and focus tip card for Learning Analytics.
// Renders solid bars without gradients or blur and scales safely.
import 'widgets_imports.dart';

class AnalyticsStudyChart extends StatelessWidget {
  const AnalyticsStudyChart({
    super.key,
    required this.totalSolvedVolume,
    required this.weeklyVolume,
    required this.focusTip,
  });

  final int totalSolvedVolume;
  final List<DailyStudyVolume> weeklyVolume;
  final String focusTip;

  @override
  Widget build(BuildContext context) {
    final maxCount = weeklyVolume.fold<int>(
      1,
      (max, item) => item.questionsSolved > max ? item.questionsSolved : max,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: AppText.title('Study Activity')),
              AppText.caption(
                '$totalSolvedVolume questions',
                color: context.primaryStrong,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          const AppText.caption(
            'Total solved volume this period',
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 132,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final day in weeklyVolume)
                  Expanded(
                    child: _BarColumn(day: day, maxCount: maxCount),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsRegular.lightbulb,
                  size: AppSizes.iconSm,
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppText.caption(
                    focusTip,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({required this.day, required this.maxCount});

  final DailyStudyVolume day;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final ratio = (day.questionsSolved / maxCount).clamp(0.08, 1.0);
    return Semantics(
      label: '${day.dayLabel}: ${day.questionsSolved} questions',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppText.caption(
            '${day.questionsSolved}',
            color: day.isHighlight
                ? context.primaryStrong
                : AppColors.textSecondary,
            fontWeight: day.isHighlight ? FontWeight.w700 : FontWeight.w500,
          ),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: ratio,
                child: Container(
                  width: 18,
                  decoration: BoxDecoration(
                    color: day.isHighlight
                        ? context.primary
                        : context.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText.caption(
            day.dayLabel,
            color: day.isHighlight
                ? AppColors.textPrimary
                : AppColors.textSecondary,
            fontWeight: day.isHighlight ? FontWeight.w600 : FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
