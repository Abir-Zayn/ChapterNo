// Segmented meter showing used vs total slots, for daily attempts and
// question progress. The optional current index gets an outline ring.
import 'ranked_widgets_imports.dart';

class AttemptPips extends StatelessWidget {
  const AttemptPips({
    super.key,
    required this.filled,
    required this.total,
    this.current,
    this.height = 8,
    this.color,
  });

  final int filled;
  final int total;
  final int? current;
  final double height;

  /// Defaults to the theme primary colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$filled of $total',
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: i < filled
                      ? (color ?? context.primary)
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: i == current
                      ? Border.all(color: context.primarySoft, width: 2)
                      : null,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
