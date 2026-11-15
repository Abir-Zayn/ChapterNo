// Featured card presenting the student's daily study target and progress.
// Pairs a progress ring with question/time stats and one primary action.
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
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                _GoalRing(ratio: goal.progressRatio, percent: progressPercent),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText.label(
                        'DAILY TARGET',
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AppText.title(
                        '${goal.subjectName}: ${goal.chapterTitle}',
                        fontWeight: FontWeight.w600,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _GoalStat(
                      icon: PhosphorIconsRegular.checkCircle,
                      iconColor: AppColors.success,
                      value:
                          '${goal.completedQuestions}/${goal.totalQuestions} Questions',
                    ),
                  ),
                  Expanded(
                    child: _GoalStat(
                      icon: PhosphorIconsRegular.clock,
                      iconColor: AppColors.info,
                      value:
                          '${goal.completedMinutes}/${goal.targetMinutes} mins',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppButton(
              label: goal.isCompleted ? 'Practice More' : 'Continue Practice',
              icon: PhosphorIconsRegular.play,
              expand: true,
              onPressed: onContinuePractice,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalRing extends StatelessWidget {
  const _GoalRing({required this.ratio, required this.percent});

  final double ratio;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Daily target $percent percent complete',
      child: SizedBox.square(
        dimension: 76,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: ratio,
              strokeWidth: 7,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.primarySoft,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
            Center(
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: AppText.title(
                    '$percent%',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalStat extends StatelessWidget {
  const _GoalStat({
    required this.icon,
    required this.iconColor,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppSizes.iconSm, color: iconColor),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: AppText.caption(
              value,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
