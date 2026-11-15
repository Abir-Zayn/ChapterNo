// Small rounded label used for tags, counters, and status chips on ranked
// quiz screens. Solid fill only; colours come from AppColors tokens.
import 'ranked_widgets_imports.dart';

class RankedPill extends StatelessWidget {
  const RankedPill({
    super.key,
    required this.label,
    this.icon,
    this.background = AppColors.surfaceSunken,
    this.foreground = AppColors.textSecondary,
    this.radius = AppRadius.pill,
  });

  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + AppSpacing.xxs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: AppText.caption(
                label,
                color: foreground,
                fontWeight: FontWeight.w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
