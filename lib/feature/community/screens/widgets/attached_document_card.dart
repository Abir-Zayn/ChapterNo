// Displays the local sample PDF and its metadata on the notes form.
// Clearly distinguishes the sample attachment from a verified upload.
import 'community_widgets_imports.dart';

class AttachedDocumentCard extends StatelessWidget {
  const AttachedDocumentCard({
    super.key,
    required this.document,
    required this.isLoading,
    this.onReplace,
    this.onRemove,
  });
  final PostDocument? document;
  final bool isLoading;
  final VoidCallback? onReplace, onRemove;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppText.label('Attached Document'),
          AppButton(
            label: 'Replace PDF',
            variant: AppButtonVariant.text,
            onPressed: onReplace,
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      if (isLoading)
        const AppLoader()
      else
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    PhosphorIconsRegular.filePdf,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppText.label(
                      document?.fileName ?? 'No document attached',
                    ),
                  ),
                  AppIconButton(
                    icon: PhosphorIconsRegular.trashSimple,
                    tooltip: 'Remove attachment',
                    onPressed: onRemove,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppText.caption(
                document?.metaLabel ?? '',
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText.caption(
                'Sample document · not uploaded',
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
    ],
  );
}
