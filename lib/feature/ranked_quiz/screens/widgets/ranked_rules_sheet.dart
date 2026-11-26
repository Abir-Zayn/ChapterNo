// Bottom sheet listing the official ranked arena rules.
// Opened from the entry screen's "Ranking Rules" action.
import 'ranked_widgets_imports.dart';

abstract final class RankedRulesSheet {
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppText.title('Official Arena Rules'),
              const SizedBox(height: AppSpacing.lg),
              const _Rule(
                icon: PhosphorIconsRegular.sealCheck,
                title: 'Board standard accuracy',
                body:
                    'Questions match the NCTB curriculum for SSC exam '
                    'preparedness.',
              ),
              const _Rule(
                icon: PhosphorIconsRegular.timer,
                title: 'Timed performance multiplier',
                body:
                    'Higher accuracy in shorter time unlocks bonus '
                    'percentile scores.',
              ),
              const _Rule(
                icon: PhosphorIconsRegular.arrowCounterClockwise,
                title: 'Daily attempt quota',
                body:
                    '5 ranked attempts renew at midnight (BST). Only your top '
                    '3 scores feed the weekly board.',
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Understood & Ready',
                expand: true,
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        color: AppColors.surfaceAlt,
        radius: AppRadius.md,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: AppSizes.iconMd, color: context.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.label(title, fontWeight: FontWeight.w700),
                  AppText.caption(body, color: AppColors.textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
