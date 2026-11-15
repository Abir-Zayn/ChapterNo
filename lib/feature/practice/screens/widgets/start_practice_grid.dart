// 2x2 grid displaying primary study modes from the Stitch Practice design.
// Includes Topic MCQ, Board MCQ, CQ Practice, and Ranked Quiz with a Timed pill badge.
import 'practice_widgets_imports.dart';

class StartPracticeGrid extends StatelessWidget {
  const StartPracticeGrid({
    super.key,
    required this.modes,
    required this.onModeSelected,
  });

  final List<PracticeModeItem> modes;
  final ValueChanged<PracticeModeItem> onModeSelected;

  (Color, Color, IconData) _resolveModeVisuals(PracticeModeType type) {
    return switch (type) {
      PracticeModeType.topicMcq => (
        AppColors.primary,
        AppColors.primarySoft,
        PhosphorIconsRegular.listChecks,
      ),
      PracticeModeType.boardMcq => (
        AppColors.info,
        AppColors.infoSoft,
        PhosphorIconsRegular.graduationCap,
      ),
      PracticeModeType.cqPractice => (
        AppColors.accentMoss,
        const Color(0xFFE5F4ED),
        PhosphorIconsRegular.notePencil,
      ),
      PracticeModeType.rankedQuiz => (
        AppColors.warning,
        AppColors.warningSoft,
        PhosphorIconsRegular.medal,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText.title('Start a Practice', fontWeight: FontWeight.w600),
        const SizedBox(height: 2),
        const AppText.caption(
          'Choose a mode tailored to your exam preparation',
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.02,
          ),
          itemBuilder: (context, index) {
            final mode = modes[index];
            final (accent, softBg, icon) = _resolveModeVisuals(mode.modeType);

            return AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              onTap: () => onModeSelected(mode),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: softBg,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(icon, color: accent, size: AppSizes.iconMd),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      if (mode.badge != null)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs + 2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSunken,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: AppText.caption(
                              mode.badge!,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          PhosphorIconsRegular.arrowRight,
                          size: 18,
                          color: AppColors.textDisabled,
                        ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.label(
                        mode.title,
                        fontWeight: FontWeight.w600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      AppText.caption(
                        mode.subtitle,
                        color: AppColors.textSecondary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
