// Horizontally scrolling subject filter pills for the Community feed.
// The first pill is always "All"; the active subject uses the filled style.
import 'community_widgets_imports.dart';

class SubjectPillBar extends StatelessWidget {
  const SubjectPillBar({
    super.key,
    required this.subjects,
    required this.selected,
    required this.onSelected,
  });

  /// Subject labels; [CommunitySubjects.all] may be included as "All".
  final List<String> subjects;
  final String selected;

  /// Null disables the bar, for example while loading.
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.minTouch,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final isSelected = subject == selected;
          return _SubjectPill(
            subject: subject,
            isSelected: isSelected,
            onTap: onSelected == null ? null : () => onSelected!(subject),
          );
        },
      ),
    );
  }
}

class _SubjectPill extends StatelessWidget {
  const _SubjectPill({
    required this.subject,
    required this.isSelected,
    required this.onTap,
  });

  final String subject;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      enabled: onTap != null,
      excludeSemantics: true,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Material(
          color: isSelected ? context.primary : AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: AppText.caption(
                subject,
                color: isSelected ? context.onPrimary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
