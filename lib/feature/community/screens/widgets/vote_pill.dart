// Upvote/downvote pill for posts. Score shifts live with the student's
// vote; the active direction is tinted and the pill gains a soft fill.
import 'community_widgets_imports.dart';

class VotePill extends StatelessWidget {
  const VotePill({
    super.key,
    required this.score,
    required this.myVote,
    required this.onVoteUp,
    required this.onVoteDown,
  });

  final int score;
  final VoteValue myVote;

  final VoidCallback? onVoteUp;
  final VoidCallback? onVoteDown;

  @override
  Widget build(BuildContext context) {
    final active = myVote != VoteValue.none;
    return Container(
      decoration: BoxDecoration(
        color: active ? context.primarySoft : AppColors.surface,
        border: Border.all(
          color: active ? context.primarySoft : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommunityIconButton(
            icon: HugeIcons.strokeRoundedArrowUp02,
            tooltip: 'Upvote',
            color: myVote == VoteValue.up
                ? context.primary
                : AppColors.textSecondary,
            onPressed: onVoteUp,
          ),
          AppText.label(
            '$score',
            color: active ? context.primary : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          CommunityIconButton(
            icon: HugeIcons.strokeRoundedArrowDown02,
            tooltip: 'Downvote',
            color: myVote == VoteValue.down
                ? context.primary
                : AppColors.textSecondary,
            onPressed: onVoteDown,
          ),
        ],
      ),
    );
  }
}
