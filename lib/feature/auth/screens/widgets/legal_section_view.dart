// Renders one numbered section of a legal document: heading and paragraphs.
// Uses reading-friendly line height and marks the heading for screen readers.
import 'auth_widgets_imports.dart';

class LegalSectionView extends StatelessWidget {
  const LegalSectionView({
    super.key,
    required this.number,
    required this.section,
  });

  final int number;
  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: AppText.title(
              '$number. ${section.heading}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          for (final paragraph in section.paragraphs)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: AppText(
                paragraph,
                color: AppColors.textSecondary,
                style: const TextStyle(height: 1.55),
              ),
            ),
        ],
      ),
    );
  }
}
