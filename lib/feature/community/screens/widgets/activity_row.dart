// One tappable row in the community activity log: kind icon, action title,
// timestamp, content summary, and subject chip with extra context.
import 'activity_row_dependencies.dart';

class ActivityRow extends StatelessWidget {
  const ActivityRow({super.key, required this.entry, this.onTap});

  final ActivityEntry entry;
  final VoidCallback? onTap;

  static const Map<ActivityKind, (IconData, Color)> _iconByKind = {
    ActivityKind.postPublished: (
      PhosphorIconsRegular.fileText,
      AppColors.primary,
    ),
    ActivityKind.commented: (
      PhosphorIconsRegular.chatCircleDots,
      AppColors.accentMoss,
    ),
    ActivityKind.upvoted: (PhosphorIconsRegular.thumbsUp, AppColors.accentClay),
    ActivityKind.questionShared: (
      PhosphorIconsRegular.question,
      AppColors.accentMoss,
    ),
    ActivityKind.notesShared: (
      PhosphorIconsRegular.bookBookmark,
      AppColors.accentClay,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (icon, tint) = _iconByKind[entry.kind]!;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, size: AppSizes.iconMd, color: tint),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText.label(
                          entry.title,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppText.caption(
                        formatCommunityTimeAgo(entry.at),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  AppText.caption(
                    entry.summary,
                    color: AppColors.textSecondary,
                    maxLines: 1,
                    fontWeight: FontWeight.w400,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      SubjectTag(label: entry.subject, dense: true),
                      const SizedBox(width: AppSpacing.xs + 2),
                      if (entry.detail != null)
                        Expanded(
                          child: AppText.caption(
                            entry.detail!,
                            color: AppColors.textSecondary,
                            maxLines: 1,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: Icon(
                PhosphorIconsRegular.caretRight,
                size: AppSizes.iconSm,
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
