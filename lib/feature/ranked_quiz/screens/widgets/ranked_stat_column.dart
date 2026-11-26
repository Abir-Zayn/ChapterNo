// One metric in a ranked stats row: big value, status pill, and caption.
// Used by the entry profile panel and the results summary card.
import 'ranked_widgets_imports.dart';

class RankedStatColumn extends StatelessWidget {
  const RankedStatColumn({
    super.key,
    required this.value,
    required this.caption,
    this.pill,
    this.icon,
    this.iconColor,
  });

  final String value;
  final String caption;
  final Widget? pill;
  final IconData? icon;

  /// Defaults to the theme primary colour.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: AppSizes.iconMd,
            color: iconColor ?? context.primary,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        FittedBox(
          fit: BoxFit.scaleDown,
          child: AppText.headline(value, fontWeight: FontWeight.w700),
        ),
        if (pill != null) ...[const SizedBox(height: AppSpacing.xs), pill!],
        const SizedBox(height: AppSpacing.xs),
        AppText.caption(
          caption,
          color: AppColors.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Lays out stat columns in equal-width cells separated by thin dividers.
class RankedStatRow extends StatelessWidget {
  const RankedStatRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        cells.add(const VerticalDivider(width: 1, color: AppColors.border));
      }
      cells.add(Expanded(child: children[i]));
    }
    return IntrinsicHeight(child: Row(children: cells));
  }
}
