// Icon-only button with a required tooltip that doubles as its a11y label.
// Wraps Material IconButton variants and enforces a 48dp touch target.
import 'app_icon_button_imports.dart';

enum AppIconButtonVariant { plain, filled, tonal, outlined }

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.variant = AppIconButtonVariant.plain,
    this.color,
    this.iconSize = AppSizes.iconMd,
  });

  final IconData icon;

  /// Read by screen readers; pass localized text.
  final String tooltip;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final Color? color;
  final double iconSize;

  static const _constraints = BoxConstraints(
    minWidth: AppSizes.minTouch,
    minHeight: AppSizes.minTouch,
  );

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: iconSize);
    return switch (variant) {
      AppIconButtonVariant.plain => IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        color: color,
        constraints: _constraints,
        icon: iconWidget,
      ),
      AppIconButtonVariant.filled => IconButton.filled(
        onPressed: onPressed,
        tooltip: tooltip,
        color: color,
        constraints: _constraints,
        icon: iconWidget,
      ),
      AppIconButtonVariant.tonal => IconButton.filledTonal(
        onPressed: onPressed,
        tooltip: tooltip,
        color: color,
        constraints: _constraints,
        icon: iconWidget,
      ),
      AppIconButtonVariant.outlined => IconButton.outlined(
        onPressed: onPressed,
        tooltip: tooltip,
        color: color,
        constraints: _constraints,
        icon: iconWidget,
      ),
    };
  }
}
