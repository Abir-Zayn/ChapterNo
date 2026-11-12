// Central colour tokens for ChapterNo's warm, light-first academic style.
// Primary coral and canvas come from the project guide; neutrals are derived
// placeholders until DESIGN.md tokens are added to the repository.
import 'tokens_imports.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFFFF5A5F);
  static const Color onPrimary = Colors.white;
  static const Color primarySoft = Color(0xFFFFE8E9);

  static const Color canvas = Color(0xFFFCFCFB);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE7E5E4);
  static const Color divider = Color(0xFFF0EEED);

  static const Color textPrimary = Color(0xFF1C1B1A);
  static const Color textSecondary = Color(0xFF5F5C59);
  static const Color textDisabled = Color(0xFFA8A29E);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFB26A00);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF1565C0);
}
