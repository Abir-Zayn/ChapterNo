// Preview of a PDF document attached to a notes post: file icon, name,
// page and size metadata, and a view action.
import 'community_widgets_imports.dart';

class PostDocumentPreview extends StatelessWidget {
  const PostDocumentPreview({super.key, required this.document, this.onOpen});

  final PostDocument document;

  /// Opens the document; hidden integrations keep this disabled.
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: const Icon(
              PhosphorIconsRegular.filePdf,
              size: AppSizes.iconLg,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.label(
                  document.fileName,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText.caption(
                  document.metaLabel,
                  color: AppColors.textSecondary,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton(
            label: 'View PDF',
            variant: AppButtonVariant.outline,
            onPressed: onOpen,
          ),
        ],
      ),
    );
  }
}
