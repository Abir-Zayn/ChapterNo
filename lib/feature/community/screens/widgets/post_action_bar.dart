// Interaction bar under a post: vote pill on the left, save on the right.
// Comments and sharing are not offered on posts yet.
import 'post_action_bar_dependencies.dart';

class PostActionBar extends StatelessWidget {
  const PostActionBar({
    super.key,
    required this.post,
    required this.onVote,
    this.onToggleSaved,
  });

  final CommunityPost post;

  /// Receives the direction the student tapped (up or down).
  final ValueChanged<VoteValue> onVote;
  final VoidCallback? onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        VotePill(
          score: post.score,
          myVote: post.myVote,
          onVoteUp: () => onVote(VoteValue.up),
          onVoteDown: () => onVote(VoteValue.down),
        ),
        const Spacer(),
        CommunityIconButton(
          icon: HugeIcons.strokeRoundedBookmark02,
          tooltip: post.saved ? 'Remove from saved' : 'Save post',
          color: post.saved ? context.primary : AppColors.textSecondary,
          onPressed: onToggleSaved,
        ),
      ],
    );
  }
}
