// Icon-only button for community screens that renders a HugeIcons glyph.
// Keeps the 48dp touch target and tooltip-as-label rules of AppIconButton.
import 'community_widgets_imports.dart';

class CommunityIconButton extends StatelessWidget {
  const CommunityIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
    this.tonal = false,
  });

  /// A HugeIcons glyph, for example `HugeIcons.strokeRoundedSearch01`.
  final List<List<dynamic>> icon;

  /// Read by screen readers; pass localized text.
  final String tooltip;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final Color? color;

  /// Uses a sunken solid background instead of a transparent one.
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final glyph = HugeIcon(
      icon: icon,
      size: AppSizes.iconMd,
      color: color ?? AppColors.textPrimary,
      strokeWidth: 1.8,
    );
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      constraints: const BoxConstraints(
        minWidth: AppSizes.minTouch,
        minHeight: AppSizes.minTouch,
      ),
      style: tonal
          ? IconButton.styleFrom(
              backgroundColor: AppColors.surfaceSunken,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            )
          : null,
      icon: glyph,
    );
  }
}
