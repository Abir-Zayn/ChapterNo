// Reusable text widget mapping semantic variants to the theme text styles.
// Never sets fontFamily, so text renders in the device's own system font;
// adds Bangla-safe line height and no letter spacing to avoid clipped marks.
import 'app_text_imports.dart';

enum AppTextVariant { display, headline, title, body, label, caption }

class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.variant = AppTextVariant.body,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.semanticsLabel,
    this.style,
  });

  const AppText.headline(
    this.data, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.semanticsLabel,
    this.style,
  }) : variant = AppTextVariant.headline;

  const AppText.title(
    this.data, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.semanticsLabel,
    this.style,
  }) : variant = AppTextVariant.title;

  const AppText.label(
    this.data, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.semanticsLabel,
    this.style,
  }) : variant = AppTextVariant.label;

  const AppText.caption(
    this.data, {
    super.key,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.semanticsLabel,
    this.style,
  }) : variant = AppTextVariant.caption;

  final String data;
  final AppTextVariant variant;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final String? semanticsLabel;

  /// Extra overrides merged last; avoid setting fontFamily here.
  final TextStyle? style;

  /// Line height that leaves room for Bangla vowel signs above and below.
  static const double banglaSafeHeight = 1.4;

  /// Resolves a variant to a theme-derived style. Shared with input widgets.
  static TextStyle? resolveStyle(BuildContext context, AppTextVariant variant) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final scheme = theme.colorScheme;
    final base = switch (variant) {
      AppTextVariant.display => textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      AppTextVariant.headline => textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      AppTextVariant.title => textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      AppTextVariant.body => textTheme.bodyLarge,
      AppTextVariant.label => textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      AppTextVariant.caption => textTheme.bodySmall?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    };
    return base?.copyWith(
      height: banglaSafeHeight,
      letterSpacing: 0,
      color: base.color ?? scheme.onSurface,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = resolveStyle(
      context,
      variant,
    )?.copyWith(color: color, fontWeight: fontWeight).merge(style);
    return Text(
      data,
      style: resolved,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      softWrap: softWrap,
      semanticsLabel: semanticsLabel,
    );
  }
}
