// Selectable MCQ answer row with a letter badge and a check indicator.
// Selection is controlled by the parent; this widget only renders it.
import 'ranked_widgets_imports.dart';

class QuizOptionTile extends StatelessWidget {
  const QuizOptionTile({
    super.key,
    required this.letter,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String letter;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.onPrimary : AppColors.textPrimary;
    final badgeBg = selected ? AppColors.primary : AppColors.surfaceSunken;
    return Semantics(
      selected: selected,
      button: true,
      label: 'Option $letter, $label',
      excludeSemantics: true,
      child: AppCard(
        onTap: onTap,
        radius: AppRadius.md,
        color: selected ? AppColors.primarySoft : AppColors.surface,
        borderColor: selected ? AppColors.primary : AppColors.border,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: badgeBg,
              child: AppText.label(
                letter,
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppText(
                label,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            Icon(
              selected
                  ? PhosphorIconsFill.checkCircle
                  : PhosphorIconsRegular.circle,
              size: AppSizes.iconMd,
              color: selected ? AppColors.primary : AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}
