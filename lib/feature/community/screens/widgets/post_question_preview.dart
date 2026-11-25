// Preview of a practice question attached to a post: badge, stem, and
// either MCQ options or a CQ stimulus with its parts. Answers stay hidden;
// the trailing link opens the full question for solving.
import 'community_widgets_imports.dart';

class PostQuestionPreview extends StatelessWidget {
  const PostQuestionPreview({super.key, required this.question, this.onOpen});

  final PostQuestion question;

  /// Opens the full question; shown as a trailing link.
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                question.isCreative
                    ? PhosphorIconsRegular.article
                    : PhosphorIconsRegular.question,
                size: AppSizes.iconSm,
                color: context.primary,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              AppText.caption(
                question.badgeLabel,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border),
                ),
                child: AppText.caption(
                  question.sourceLabel,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppText.label(question.stem, fontWeight: FontWeight.w400),
          if (question.options.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final option in question.options)
                  _OptionTile(option: option),
              ],
            ),
          ],
          if (question.isCreative) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: AppText.caption(
                '"${question.stem}"',
                color: AppColors.textSecondary,
                maxLines: 3,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final part in question.parts)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: AppText.caption(
                  part,
                  color: AppColors.textSecondary,
                  maxLines: 1,
                ),
              ),
          ],
          if (onOpen != null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AppButton(
                label: question.isCreative
                    ? 'View Full Question & Stimulus'
                    : 'View Question & Solve',
                variant: AppButtonVariant.text,
                trailingIcon: PhosphorIconsRegular.arrowRight,
                onPressed: onOpen,
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.option});

  final PostOption option;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.caption(
            option.label,
            color: context.primary,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(width: AppSpacing.xs + 2),
          Flexible(child: AppText.caption(option.text)),
        ],
      ),
    );
  }
}
