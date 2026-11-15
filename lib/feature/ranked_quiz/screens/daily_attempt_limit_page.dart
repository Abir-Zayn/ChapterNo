// Shown when all daily ranked attempts are used: explains the limit, the
// next reset, that the current rank is safe, and offers practice paths.
import 'ranked_quiz_imports.dart';

class DailyAttemptLimitPage extends StatefulWidget {
  const DailyAttemptLimitPage({
    super.key,
    required this.onPractice,
    required this.onReviewMistakes,
    required this.onViewLeaderboard,
    this.onBack,
  });

  final VoidCallback onPractice;
  final VoidCallback onReviewMistakes;
  final VoidCallback onViewLeaderboard;
  final VoidCallback? onBack;

  @override
  State<DailyAttemptLimitPage> createState() => _DailyAttemptLimitPageState();
}

class _DailyAttemptLimitPageState extends State<DailyAttemptLimitPage> {
  bool _showPolicy = false;

  @override
  Widget build(BuildContext context) {
    const limit = RankedQuizFixtures.dailyLimit;
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
                  eyebrow: 'SSC Competitive',
                  title: 'Ranked Quiz',
                  onLeading:
                      widget.onBack ?? () => Navigator.of(context).maybePop(),
                  trailing: RankedSquareIconButton(
                    icon: PhosphorIconsRegular.info,
                    tooltip: 'Limit policy',
                    onPressed: () => setState(() => _showPolicy = !_showPolicy),
                  ),
                ),
                if (_showPolicy) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const AppCard(
                    color: AppColors.surfaceAlt,
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: AppText.caption(
                      'Equal daily attempts ensure dedication and consistency '
                      'decide SSC ranks, not continuous retries.',
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                const _StatusHero(limit: limit),
                const SizedBox(height: AppSpacing.xl),
                const _ResetCard(),
                const SizedBox(height: AppSpacing.xl),
                const AppText.label(
                  'WHAT YOU CAN DO NOW',
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: AppSpacing.sm),
                RankedActionCard(
                  icon: PhosphorIconsRegular.bookOpen,
                  title: 'Practice Without Limits',
                  description:
                      'Solve unlimited unranked Topic and Board MCQs in the '
                      'Practice Hub.',
                  tags: const ['Unlimited MCQs', 'No Pressure'],
                  onTap: widget.onPractice,
                ),
                const SizedBox(height: AppSpacing.sm),
                RankedActionCard(
                  icon: PhosphorIconsRegular.brain,
                  iconBackground: AppColors.successSoft,
                  iconColor: AppColors.success,
                  title: 'Review Past Mistakes',
                  description:
                      'Strengthen weak concepts with AI-assisted answer '
                      'analysis.',
                  tags: const ['8 Flagged Questions', 'Step-by-step'],
                  onTap: widget.onReviewMistakes,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Practice MCQs',
                  icon: PhosphorIconsRegular.books,
                  size: AppButtonSize.large,
                  expand: true,
                  onPressed: widget.onPractice,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'View Leaderboard',
                  icon: PhosphorIconsRegular.ranking,
                  variant: AppButtonVariant.outline,
                  expand: true,
                  onPressed: widget.onViewLeaderboard,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.limit});

  final int limit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 52,
          backgroundColor: AppColors.surfaceSunken,
          child: CircleAvatar(
            radius: 38,
            backgroundColor: AppColors.surface,
            child: Icon(
              PhosphorIconsFill.shieldCheck,
              size: 38,
              color: AppColors.accentClay,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        RankedPill(
          label: '$limit / $limit Attempts Used Today',
          background: AppColors.warningSoft,
          foreground: AppColors.warning,
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppText.headline(
          'Daily Limit Reached',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppText(
          'You have used all $limit ranked quiz attempts for today. Daily '
          'limits keep competition fair for all SSC students.',
          color: AppColors.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ResetCard extends StatelessWidget {
  const _ResetCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                PhosphorIconsRegular.clockCounterClockwise,
                color: AppColors.primary,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: AppText.title('Next Reset')),
              RankedPill(
                label: 'Midnight 00:00',
                icon: PhosphorIconsRegular.moon,
                background: AppColors.surface,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const AppText.caption(
            'Attempts refresh with the daily server reset at midnight.',
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            radius: AppRadius.md,
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.successSoft,
                  child: Icon(
                    PhosphorIconsRegular.sealCheck,
                    size: AppSizes.iconSm,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.label(
                        'Your rank #21 with 1,060 pts is secured.',
                        fontWeight: FontWeight.w600,
                      ),
                      AppText.caption(
                        "Scores won't decay before tomorrow's reset.",
                        color: AppColors.textSecondary,
                      ),
                    ],
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
