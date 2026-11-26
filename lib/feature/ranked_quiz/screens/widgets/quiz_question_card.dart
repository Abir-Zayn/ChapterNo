// Question prompt card and bottom navigation controls for a live quiz.
// Purely presentational; the page owns question index and bookmarks.
import 'ranked_widgets_imports.dart';
import 'ranked_pill.dart';
import 'ranked_top_bar.dart';

class QuizQuestionCard extends StatelessWidget {
  const QuizQuestionCard({
    super.key,
    required this.prompt,
    required this.note,
    required this.bookmarked,
    required this.onToggleBookmark,
  });

  final String prompt;
  final String note;
  final bool bookmarked;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final color = bookmarked ? context.primary : AppColors.textSecondary;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: AppText.caption(
                  'QUESTION PROMPT',
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton.icon(
                onPressed: onToggleBookmark,
                icon: Icon(
                  bookmarked
                      ? PhosphorIconsFill.bookmarkSimple
                      : PhosphorIconsRegular.bookmarkSimple,
                  size: AppSizes.iconSm,
                  color: color,
                ),
                label: AppText.caption('Review Later', color: color),
              ),
            ],
          ),
          AppText(prompt, fontWeight: FontWeight.w500),
          const SizedBox(height: AppSpacing.md),
          RankedPill(
            label: note,
            icon: PhosphorIconsRegular.info,
            radius: AppRadius.sm,
          ),
        ],
      ),
    );
  }
}

class QuizBottomControls extends StatelessWidget {
  const QuizBottomControls({
    super.key,
    required this.index,
    required this.total,
    required this.isLast,
    required this.onPrevious,
    required this.onNext,
  });

  final int index;
  final int total;
  final bool isLast;
  final VoidCallback? onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              RankedSquareIconButton(
                icon: PhosphorIconsRegular.arrowLeft,
                tooltip: 'Previous question',
                onPressed: onPrevious,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: isLast ? 'Submit Quiz' : 'Next Question',
                  trailingIcon: isLast
                      ? PhosphorIconsRegular.check
                      : PhosphorIconsRegular.arrowRight,
                  size: AppButtonSize.large,
                  expand: true,
                  onPressed: onNext,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText.caption(
            'Question ${index + 1} of $total · Answers lock on completion',
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
