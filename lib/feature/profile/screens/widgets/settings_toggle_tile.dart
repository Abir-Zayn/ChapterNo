// Grouped toggle rows for Settings boolean preferences such as notifications,
// sound effects, haptics, and dark mode.
import 'widgets_imports.dart';

class SettingsToggleItem {
  const SettingsToggleItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
}

class SettingsToggleCard extends StatelessWidget {
  const SettingsToggleCard({super.key, required this.items});

  final List<SettingsToggleItem> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            SwitchListTile.adaptive(
              value: items[i].value,
              onChanged: items[i].onChanged,
              activeTrackColor: AppColors.primary,
              secondary: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  items[i].icon,
                  size: AppSizes.iconSm,
                  color: AppColors.textSecondary,
                ),
              ),
              title: AppText(items[i].title, fontWeight: FontWeight.w500),
            ),
            if (i < items.length - 1) const Divider(height: 1, thickness: 1),
          ],
        ],
      ),
    );
  }
}
