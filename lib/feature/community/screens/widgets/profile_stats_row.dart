// Three-column contribution stats for the community profile dashboard.
import 'community_widgets_imports.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({super.key, required this.stats});

  final CommunityProfileStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Stat(value: '${stats.posts}', label: 'Posts'),
        ),
        Container(width: 1, height: AppSpacing.xl, color: AppColors.border),
        Expanded(
          child: _Stat(value: '${stats.notes}', label: 'Notes'),
        ),
        Container(width: 1, height: AppSpacing.xl, color: AppColors.border),
        Expanded(
          child: _Stat(
            value: '${stats.upvotes}',
            label: 'Upvotes',
            icon: PhosphorIconsFill.flame,
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.icon});

  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppSizes.iconSm, color: AppColors.accentClay),
              const SizedBox(width: AppSpacing.xs),
            ],
            AppText.title(value),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        AppText.caption(label, color: AppColors.textSecondary),
      ],
    );
  }
}
