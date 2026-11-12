// Primary reusable action button with visual variants, sizes, and loading.
// Wraps Material buttons so theme, 48dp touch targets, and semantics stay
// consistent; loading disables taps and shows an inline progress indicator.
import 'app_button_imports.dart';

enum AppButtonVariant { primary, secondary, outline, text, danger }

enum AppButtonSize { medium, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.expand = false,
    this.semanticsLabel,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;

  /// Stretches the button to the full available width.
  final bool expand;
  final String? semanticsLabel;

  double get _height => switch (size) {
    AppButtonSize.medium => AppSizes.buttonHeight,
    AppButtonSize.large => AppSizes.buttonHeightLarge,
  };

  ButtonStyle _style(ThemeData theme) {
    final scheme = theme.colorScheme;
    // No colour in the text style: the button's foreground colour applies.
    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      height: AppText.banglaSafeHeight,
      letterSpacing: 0,
    );
    final base = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(AppSizes.minTouch, _height)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      ),
      textStyle: WidgetStatePropertyAll(labelStyle),
    );
    if (variant != AppButtonVariant.danger) return base;
    return base.merge(
      FilledButton.styleFrom(
        backgroundColor: scheme.error,
        foregroundColor: scheme.onError,
      ),
    );
  }

  Widget _content() {
    final leading = isLoading
        ? const SizedBox.square(
            dimension: AppSizes.iconSm,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : (icon == null ? null : Icon(icon, size: AppSizes.iconSm));
    return Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading, const SizedBox(width: AppSpacing.sm)],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Icon(trailingIcon, size: AppSizes.iconSm),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _style(Theme.of(context));
    final onTap = isLoading ? null : onPressed;
    final child = _content();

    Widget button = switch (variant) {
      AppButtonVariant.primary || AppButtonVariant.danger => FilledButton(
        onPressed: onTap,
        style: style,
        child: child,
      ),
      AppButtonVariant.secondary => FilledButton.tonal(
        onPressed: onTap,
        style: style,
        child: child,
      ),
      AppButtonVariant.outline => OutlinedButton(
        onPressed: onTap,
        style: style,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: onTap,
        style: style,
        child: child,
      ),
    };

    if (expand) button = SizedBox(width: double.infinity, child: button);
    final a11yLabel = semanticsLabel;
    if (a11yLabel == null) return button;
    return Semantics(
      label: a11yLabel,
      button: true,
      enabled: onTap != null,
      excludeSemantics: true,
      child: button,
    );
  }
}
