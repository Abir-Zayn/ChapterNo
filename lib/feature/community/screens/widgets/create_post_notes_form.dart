// Notes form for create-post: attached sample PDF, title, subject and
// chapter pickers, description, and the sharing guidelines.
import '../create_post_page_imports.dart';

class CreatePostNotesForm extends StatelessWidget {
  const CreatePostNotesForm({
    super.key,
    required this.titleController,
    required this.bodyController,
    required this.state,
    required this.onSubjectSelected,
    required this.onChapterSelected,
    required this.onFeatureUnavailable,
  });

  final TextEditingController titleController;
  final TextEditingController bodyController;

  /// Subject, chapter choices, and attachment state live in the cubit.
  final CreatePostState state;
  final ValueChanged<String> onSubjectSelected;
  final ValueChanged<String> onChapterSelected;
  final ValueChanged<String> onFeatureUnavailable;

  static const List<String> _guidelineBullets = [
    'Your notes will be visible to all verified SSC batch peers across '
        'ChapterNo.',
    'Please confirm that no personal phone numbers, coaching IDs, or private '
        'photos appear on the pages.',
    'Only upload your original study notes or open-source materials with '
        'study group permission.',
  ];

  @override
  Widget build(BuildContext context) {
    final chapters = state.chapters[state.subject] ?? const <String>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AttachedDocumentCard(
          document: state.document,
          isLoading: state.attachmentsLoading,
          onReplace: () => onFeatureUnavailable('Replacing the PDF'),
          onRemove: () => onFeatureUnavailable('Removing attachments'),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TitleFieldWithCounter(
                controller: titleController,
                label: 'Note Title',
                hint: 'e.g. SSC Biology Chapter 2 Revision Sheet',
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(child: AppText.label('Subject')),
                  const SizedBox(width: AppSpacing.xs),
                  AppText.caption('(required)', color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SubjectChipRow(
                selected: state.subject,
                onSelected: onSubjectSelected,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(child: AppText.label('Chapter')),
                  const SizedBox(width: AppSpacing.xs),
                  AppText.caption('(required)', color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (chapters.isEmpty)
                AppText.caption(
                  'Pick a subject first to choose its chapter.',
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                )
              else
                SizedBox(
                  height: AppSizes.minTouch,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: chapters.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) => Center(
                      child: CommunityChoiceChip(
                        label: chapters[index],
                        isSelected: chapters[index] == state.chapter,
                        onTap: () => onChapterSelected(chapters[index]),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: bodyController,
                label: 'Description (optional)',
                hint:
                    'Add chapter highlights, tips, or what is covered inside…',
                maxLines: 4,
                minLines: 2,
                validator: PostDraftValidator.bodyFieldError,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GuidelinesCard.bullets(
          title: 'Community Guidelines & Safety',
          bullets: _guidelineBullets,
        ),
      ],
    );
  }
}
