// Post author line: avatar, name with posted time, optional location, and
// an overflow menu button. Long names and meta labels wrap, never clip.
import 'author_row_dependencies.dart';

class AuthorRow extends StatelessWidget {
  const AuthorRow({super.key, required this.post, this.onMore});

  final CommunityPost post;

  /// Overflow menu; screen readers get a 'More options' button.
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final author = post.author;
    final location = author.location;
    final timeLabel = formatCommunityTimeAgo(post.postedAt);
    return Row(
      children: [
        CommunityAvatar(
          initials: author.initials,
          semanticsLabel: author.displayName,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.label(author.displayName, fontWeight: FontWeight.w600),
              const SizedBox(height: 2),
              AppText.caption(
                location == null ? timeLabel : '$location · $timeLabel',
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        CommunityIconButton(
          icon: HugeIcons.strokeRoundedMoreHorizontal,
          tooltip: 'More options',
          color: AppColors.textSecondary,
          onPressed: onMore,
        ),
      ],
    );
  }
}
