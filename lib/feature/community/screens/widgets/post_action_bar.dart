// Interaction bar under a post: vote pill, comment count, share, and save.
import 'post_action_bar_dependencies.dart';

class PostActionBar extends StatelessWidget {
  const PostActionBar({
    super.key,
    required this.post,
    required this.onVote,
    this.onComments,
    this.onShare,
    this.onToggleSaved,
  });

  final CommunityPost post;

  /// Receives the direction the student tapped (up or down).
  final ValueChanged<VoteValue> onVote;
  final VoidCallback? onComments;
  final VoidCallback? onShare;
  final VoidCallback? onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        VotePill(
          score: post.score,
          myVote: post.myVote,
          onVoteUp: () => onVote(VoteValue.up),
          onVoteDown: () => onVote(VoteValue.down),
        ),
        const SizedBox(width: AppSpacing.sm),
        _PillButton(
          tooltip: 'Comments',
          icon: PhosphorIconsRegular.chatCircle,
          label: '${post.commentCount}',
          onTap: onComments,
        ),
        AppIconButton(
          icon: PhosphorIconsRegular.shareFat,
          tooltip: 'Share post',
          onPressed: onShare,
        ),
        AppIconButton(
          icon: post.saved
              ? PhosphorIconsFill.bookmark
              : PhosphorIconsRegular.bookmarkSimple,
          tooltip: post.saved ? 'Remove from saved' : 'Save post',
          color: post.saved ? AppColors.primary : null,
          onPressed: onToggleSaved,
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.tooltip,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$tooltip: $label',
      enabled: onTap != null,
      excludeSemantics: true,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            height: AppSizes.minTouch,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceSunken,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: AppSizes.iconSm,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                AppText.label(label, maxLines: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
