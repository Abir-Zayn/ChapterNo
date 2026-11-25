// Fine print under the Plus benefits: fair-use and separately sold content
// notes followed by the Terms and conditions link.
import 'widgets_imports.dart';

class PlusFinePrint extends StatelessWidget {
  const PlusFinePrint({
    super.key,
    required this.footnotes,
    required this.onOpenTerms,
  });

  final List<String> footnotes;
  final VoidCallback onOpenTerms;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final note in footnotes)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: AppText.caption(note, color: AppColors.textSecondary),
          ),
        const SizedBox(height: AppSpacing.xs),
        TextButton(
          onPressed: onOpenTerms,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, AppSizes.minTouch),
            alignment: Alignment.centerLeft,
          ),
          child: const AppText.label(
            'Terms and conditions',
            color: AppColors.info,
          ),
        ),
      ],
    );
  }
}
