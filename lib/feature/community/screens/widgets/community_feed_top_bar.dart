// Community feed top bar: profile avatar on the left, a search field in the
// centre, and a messages button on the right. Search and messages are
// placeholders until those features ship; callers decide what taps do.
import 'community_widgets_imports.dart';

class CommunityFeedTopBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CommunityFeedTopBar({
    super.key,
    required this.onOpenProfile,
    required this.onSearch,
    required this.onOpenMessages,
  });

  final VoidCallback onOpenProfile;
  final VoidCallback onSearch;
  final VoidCallback onOpenMessages;

  static const double _barHeight = 64;

  @override
  Size get preferredSize => const Size.fromHeight(_barHeight + 1);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: _barHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: 'My community profile',
                excludeSemantics: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  onTap: onOpenProfile,
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.xs),
                    child: CommunityAvatar(initials: 'AR', size: 40),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _SearchField(onTap: onSearch)),
              const SizedBox(width: AppSpacing.xs),
              CommunityIconButton(
                icon: HugeIcons.strokeRoundedMessage01,
                tooltip: 'Messages',
                onPressed: onOpenMessages,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Search community',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          height: AppSizes.minTouch,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceSunken,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: const Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                size: AppSizes.iconSm,
                color: AppColors.textSecondary,
                strokeWidth: 1.8,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText.label(
                  'Search community',
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
