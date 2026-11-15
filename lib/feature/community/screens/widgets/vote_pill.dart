// Upvote/downvote pill for posts. Score shifts live with the student's
// vote; the active direction icon is tinted so the state is visible.
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
    final upColor = myVote == VoteValue.up
        ? AppColors.primary
        : AppColors.textSecondary;
    final downColor = myVote == VoteValue.down
        ? AppColors.primary
        : AppColors.textSecondary;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onVoteUp,
            tooltip: 'Upvote',
            icon: Icon(
              myVote == VoteValue.up
                  ? PhosphorIconsFill.arrowFatUp
                  : PhosphorIconsRegular.arrowFatUp,
              size: AppSizes.iconMd,
              color: upColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: AppText.label(
              '$score',
              color: active ? AppColors.primary : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            onPressed: onVoteDown,
            tooltip: 'Downvote',
            icon: Icon(
              myVote == VoteValue.down
                  ? PhosphorIconsFill.arrowFatDown
                  : PhosphorIconsRegular.arrowFatDown,
              size: AppSizes.iconMd,
              color: downColor,
            ),
          ),
        ],
      ),
    );
  }
}
