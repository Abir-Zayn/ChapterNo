// Section header for one chronological block of the activity log.
import 'activity_group_header_dependencies.dart';

class ActivityGroupHeader extends StatelessWidget {
  const ActivityGroupHeader({super.key, required this.group});

  final ActivityDayGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceAlt,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppText.caption(group.label, fontWeight: FontWeight.w700),
          ),
          AppText.caption(group.subtitle, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
