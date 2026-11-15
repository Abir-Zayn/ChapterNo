// Grid of primary study modes corresponding to ChapterNo's learning loop.
// Enables direct entry into MCQs, Mistake Notebook, CQ practice, and Diagnostics.
import 'home_widgets_imports.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key, required this.onActionSelected});

  final ValueChanged<String> onActionSelected;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        title: 'Board MCQs',
        subtitle: 'Official exam questions',
        icon: PhosphorIconsRegular.listChecks,
        accentColor: AppColors.info,
        softColor: AppColors.infoSoft,
        keyName: 'mcq',
      ),
      _ActionItem(
        title: 'Mistake Notebook',
        subtitle: 'Fix past errors',
        icon: PhosphorIconsRegular.notebook,
        accentColor: AppColors.error,
        softColor: AppColors.errorSoft,
        keyName: 'mistakes',
      ),
      _ActionItem(
        title: 'Creative Questions',
        subtitle: 'CQ evaluation',
        icon: PhosphorIconsRegular.penNib,
        accentColor: AppColors.success,
        softColor: AppColors.successSoft,
        keyName: 'cq',
      ),
      _ActionItem(
        title: 'Diagnostic Test',
        subtitle: 'Find weak topics',
        icon: PhosphorIconsRegular.chartLineUp,
        accentColor: AppColors.warning,
        softColor: AppColors.warningSoft,
        keyName: 'diagnostic',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          onTap: () => onActionSelected(item.keyName),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.softColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  item.icon,
                  color: item.accentColor,
                  size: AppSizes.iconMd,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.label(
                    item.title,
                    fontWeight: FontWeight.w600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  AppText.caption(
                    item.subtitle,
                    color: AppColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.softColor,
    required this.keyName,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color softColor;
  final String keyName;
}
