// Top bar widget displaying student greeting, cohort, streak, and coins.
// Provides quick glance status and action callbacks.
import 'home_widgets_imports.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.studentName,
    required this.cohortTitle,
    required this.streakDays,
    required this.chapterCoins,
    this.onNotificationTap,
    this.onProfileTap,
  });

  final String studentName;
  final String cohortTitle;
  final int streakDays;
  final int chapterCoins;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.title(
                    'Hello, $studentName 👋',
                    fontWeight: FontWeight.w700,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppText.caption(
                    cohortTitle,
                    color: AppColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusBadge(
                  icon: PhosphorIconsFill.fire,
                  iconColor: AppColors.primary,
                  label: '$streakDays d',
                  backgroundColor: AppColors.primarySoft,
                ),
                const SizedBox(width: AppSpacing.xs),
                _StatusBadge(
                  icon: PhosphorIconsFill.coins,
                  iconColor: AppColors.warning,
                  label: '$chapterCoins',
                  backgroundColor: AppColors.warningSoft,
                ),
                const SizedBox(width: AppSpacing.xxs),
                AppIconButton(
                  icon: PhosphorIconsRegular.bell,
                  tooltip: 'Notifications',
                  onPressed: onNotificationTap ?? () {},
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSm, color: iconColor),
          const SizedBox(width: AppSpacing.xs),
          AppText.label(
            label,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}
