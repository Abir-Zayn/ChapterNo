// Card displaying the student's most recent in-progress learning session.
// Allows fast resumption of chapter reading and practice.
import 'home_widgets_imports.dart';

class ContinueLearningCard extends StatelessWidget {
  const ContinueLearningCard({
    super.key,
    required this.session,
    required this.onResume,
  });

  final LearningSession session;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onResume,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.infoSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              PhosphorIconsRegular.bookOpen,
              color: AppColors.info,
              size: AppSizes.iconMd,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.xs,
                  runSpacing: 2,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: AppText.caption(
                        session.subjectName,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppText.caption(
                      '• ${session.lastStudiedText}',
                      color: AppColors.textDisabled,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  session.chapterTitle,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: LinearProgressIndicator(
                          value: session.progressRatio,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceSunken,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.info,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppText.caption(
                      '${session.progressPercentage}%',
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            PhosphorIconsRegular.caretRight,
            size: AppSizes.iconSm,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
