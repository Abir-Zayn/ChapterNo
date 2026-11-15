// Featured card presenting the student's daily study target and progress.
// Visualises question completion, time invested, and primary practice action.
import 'home_widgets_imports.dart';

class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({
    super.key,
    required this.goal,
    required this.onContinuePractice,
  });

  final DailyGoal goal;
  final VoidCallback onContinuePractice;

  @override
  Widget build(BuildContext context) {
    final progressPercent = (goal.progressRatio * 100).toInt();

    return AppCard(
      radius: AppRadius.xl,
      borderColor: AppColors.primary.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const AppText.label(
                      'DAILY TARGET',
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppText.label(
                '$progressPercent%',
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppText.title(
            '${goal.subjectName}: ${goal.chapterTitle}',
            fontWeight: FontWeight.w600,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: goal.progressRatio,
              minHeight: 8,
              backgroundColor: AppColors.surfaceSunken,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    PhosphorIconsRegular.checkCircle,
                    size: AppSizes.iconSm,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  AppText.caption(
                    '${goal.completedQuestions}/${goal.totalQuestions} Questions',
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    PhosphorIconsRegular.clock,
                    size: AppSizes.iconSm,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  AppText.caption(
                    '${goal.completedMinutes}/${goal.targetMinutes} mins',
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: goal.isCompleted ? 'Practice More' : 'Continue Practice',
            icon: PhosphorIconsRegular.play,
            expand: true,
            onPressed: onContinuePractice,
          ),
        ],
      ),
    );
  }
}
