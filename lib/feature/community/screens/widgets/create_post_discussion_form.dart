// Discussion form for create-post: subject picker, title with counter,
// description, quick media toolbar, and the privacy callout.
import '../create_post_page_imports.dart';

class CreatePostDiscussionForm extends StatelessWidget {
  const CreatePostDiscussionForm({
    super.key,
    required this.titleController,
    required this.bodyController,
    required this.subject,
    required this.onSubjectSelected,
    required this.onFeatureUnavailable,
  });

  final TextEditingController titleController;
  final TextEditingController bodyController;
  final String? subject;
  final ValueChanged<String> onSubjectSelected;
  final ValueChanged<String> onFeatureUnavailable;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    PhosphorIconsRegular.bookOpenText,
                    size: AppSizes.iconMd,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: AppText.label('Subject')),
                  const SizedBox(width: AppSpacing.xs),
                  AppText.caption('(required)', color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText.caption(
                'Select a subject to help classmates find your question',
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
              const SizedBox(height: AppSpacing.md),
              SubjectChipRow(selected: subject, onSelected: onSubjectSelected),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TitleFieldWithCounter(
                controller: titleController,
                label: 'Title',
                hint: 'Ask your academic question clearly…',
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: bodyController,
                label: 'Description / Details (optional)',
                hint: 'Add background context or specific doubts…',
                maxLines: 5,
                minLines: 3,
                validator: PostDraftValidator.bodyFieldError,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _MediaToolbar(onFeatureUnavailable: onFeatureUnavailable),
        const SizedBox(height: AppSpacing.md),
        GuidelinesCard(
          title: 'Community & Privacy Shield',
          message:
              'Your display name will be visible to classmates. Keep '
              'discussions safe and never share personal phone numbers.',
        ),
      ],
    );
  }
}

class _MediaToolbar extends StatelessWidget {
  const _MediaToolbar({required this.onFeatureUnavailable});

  final ValueChanged<String> onFeatureUnavailable;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _ToolbarButton(
                  icon: PhosphorIconsRegular.image,
                  label: 'Add Diagram',
                  onPressed: () => onFeatureUnavailable('Adding diagrams'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ToolbarButton(
                  icon: PhosphorIconsRegular.function,
                  label: 'Math Formula',
                  onPressed: () =>
                      onFeatureUnavailable('Inserting math formulas'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                PhosphorIconsRegular.lightbulb,
                size: AppSizes.iconSm,
                color: AppColors.accentClay,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Expanded(
                child: AppText.caption(
                  'Keep discussions focused on SSC curriculum topics.',
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: AppSizes.iconSm),
      label: AppText.caption(label),
    );
  }
}
