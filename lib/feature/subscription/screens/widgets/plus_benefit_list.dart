// Checklist of Plus benefits; each row pairs an icon and a check mark with
// text so meaning never depends on colour alone.
import 'widgets_imports.dart';

class PlusBenefitList extends StatelessWidget {
  const PlusBenefitList({super.key, required this.benefits});

  final List<PlusBenefit> benefits;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText.title('What you get with Plus'),
        const SizedBox(height: AppSpacing.md),
        for (final benefit in benefits) _BenefitRow(benefit: benefit),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.benefit});

  final PlusBenefit benefit;

  static IconData _iconFor(PlusBenefitKind kind) => switch (kind) {
    PlusBenefitKind.practice => PhosphorIconsRegular.books,
    PlusBenefitKind.aiSupport => PhosphorIconsRegular.sparkle,
    PlusBenefitKind.feedback => PhosphorIconsRegular.pencilLine,
    PlusBenefitKind.revision => PhosphorIconsRegular.notebook,
    PlusBenefitKind.analytics => PhosphorIconsRegular.chartLineUp,
  };

  @override
  Widget build(BuildContext context) {
    final description = benefit.description;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 40,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                _iconFor(benefit.kind),
                size: AppSizes.iconMd,
                color: AppColors.primaryPressed,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(benefit.title, fontWeight: FontWeight.w600),
                if (description != null)
                  AppText.caption(description, color: AppColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            PhosphorIconsBold.check,
            size: AppSizes.iconMd,
            color: AppColors.success,
            semanticLabel: 'Included',
          ),
        ],
      ),
    );
  }
}
