// List of primary study modes corresponding to ChapterNo's learning loop.
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

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                indent: AppSpacing.lg,
                endIndent: AppSpacing.lg,
                color: AppColors.border,
              ),
            _ActionRow(
              item: actions[i],
              onTap: () => onActionSelected(actions[i].keyName),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.item, required this.onTap});

  final _ActionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.softColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: item.accentColor,
                  size: AppSizes.iconMd,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.label(item.title, fontWeight: FontWeight.w600),
                    const SizedBox(height: 2),
                    AppText.caption(
                      item.subtitle,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                PhosphorIconsRegular.caretRight,
                size: AppSizes.iconSm,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
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
