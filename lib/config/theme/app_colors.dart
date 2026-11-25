// Central colour tokens for ChapterNo's warm, light-first academic style.
// Values mirror the tokens in DESIGN.md section 3. The monochrome primary
// flips per theme: widgets read it via `context.primary` (app_palette.dart).
import 'tokens_imports.dart';

abstract final class AppColors {
  /// Light-theme primary values; feed the ColorScheme in AppTheme.light().
  /// Widgets should use the theme-aware `context.primary*` getters instead.
  static const Color primary = Color(0xFF18181B);
  static const Color primaryPressed = Color(0xFF18181B);
  static const Color onPrimary = Colors.white;
  static const Color primarySoft = Color(0xFFE4E4E7);

  /// Dark-theme primary values; feed the ColorScheme in AppTheme.dark().
  static const Color primaryDark = Color(0xFFFAFAFA);
  static const Color primaryPressedDark = Color(0xFFFAFAFA);
  static const Color onPrimaryDark = Color(0xFF18181B);
  static const Color primarySoftDark = Color(0xFF3F3F46);

  /// Dark-theme base surfaces from DESIGN.md section 3.
  static const Color canvasDark = Color(0xFF111113);
  static const Color surfaceDark = Color(0xFF18181B);
  static const Color textPrimaryDark = Color(0xFFFAFAFA);
  static const Color textSecondaryDark = Color(0xFFD4D4D8);
  static const Color borderDark = Color(0xFF2F2F35);

  static const Color canvas = Color(0xFFFCFCFB);
  static const Color surface = Colors.white;
  static const Color surfaceAlt = Color(0xFFF7F7F5);
  static const Color surfaceSunken = Color(0xFFF4F4F5);
  static const Color border = Color(0xFFE4E4E7);
  static const Color divider = Color(0xFFF4F4F5);

  static const Color textPrimary = Color(0xFF18181B);
  static const Color textSecondary = Color(0xFF71717A);
  static const Color textDisabled = Color(0xFFA1A1AA);

  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorSoft = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoSoft = Color(0xFFDBEAFE);

  /// Illustration accents only; never use for actions or correctness.
  static const Color accentMoss = Color(0xFF708D81);
  static const Color accentAmber = Color(0xFFF4D35E);
  static const Color accentClay = Color(0xFFD98363);

  /// Solid ink surfaces reserved for the Plus upgrade hero; no gradients.
  static const Color plusInk = Color(0xFF16153A);
  static const Color plusInkRaised = Color(0xFF23215A);
  static const Color onPlusInk = Colors.white;
  static const Color onPlusInkMuted = Color(0xFFCFCDEB);
}
