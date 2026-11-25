// Selectable pill chip with an optional check icon for chosen state.
// Shared by subject and chapter pickers so selection looks identical.
import 'community_widgets_imports.dart';

class CommunityChoiceChip extends StatelessWidget {
  const CommunityChoiceChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;

  /// Null disables the chip, for example while publishing.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      enabled: onTap != null,
      excludeSemantics: true,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Material(
          color: isSelected ? AppColors.primarySoft : AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(
                      PhosphorIconsRegular.checkCircle,
                      size: AppSizes.iconSm,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  AppText.caption(
                    label,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    maxLines: 1,
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
