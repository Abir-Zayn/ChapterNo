// Central colour tokens for ChapterNo's warm, light-first academic style.
// Values mirror the light-theme tokens in DESIGN.md section 3.
// Use these instead of raw hex values so screens stay consistent.
import 'tokens_imports.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFFFF5A5F);
  static const Color primaryPressed = Color(0xFFFA4F54);
  static const Color onPrimary = Colors.white;
  static const Color primarySoft = Color(0xFFFFE9EA);

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
}
