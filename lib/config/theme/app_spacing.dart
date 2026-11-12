// Spacing, radius, and sizing tokens shared by every screen and component.
// Use these instead of raw numbers so layouts stay consistent.
import 'tokens_imports.dart';

abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: lg);
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}

abstract final class AppSizes {
  /// Minimum accessible touch target.
  static const double minTouch = 48;
  static const double buttonHeight = 48;
  static const double buttonHeightLarge = 56;
  static const double iconSm = 18;
  static const double iconMd = 22;
  static const double iconLg = 28;
}
