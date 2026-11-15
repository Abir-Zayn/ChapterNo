// Ranked quiz results: achievement badge, score/accuracy/time summary,
// leaderboard impact, remaining daily attempts, and next actions.
// Shows static preview numbers until scoring is connected.
import 'ranked_quiz_imports.dart';

class RankedQuizResultsPage extends StatelessWidget {
  const RankedQuizResultsPage({
    super.key,
    required this.onClose,
    required this.onReviewAnswers,
    required this.onViewLeaderboard,
    required this.onBackToPractice,
    this.onShare,
  });

  final VoidCallback onClose;
  final VoidCallback onReviewAnswers;
  final VoidCallback onViewLeaderboard;
  final VoidCallback onBackToPractice;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.contentMaxWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              children: [
                RankedTopBar(
                  title: 'Ranked Mode • Wave 3',
                  leadingIcon: PhosphorIconsRegular.x,
                  leadingTooltip: 'Close results',
                  onLeading: onClose,
                  trailing: RankedSquareIconButton(
                    icon: PhosphorIconsRegular.shareNetwork,
                    tooltip: 'Share results',
                    onPressed: onShare,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const _Hero(),
                const SizedBox(height: AppSpacing.xl),
                const AppCard(
                  child: RankedStatRow(
                    children: [
                      RankedStatColumn(
                        icon: PhosphorIconsRegular.listChecks,
                        value: '8/10',
                        caption: 'Score · 80% correct',
                      ),
                      RankedStatColumn(
                        icon: PhosphorIconsRegular.target,
                        iconColor: AppColors.success,
                        value: '80%',
                        caption: 'Accuracy',
                      ),
                      RankedStatColumn(
                        icon: PhosphorIconsRegular.timer,
                        iconColor: AppColors.warning,
                        value: '8m 24s',
                        caption: 'of 10m limit',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const _LeaderboardImpact(),
                const SizedBox(height: AppSpacing.md),
                const _AttemptsCard(used: 4),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Review Answers & Explanations',
                  icon: PhosphorIconsRegular.clipboardText,
                  size: AppButtonSize.large,
                  expand: true,
                  onPressed: onReviewAnswers,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'View Leaderboard',
                  icon: PhosphorIconsRegular.ranking,
                  variant: AppButtonVariant.outline,
                  expand: true,
                  onPressed: onViewLeaderboard,
                ),
                AppButton(
                  label: 'Back to Practice Hub',
                  variant: AppButtonVariant.text,
                  expand: true,
                  onPressed: onBackToPractice,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primarySoft,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary,
            child: Icon(
              PhosphorIconsFill.medal,
              color: AppColors.onPrimary,
              size: AppSizes.iconLg,
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        RankedPill(label: 'SSC Science', icon: PhosphorIconsFill.sealCheck),
        SizedBox(height: AppSpacing.md),
        AppText.headline('Challenge Completed!', textAlign: TextAlign.center),
        SizedBox(height: AppSpacing.xs),
        AppText(
          'Solid performance in Physics Mixed MCQ',
          color: AppColors.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LeaderboardImpact extends StatelessWidget {
  const _LeaderboardImpact();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(PhosphorIconsRegular.ranking, color: AppColors.primary),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: AppText.title('Leaderboard Impact')),
              RankedPill(
                label: '+80 Pts',
                icon: PhosphorIconsRegular.trendUp,
                background: AppColors.successSoft,
                foreground: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            color: AppColors.surfaceAlt,
            borderColor: AppColors.surfaceAlt,
            radius: AppRadius.md,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.caption(
                        'CURRENT STANDING',
                        color: AppColors.textSecondary,
                      ),
                      Row(
                        children: [
                          AppText.title('#24'),
                          Icon(
                            PhosphorIconsRegular.arrowRight,
                            size: 16,
                            color: AppColors.success,
                          ),
                          AppText.headline('#21', color: AppColors.success),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText.caption(
                      'MONTHLY TOTAL',
                      color: AppColors.textSecondary,
                    ),
                    AppText.title('1,060 Pts'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              Icon(
                PhosphorIconsRegular.shieldCheck,
                size: 16,
                color: AppColors.success,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText.caption(
                  'Score recorded on SSC Science Cohort Leaderboard',
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttemptsCard extends StatelessWidget {
  const _AttemptsCard({required this.used});

  final int used;

  @override
  Widget build(BuildContext context) {
    const limit = RankedQuizFixtures.dailyLimit;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                PhosphorIconsRegular.lightning,
                size: AppSizes.iconSm,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.xs),
              const Expanded(
                child: AppText.label(
                  'Daily Ranked Limit',
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppText.label(
                '${limit - used} remaining today',
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AttemptPips(filled: used, total: limit),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppText.caption('$used / $limit', color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
