// One community post card: author or kind header, title, kind-specific
// content preview, and the interaction bar. Used by both the feed and the
// profile dashboard, which hides the author row.
import 'post_card_dependencies.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onVote,
    this.showAuthor = true,
    this.onComments,
    this.onShare,
    this.onToggleSaved,
    this.onOpenQuestion,
    this.onOpenDocument,
    this.onMore,
  });

  final CommunityPost post;

  /// Receives the vote direction the student tapped.
  final ValueChanged<VoteValue> onVote;

  /// Feed cards show the author; the profile dashboard shows a kind header.
  final bool showAuthor;
  final VoidCallback? onComments;
  final VoidCallback? onShare;
  final VoidCallback? onToggleSaved;
  final VoidCallback? onOpenQuestion;
  final VoidCallback? onOpenDocument;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final question = post.question;
    final document = post.document;
    final body = post.body;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showAuthor)
            AuthorRow(post: post, onMore: onMore)
          else
            _KindHeader(post: post, onMore: onMore),
          const SizedBox(height: AppSpacing.md),
          AppText.title(post.title),
          if (body != null) ...[
            const SizedBox(height: AppSpacing.sm),
            AppText.label(
              body,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              maxLines: 3,
            ),
          ],
          if (question != null) ...[
            const SizedBox(height: AppSpacing.md),
            PostQuestionPreview(question: question, onOpen: onOpenQuestion),
          ],
          if (document != null) ...[
            const SizedBox(height: AppSpacing.md),
            PostDocumentPreview(document: document, onOpen: onOpenDocument),
          ],
          if (post.topAnswerAuthor != null && post.topAnswerText != null) ...[
            const SizedBox(height: AppSpacing.md),
            _TopAnswerHighlight(
              author: post.topAnswerAuthor!,
              text: post.topAnswerText!,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          PostActionBar(
            post: post,
            onVote: onVote,
            onComments: onComments,
            onShare: onShare,
            onToggleSaved: onToggleSaved,
          ),
        ],
      ),
    );
  }
}

class _KindHeader extends StatelessWidget {
  const _KindHeader({required this.post, required this.onMore});

  final CommunityPost post;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SubjectTag(label: '${post.subject} · ${post.kindLabel}'),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          child: AppText.caption(
            formatCommunityTimeAgo(post.postedAt),
            color: AppColors.textSecondary,
            maxLines: 1,
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

class _TopAnswerHighlight extends StatelessWidget {
  const _TopAnswerHighlight({required this.author, required this.text});

  final String author;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            PhosphorIconsRegular.lightbulb,
            size: AppSizes.iconMd,
            color: AppColors.accentClay,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.caption(
                  'Top answer by $author',
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText.caption(
                  text,
                  color: AppColors.textSecondary,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
