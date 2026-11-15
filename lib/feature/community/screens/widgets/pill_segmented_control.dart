// Pill-shaped segmented control used for feed sorting, post-type picking,
// and profile tabs. Selected segments use the app's filled action style;
// every segment is a semantic option so screen readers announce selection.
import 'community_widgets_imports.dart';

/// One selectable segment of a [PillSegmentedControl].
class PillSegment<T> {
  const PillSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

class PillSegmentedControl<T> extends StatelessWidget {
  const PillSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  final List<PillSegment<T>> segments;
  final T selected;

  /// Null while [enabled] is false.
  final ValueChanged<T>? onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          for (var index = 0; index < segments.length; index++)
            Expanded(
              child: _Segment(
                segment: segments[index],
                isSelected: segments[index].value == selected,
                onTap: enabled && onSelected != null
                    ? () => onSelected!(segments[index].value)
                    : null,
                showDivider: index > 0,
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.segment,
    required this.isSelected,
    required this.onTap,
    required this.showDivider,
  });

  final PillSegment<dynamic> segment;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected
        ? AppColors.onPrimary
        : AppColors.textSecondary;
    final icon = segment.icon;
    return Semantics(
      selected: isSelected,
      button: true,
      enabled: onTap != null,
      excludeSemantics: true,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Material(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppSizes.iconSm, color: foreground),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Flexible(
                    child: AppText.caption(
                      segment.label,
                      color: foreground,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
