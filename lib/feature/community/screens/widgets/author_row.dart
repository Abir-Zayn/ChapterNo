// Post author line: avatar, name with location and time, subject tag, and
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
      crossAxisAlignment: CrossAxisAlignment.center,
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
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.xs + 2,
                runSpacing: 0,
                children: [
                  AppText.label(
                    author.displayName,
                    fontWeight: FontWeight.w600,
                  ),
                  if (location != null)
                    AppText.caption(
                      '· $location',
                      color: AppColors.textSecondary,
                    ),
                  AppText.caption(
                    '· $timeLabel',
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              SubjectTag(label: '${post.subject} · ${post.topic}'),
            ],
          ),
        ),
        AppIconButton(
          icon: PhosphorIconsRegular.dotsThree,
          tooltip: 'More options',
          onPressed: onMore,
        ),
      ],
    );
  }
}
