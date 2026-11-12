// Footer prompt that switches between auth screens, for example
// "Have an account? Log in". Wraps onto two lines on narrow or large text.
import 'auth_widgets_imports.dart';

class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onAction,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppText(
          prompt,
          color: AppColors.textSecondary,
          style: const TextStyle(fontSize: 14),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
          child: AppText.label(actionLabel, color: AppColors.primaryPressed),
        ),
      ],
    );
  }
}
