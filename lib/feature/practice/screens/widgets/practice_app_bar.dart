// Fixed top app bar for the Practice Dashboard screen.
// Features brand indicator pill, screen title, notification bell, and user avatar.
import 'practice_widgets_imports.dart';

class PracticeAppBar extends StatelessWidget {
  const PracticeAppBar({super.key, this.onNotificationTap, this.onProfileTap});

  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const AppText(
                'Practice',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: onNotificationTap,
                icon: const Icon(
                  PhosphorIconsRegular.bell,
                  size: AppSizes.iconMd,
                  color: AppColors.textSecondary,
                ),
                tooltip: 'Notifications',
              ),
              const SizedBox(width: AppSpacing.xs),
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    PhosphorIconsRegular.user,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
