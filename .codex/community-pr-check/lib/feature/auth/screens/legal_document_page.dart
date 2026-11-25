// Readable Terms of Service / Privacy Policy screen.
// Shows a title, last-updated date, draft notice, and numbered sections in
// a lazy list with a capped reading width; content is passed in.
import 'legal_document_page_imports.dart';

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({super.key, required this.document});

  final LegalDocument document;

  /// Rows before the sections: back button, header, and notice block.
  static const int _leadingRows = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gutter = constraints.maxWidth < AppSizes.narrowBreakpoint
                ? AppSpacing.lg
                : AppSpacing.gutter;
            final side = ((constraints.maxWidth - AppSizes.contentMaxWidth) / 2)
                .clamp(gutter, double.infinity);
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                side,
                AppSpacing.sm,
                side,
                AppSpacing.xxl,
              ),
              itemCount: document.sections.length + _leadingRows,
              itemBuilder: (context, index) => switch (index) {
                0 => const AuthBackButton(),
                1 => _Intro(document: document),
                _ => LegalSectionView(
                  number: index - _leadingRows + 1,
                  section: document.sections[index - _leadingRows],
                ),
              },
            );
          },
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthHeader(title: document.title, subtitle: document.summary),
        const SizedBox(height: AppSpacing.sm),
        AppText.caption('Last updated ${document.lastUpdated}'),
        if (document.isDraft) ...[
          const SizedBox(height: AppSpacing.lg),
          const AuthNotice(
            message:
                'Draft wording for review. The final version will be '
                'published before ChapterNo is released.',
          ),
        ],
      ],
    );
  }
}
