// Consent sentence with tappable Terms of Service and Privacy Policy links.
// Links are underlined and bold so they do not rely on colour alone;
// owns and disposes its tap recognizers.
import 'auth_widgets_imports.dart';

class LegalConsentText extends StatefulWidget {
  const LegalConsentText({
    super.key,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
  });

  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  @override
  State<LegalConsentText> createState() => _LegalConsentTextState();
}

class _LegalConsentTextState extends State<LegalConsentText> {
  late final TapGestureRecognizer _terms = TapGestureRecognizer()
    ..onTap = () => widget.onOpenTerms();
  late final TapGestureRecognizer _privacy = TapGestureRecognizer()
    ..onTap = () => widget.onOpenPrivacy();

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = AppText.resolveStyle(
      context,
      AppTextVariant.caption,
    )?.copyWith(fontSize: 13, color: AppColors.textSecondary);
    final link = base?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: 'By signing up, you accept ChapterNo’s '),
          TextSpan(text: 'Terms of Service', style: link, recognizer: _terms),
          const TextSpan(text: ' and '),
          TextSpan(text: 'Privacy Policy', style: link, recognizer: _privacy),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
