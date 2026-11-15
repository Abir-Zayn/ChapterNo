// Responsive 2-column KPI grid shared by Profile Dashboard and Analytics.
// Uses flexible intrinsic heights so large text scaling never overflows.
import 'widgets_imports.dart';

class ProfileStatItem {
  const ProfileStatItem({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.softBackground,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color softBackground;
}

class ProfileStatGrid extends StatelessWidget {
  const ProfileStatGrid({super.key, required this.items});

  final List<ProfileStatItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.md;
        final itemWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _StatCard(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final ProfileStatItem item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '${item.label}: ${item.value}, ${item.subtitle}',
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppText.caption(
                    item.label,
                    color: AppColors.textSecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: item.softBackground,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    item.icon,
                    size: AppSizes.iconSm,
                    color: item.accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText.headline(item.value),
            const SizedBox(height: AppSpacing.xxs),
            AppText.caption(
              item.subtitle,
              color: item.accentColor,
              fontWeight: FontWeight.w600,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
