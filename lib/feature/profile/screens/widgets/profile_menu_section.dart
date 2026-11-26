// Grouped solid-surface menu section with accessible 48dp+ list rows.
// Reused by Student Profile Dashboard and Settings screens.
import 'widgets_imports.dart';

class ProfileMenuItem {
  const ProfileMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.trailingBadge,
    this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final String? trailingBadge;
  final VoidCallback? onTap;
  final bool isDestructive;
}

class ProfileMenuSection extends StatelessWidget {
  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.items,
    this.headerBadge,
  });

  final String title;
  final List<ProfileMenuItem> items;
  final String? headerBadge;

  @override
  Widget build(BuildContext context) {
    final badge = headerBadge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: AppText.label(title, color: AppColors.textSecondary),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: context.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: AppText.caption(
                    badge,
                    color: context.primaryStrong,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _MenuRow(item: items[i]),
                if (i < items.length - 1)
                  const Divider(height: 1, thickness: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item});

  final ProfileMenuItem item;

  @override
  Widget build(BuildContext context) {
    final fg = item.isDestructive ? AppColors.error : AppColors.textPrimary;
    final iconBg = item.isDestructive
        ? AppColors.errorSoft
        : AppColors.surfaceAlt;
    final iconColor = item.isDestructive
        ? AppColors.error
        : AppColors.textSecondary;
    final subtitle = item.subtitle;
    final trailingText = item.trailingText;
    final trailingBadge = item.trailingBadge;

    return InkWell(
      onTap: item.onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTouch + 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(item.icon, size: AppSizes.iconSm, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(item.title, color: fg, fontWeight: FontWeight.w500),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      AppText.caption(subtitle, color: AppColors.textSecondary),
                    ],
                  ],
                ),
              ),
              if (trailingBadge != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: context.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: AppText.caption(
                    trailingBadge,
                    color: context.primaryStrong,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (trailingText != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: AppText.caption(
                    trailingText,
                    color: AppColors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (item.onTap != null && !item.isDestructive) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  PhosphorIconsRegular.caretRight,
                  size: AppSizes.iconSm,
                  color: AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
