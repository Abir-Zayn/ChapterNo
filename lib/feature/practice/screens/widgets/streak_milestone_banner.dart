// Micro-state card highlighting the student's active streak and daily practice goal.
// Features a coral progress icon and motivational call-to-action text.
import 'practice_widgets_imports.dart';

class StreakMilestoneBanner extends StatelessWidget {
  const StreakMilestoneBanner({super.key, required this.milestone});

  final DailyStreakMilestone milestone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIconsRegular.trendUp,
              color: context.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.label(
                  milestone.title,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                AppText.caption(
                  milestone.description,
                  color: AppColors.textSecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
