// Practice-question form for create-post: the attached sample question,
// title, optional commentary, automatic categorization notice, and a note
// about how classmates solve the shared question.
import '../create_post_page_imports.dart';

class CreatePostQuestionForm extends StatelessWidget {
  const CreatePostQuestionForm({
    super.key,
    required this.titleController,
    required this.bodyController,
    required this.state,
    required this.onFeatureUnavailable,
  });

  final TextEditingController titleController;
  final TextEditingController bodyController;

  /// Only [CreatePostState.question] and [CreatePostState.attachmentsLoading]
  /// are read here; the type keeps widget imports narrow.
  final CreatePostState state;
  final ValueChanged<String> onFeatureUnavailable;

  @override
  Widget build(BuildContext context) {
    final question = state.question;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AttachedQuestionCard(
          question: question,
          isLoading: state.attachmentsLoading,
          onReplace: () => onFeatureUnavailable('Replacing questions'),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TitleFieldWithCounter(
                controller: titleController,
                label: 'Post Title',
                hint: 'Can you solve this motion problem from today’s test?',
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: bodyController,
                label: 'Add your thought or hint (optional)',
                hint:
                    'e.g., I found question C tricky because of the constant '
                    'rate wording…',
                maxLines: 3,
                minLines: 2,
                prefixIcon: PhosphorIconsRegular.lightbulb,
                validator: PostDraftValidator.bodyFieldError,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _AutoCategorizedNotice(
          subject: question?.subject ?? CommunitySubjects.physics,
          topic: question?.topic ?? 'Motion',
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              PhosphorIconsRegular.usersThree,
              size: AppSizes.iconSm,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs + 2),
            Expanded(
              child: AppText.caption(
                'Classmates can tap "Solve Question" directly from your post '
                'in the Community feed.',
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AutoCategorizedNotice extends StatelessWidget {
  const _AutoCategorizedNotice({required this.subject, required this.topic});

  final String subject;
  final String topic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentMoss.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            PhosphorIconsRegular.tag,
            size: AppSizes.iconMd,
            color: AppColors.accentMoss,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText.caption(
              'Categorized automatically: $subject > Chapter: $topic. '
              'No manual tagging needed.',
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
