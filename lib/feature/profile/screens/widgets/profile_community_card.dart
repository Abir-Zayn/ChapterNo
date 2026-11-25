// Community profile summary card and Learning Pace modal picker for Profile.
// Keeps ProfilePage focused on top-level screen composition.
import 'widgets_imports.dart';

class ProfileCommunityCard extends StatelessWidget {
  const ProfileCommunityCard({
    super.key,
    required this.postsCount,
    required this.notesCount,
    required this.onTap,
  });

  final int postsCount;
  final int notesCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const AppText.title('My Community Profile'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.successSoft,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const AppText.caption(
                        'Public',
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText.caption(
                  'View your peer solutions, $postsCount posts & $notesCount notes',
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const Icon(
            PhosphorIconsRegular.arrowRight,
            size: AppSizes.iconMd,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

Future<String?> showLearningPacePicker(
  BuildContext context,
  String currentPace,
) {
  const paces = ['Light', 'Standard', 'Intensive'];
  return showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.sheet),
      ),
    ),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: AppText.title('Select Learning Pace'),
          ),
          for (final pace in paces)
            ListTile(
              title: AppText(pace),
              trailing: pace == currentPace
                  ? Icon(PhosphorIconsRegular.check, color: context.primary)
                  : null,
              onTap: () => Navigator.of(sheetContext).pop(pace),
            ),
        ],
      ),
    ),
  );
}
