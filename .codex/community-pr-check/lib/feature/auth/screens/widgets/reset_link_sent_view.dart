// Confirmation shown after a password-reset request is accepted.
// Wording does not reveal whether an account exists for the address.
import 'auth_header.dart';
import 'auth_notice.dart';
import 'auth_widgets_imports.dart';

class ResetLinkSentView extends StatelessWidget {
  const ResetLinkSentView({
    super.key,
    required this.email,
    required this.onBackToLogin,
    required this.onUseDifferentEmail,
  });

  final String email;
  final VoidCallback onBackToLogin;
  final VoidCallback onUseDifferentEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const AuthHeader(title: 'Check your email'),
        const SizedBox(height: AppSpacing.lg),
        AuthNotice(
          tone: AuthNoticeTone.success,
          message:
              'If an account exists for $email, a reset link is on its '
              'way. It can take a few minutes to arrive.',
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Back to log in',
          size: AppButtonSize.large,
          expand: true,
          onPressed: onBackToLogin,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Use a different email',
          variant: AppButtonVariant.text,
          expand: true,
          onPressed: onUseDifferentEmail,
        ),
      ],
    );
  }
}
