// Ranked quiz lobby: season banner, the student's ranking profile, today's
// challenge, fair-play notes, and the start action. UI preview data only.
import 'ranked_quiz_imports.dart';

class RankedQuizEntryPage extends StatelessWidget {
  const RankedQuizEntryPage({
    super.key,
    required this.onStart,
    required this.onViewLeaderboard,
    this.onBack,
  });

  final VoidCallback onStart;
  final VoidCallback onViewLeaderboard;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    const used = RankedQuizFixtures.attemptsUsed;
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
                  title: 'Competitive Battle',
                  eyebrow: 'SSC Batch 2025',
                  onLeading: onBack ?? () => Navigator.of(context).maybePop(),
                  trailing: RankedSquareIconButton(
                    icon: PhosphorIconsRegular.info,
                    tooltip: 'Ranking rules',
                    onPressed: () => RankedRulesSheet.show(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const _SeasonBanner(),
                const SizedBox(height: AppSpacing.lg),
                const _ProfilePanel(used: used, limit: limit),
                const SizedBox(height: AppSpacing.xl),
                const _SectionHeader(
                  title: "TODAY'S RANKED CHALLENGE",
                  trailing: 'Refreshes 12:00 AM',
                ),
                const SizedBox(height: AppSpacing.sm),
                const RankedChallengeCard(),
                const SizedBox(height: AppSpacing.lg),
                const RankedFairPlayNote(),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Start Ranked Quiz',
                  trailingIcon: PhosphorIconsRegular.arrowRight,
                  size: AppButtonSize.large,
                  expand: true,
                  onPressed: onStart,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppText.caption(
                  'Attempt ${used + 1} of $limit will start immediately.',
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'View Full Leaderboard',
                  icon: PhosphorIconsRegular.ranking,
                  variant: AppButtonVariant.outline,
                  expand: true,
                  onPressed: onViewLeaderboard,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: AppText.label(title, fontWeight: FontWeight.w700)),
        AppText.caption(trailing, color: AppColors.textSecondary),
      ],
    );
  }
}

class _SeasonBanner extends StatelessWidget {
  const _SeasonBanner();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surfaceAlt,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.warningSoft,
            child: Icon(PhosphorIconsFill.trophy, color: AppColors.warning),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.caption(
                  'WEEKLY SSC LEADERBOARD',
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
                AppText.label(
                  'Season 02 · Week 4 of 6',
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          RankedPill(label: 'Ends in 2d', background: AppColors.surface),
        ],
      ),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({required this.used, required this.limit});

  final int used;
  final int limit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: AppText.caption(
                  'YOUR PERFORMANCE PROFILE',
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                PhosphorIconsFill.lightning,
                size: 14,
                color: AppColors.success,
              ),
              AppText.caption(' Real-time', color: AppColors.success),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          RankedStatRow(
            children: [
              RankedStatColumn(
                value: '#24',
                caption: 'Cohort Rank',
                pill: RankedPill(
                  label: 'Top 5%',
                  icon: PhosphorIconsFill.caretUp,
                  background: context.primarySoft,
                  foreground: context.primary,
                ),
              ),
              const RankedStatColumn(
                value: '980',
                caption: 'Monthly Pts',
                pill: RankedPill(label: 'Active', icon: PhosphorIconsFill.star),
              ),
              RankedStatColumn(
                value: '$used/$limit',
                caption: "Today's Runs",
                pill: RankedPill(
                  label: '${limit - used} Left',
                  icon: PhosphorIconsFill.fire,
                  background: AppColors.successSoft,
                  foreground: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
