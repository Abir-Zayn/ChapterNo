// Attached practice-question preview on the create-post question form.
// The sample attachment stands in until practice history is connected.
import 'community_widgets_imports.dart';

class AttachedQuestionCard extends StatelessWidget {
  const AttachedQuestionCard({
    super.key,
    required this.question,
    required this.isLoading,
    this.onReplace,
  });

  final PostQuestion? question;

  /// While loading, a compact placeholder replaces the card content.
  final bool isLoading;
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(
              PhosphorIconsRegular.sealCheck,
              size: AppSizes.iconMd,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            AppText.label('Attached Practice Question'),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.infoSoft,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: AppText.caption(
                'Sample',
                color: AppColors.info,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppButton(
              label: 'Replace Question',
              variant: AppButtonVariant.text,
              icon: PhosphorIconsRegular.arrowsClockwise,
              onPressed: onReplace,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (isLoading)
          const AppLoader()
        else ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _MetaChip(
                      label:
                          '${question?.subject ?? ''} · ${question?.topic ?? ''}',
                    ),
                    _MetaChip(label: question?.sourceLabel ?? ''),
                    _MetaChip(label: "Dhaka Board '23", highlight: true),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppText(question?.stem ?? '', fontWeight: FontWeight.w500),
                if ((question?.options.length ?? 0) > 0) ...[
                  const SizedBox(height: AppSpacing.md),
                  for (final option in question!.options)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceSunken,
                              shape: BoxShape.circle,
                            ),
                            child: AppText.caption(
                              option.label,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppText(
                              option.text,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSunken,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        PhosphorIconsRegular.lockSimple,
                        size: AppSizes.iconMd,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppText.caption(
                          'Correct answer and your test score remain hidden in '
                          'the feed until classmates attempt it.',
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText.caption(
            "Practice history isn't connected yet — this sample shows how a "
            'shared question appears.',
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ],
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, this.highlight = false});

  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: highlight ? AppColors.surface : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: highlight ? Border.all(color: AppColors.border) : null,
      ),
      child: AppText.caption(
        label,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
