// Header section introducing the practice screen and providing quick search access.
// Displays the student greeting, motivational tagline, and circular search button.
import 'practice_widgets_imports.dart';

class PracticeGreetingHeader extends StatelessWidget {
  const PracticeGreetingHeader({super.key, this.onSearchTap});

  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.headline('Practice', fontWeight: FontWeight.w700),
              SizedBox(height: 2),
              AppText(
                'Keep practicing. Keep improving.',
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Material(
          color: AppColors.surfaceSunken,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onSearchTap,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                PhosphorIconsRegular.magnifyingGlass,
                color: AppColors.textPrimary,
                size: AppSizes.iconMd,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
