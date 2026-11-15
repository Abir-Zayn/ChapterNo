// Tappable tile showing a tinted icon above a label, e.g. Home shortcuts.
// Solid surface with a border (no blur); merges into one semantic button
// and lets long Bangla labels wrap to two lines instead of clipping.
import 'app_tile_icon_button_imports.dart';

class AppTileIconButton extends StatelessWidget {
  const AppTileIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.iconBackgroundColor,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;

  /// Null disables the tile.
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    final radius = BorderRadius.circular(AppRadius.lg);
    final fg = iconColor ?? scheme.primary;
    final caption = subtitle;

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Material(
          color: scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: selected ? scheme.primary : scheme.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: AppSizes.minTouch,
                minHeight: AppSizes.minTouch,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color:
                            iconBackgroundColor ?? fg.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Icon(icon, color: fg, size: AppSizes.iconLg),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppText.label(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    if (caption != null)
                      AppText.caption(
                        caption,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
