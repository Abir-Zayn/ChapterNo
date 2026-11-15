// Interaction bar under a post: vote and comment pills on the left,
// share and save on the right. Left group wraps on narrow/large-text layouts.
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
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
              _CommentPill(count: post.commentCount, onTap: onComments),
            ],
          ),
        ),
        CommunityIconButton(
          icon: HugeIcons.strokeRoundedShare08,
          tooltip: 'Share post',
          color: AppColors.textSecondary,
          onPressed: onShare,
        ),
        CommunityIconButton(
          icon: HugeIcons.strokeRoundedBookmark02,
          tooltip: post.saved ? 'Remove from saved' : 'Save post',
          color: post.saved ? AppColors.primary : AppColors.textSecondary,
          onPressed: onToggleSaved,
        ),
      ],
    );
  }
}

class _CommentPill extends StatelessWidget {
  const _CommentPill({required this.count, required this.onTap});

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Comments: $count',
      enabled: onTap != null,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HugeIcon(
                icon: HugeIcons.strokeRoundedComment01,
                size: AppSizes.iconSm,
                color: AppColors.textSecondary,
                strokeWidth: 1.8,
              ),
              const SizedBox(width: AppSpacing.xs),
              AppText.label('$count', maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }
}
