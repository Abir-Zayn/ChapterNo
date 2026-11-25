// Persistent bottom navigation bar aligning with ChapterNo's root navigation.
// Exposes tabs for Home, Practice, Community, and Profile.
import 'home_widgets_imports.dart';

enum HomeNavTab { home, practice, community, profile }

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final HomeNavTab currentTab;
  final ValueChanged<HomeNavTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  label: 'Home',
                  regularIcon: PhosphorIconsRegular.house,
                  fillIcon: PhosphorIconsFill.house,
                  isSelected: currentTab == HomeNavTab.home,
                  onTap: () => onTabSelected(HomeNavTab.home),
                ),
              ),
              Expanded(
                child: _NavItem(
                  label: 'Practice',
                  regularIcon: PhosphorIconsRegular.books,
                  fillIcon: PhosphorIconsFill.books,
                  isSelected: currentTab == HomeNavTab.practice,
                  onTap: () => onTabSelected(HomeNavTab.practice),
                ),
              ),
              Expanded(
                child: _NavItem(
                  label: 'Community',
                  regularIcon: PhosphorIconsRegular.users,
                  fillIcon: PhosphorIconsFill.users,
                  isSelected: currentTab == HomeNavTab.community,
                  onTap: () => onTabSelected(HomeNavTab.community),
                ),
              ),
              Expanded(
                child: _NavItem(
                  label: 'Profile',
                  regularIcon: PhosphorIconsRegular.user,
                  fillIcon: PhosphorIconsFill.user,
                  isSelected: currentTab == HomeNavTab.profile,
                  onTap: () => onTabSelected(HomeNavTab.profile),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.regularIcon,
    required this.fillIcon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData regularIcon;
  final IconData fillIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;
    final icon = isSelected ? fillIcon : regularIcon;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizes.iconMd, color: color),
            const SizedBox(height: 2),
            AppText.caption(
              label,
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
