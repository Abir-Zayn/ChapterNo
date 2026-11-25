// Dark ink hero at the top of the Plus screen: close action, Plus wordmark,
// headline, and reassurance copy. Extends under the status bar safely.
import 'widgets_imports.dart';

class PlusHeroHeader extends StatelessWidget {
  const PlusHeroHeader({
    super.key,
    required this.headline,
    required this.summary,
    required this.onClose,
    this.isOnPlus = false,
  });

  final String headline;
  final String summary;
  final VoidCallback onClose;
  final bool isOnPlus;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppRadius.sheet),
      ),
      child: ColoredBox(
        color: AppColors.plusInk,
        child: CustomPaint(
          painter: const PlusHeroArcs(),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.xs,
                AppSpacing.sm,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: onClose,
                      tooltip: 'Close',
                      icon: const Icon(PhosphorIconsRegular.x),
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _PlusWordmark(),
                  const SizedBox(height: AppSpacing.xl),
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.headline(
                          isOnPlus ? "You're on ChapterNo Plus" : headline,
                          color: AppColors.onPrimary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppText(summary, color: AppColors.onPlusInkMuted),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlusWordmark extends StatelessWidget {
  const _PlusWordmark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'ChapterNo Plus',
      excludeSemantics: true,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          const AppText(
            'ChapterNo',
            variant: AppTextVariant.display,
            color: AppColors.onPrimary,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.accentAmber,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsFill.crown,
                    size: AppSizes.iconSm,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  AppText.label('Plus', color: AppColors.textPrimary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
