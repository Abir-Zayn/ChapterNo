// Tappable card with an icon tile, title, description, tags and a chevron.
// Used for "what you can do now" alternatives on the daily limit screen.
import 'ranked_widgets_imports.dart';

class RankedActionCard extends StatelessWidget {
  const RankedActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.iconBackground = AppColors.primarySoft,
    this.iconColor = AppColors.primary,
    this.tags = const [],
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Color iconBackground;
  final Color iconColor;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: iconColor, size: AppSizes.iconMd),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.title(title, maxLines: 2),
                const SizedBox(height: AppSpacing.xxs),
                AppText.caption(description, color: AppColors.textSecondary),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final tag in tags) RankedPillLite(label: tag),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            PhosphorIconsRegular.caretRight,
            size: AppSizes.iconSm,
            color: AppColors.textDisabled,
          ),
        ],
      ),
    );
  }
}

/// Compact square-ish tag used inside action cards.
class RankedPillLite extends StatelessWidget {
  const RankedPillLite({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.sm / 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: AppText.caption(
          label,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
