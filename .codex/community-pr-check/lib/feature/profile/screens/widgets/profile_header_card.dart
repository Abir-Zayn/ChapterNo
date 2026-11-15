// Top identity banner for Student Profile Dashboard with avatar, cohort tag,
// notification action, and edit trigger.
import 'widgets_imports.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.onNotificationsTap,
    required this.onEditTap,
  });

  final StudentProfile profile;
  final VoidCallback onNotificationsTap;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadius.xl,
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primarySoft,
            child: AppText.title(
              profile.initials,
              color: AppColors.primaryPressed,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.title(
                  'Hi, ${profile.fullName.split(' ').first}!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText.caption(
                  '${profile.targetExam} • ${profile.academicGroup} Group',
                  color: AppColors.textSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: PhosphorIconsRegular.bell,
            tooltip: 'Notifications',
            onPressed: onNotificationsTap,
          ),
          const SizedBox(width: AppSpacing.xs),
          AppIconButton(
            icon: PhosphorIconsRegular.pencilSimple,
            tooltip: 'Edit profile',
            onPressed: onEditTap,
          ),
        ],
      ),
    );
  }
}
