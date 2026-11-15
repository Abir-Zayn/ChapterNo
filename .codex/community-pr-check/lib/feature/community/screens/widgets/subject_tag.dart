// Small subject pill with a colored dot, used on posts and activity rows.
// The label carries the meaning; the dot is decorative accent only.
import 'community_widgets_imports.dart';

class SubjectTag extends StatelessWidget {
  const SubjectTag({super.key, required this.label, this.dense = false});

  /// Full label, for example 'Physics · Motion'.
  final String label;

  /// Slightly smaller padding for compact rows such as the activity log.
  final bool dense;

  static const Map<String, Color> _dots = {
    CommunitySubjects.physics: AppColors.accentMoss,
    CommunitySubjects.chemistry: AppColors.accentClay,
    CommunitySubjects.biology: AppColors.accentMoss,
    CommunitySubjects.math: AppColors.accentClay,
    CommunitySubjects.higherMath: AppColors.accentClay,
    CommunitySubjects.english: AppColors.accentAmber,
    CommunitySubjects.bangla: AppColors.accentAmber,
  };

  @override
  Widget build(BuildContext context) {
    final subject = label.split(' · ').first.trim();
    final dot = _dots[subject] ?? AppColors.textSecondary;
    return Container(
      padding: dense
          ? const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xs + 2),
          Flexible(
            child: AppText.caption(
              label,
              maxLines: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
