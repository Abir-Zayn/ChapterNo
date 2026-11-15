// Horizontally scrolling subject chips for create-post forms. The selected
// chip shows a check icon next to the label so selection is not color-only.
import 'community_widgets_imports.dart';

class SubjectChipRow extends StatelessWidget {
  const SubjectChipRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String? selected;

  /// Null disables the chips, for example while publishing.
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.minTouch,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: CommunitySubjects.selectable.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final subject = CommunitySubjects.selectable[index];
          return Center(
            child: CommunityChoiceChip(
              label: subject,
              isSelected: subject == selected,
              onTap: onSelected == null ? null : () => onSelected!(subject),
            ),
          );
        },
      ),
    );
  }
}
