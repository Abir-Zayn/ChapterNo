// ChapterNo brand mark: coral book tile with an optional wordmark.
// Placeholder identity built from tokens until a final logo asset exists.
import 'auth_widgets_imports.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72, this.showWordmark = true});

  /// Edge length of the square tile.
  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final tile = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(
          PhosphorIconsFill.bookOpenText,
          size: size * 0.56,
          color: AppColors.onPrimary,
        ),
      ),
    );
    return Semantics(
      label: 'ChapterNo',
      image: true,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tile,
          if (showWordmark) ...[
            const SizedBox(height: AppSpacing.lg),
            const AppText(
              'ChapterNo',
              variant: AppTextVariant.display,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28),
            ),
          ],
        ],
      ),
    );
  }
}
