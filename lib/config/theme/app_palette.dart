// Theme-aware primary colours read from the active ColorScheme.
// Light theme resolves to near-black, dark theme to white; use these
// getters in widgets instead of the static AppColors.primary* tokens.
import 'app_theme_imports.dart';

extension AppPalette on BuildContext {
  ColorScheme get _scheme => Theme.of(this).colorScheme;

  /// Main action and accent colour.
  Color get primary => _scheme.primary;

  /// Foreground placed on [primary] fills.
  Color get onPrimary => _scheme.onPrimary;

  /// Subtle background for selected or highlighted primary elements.
  Color get primarySoft => _scheme.primaryContainer;

  /// Strong foreground placed on [primarySoft] backgrounds.
  Color get primaryStrong => _scheme.onPrimaryContainer;
}
