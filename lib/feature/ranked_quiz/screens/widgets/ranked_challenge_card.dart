// Today's challenge card and fair-play notes for the ranked quiz lobby.
// Static preview content sourced from RankedQuizFixtures.
import 'ranked_widgets_imports.dart';
import '../../data/resource/ranked_quiz_fixtures.dart';
import 'ranked_pill.dart';

class RankedChallengeCard extends StatelessWidget {
  const RankedChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              RankedPill(
                label: 'PHYSICS',
                background: AppColors.successSoft,
                foreground: AppColors.success,
              ),
              RankedPill(
                label: 'RANKED ARENA',
                background: context.primarySoft,
                foreground: context.primary,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          AppText.title(RankedQuizFixtures.challengeTitle),
          SizedBox(height: AppSpacing.xs),
          AppText.caption(
            RankedQuizFixtures.challengeSummary,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              RankedPill(
                label: '${RankedQuizFixtures.questionCount} Questions',
                icon: PhosphorIconsRegular.question,
                radius: AppRadius.sm,
              ),
              RankedPill(
                label: '10 Minutes',
                icon: PhosphorIconsRegular.timer,
                radius: AppRadius.sm,
              ),
              RankedPill(
                label: 'Board Standard',
                icon: PhosphorIconsRegular.sealCheck,
                radius: AppRadius.sm,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RankedFairPlayNote extends StatelessWidget {
  const RankedFairPlayNote({super.key});

  static const _items = [
    (
      PhosphorIconsRegular.checkCircle,
      AppColors.success,
      'Full solutions unlock immediately after final submission.',
    ),
    (
      PhosphorIconsRegular.lockSimple,
      AppColors.warning,
      'No AI assistance, hints, or answer changes during live time.',
    ),
    (
      PhosphorIconsRegular.warning,
      AppColors.error,
      'Leaving the app consumes your attempt without recording points.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.surfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(PhosphorIconsRegular.shieldCheck, size: AppSizes.iconSm),
              SizedBox(width: AppSpacing.sm),
              AppText.caption(
                'ARENA FAIR PLAY PROTOCOL',
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final (icon, color, text) in _items)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppText.caption(
                      text,
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
