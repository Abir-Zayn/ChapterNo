// Confirmation shown after sign-up when email verification is required.
// Uses calm solid surfaces and clear next actions without leaving auth flow.
import 'auth_header.dart';
import 'auth_notice.dart';
import 'auth_widgets_imports.dart';

class EmailVerificationSentView extends StatelessWidget {
  const EmailVerificationSentView({
    super.key,
    required this.email,
    required this.onGoToLogin,
    required this.onUseDifferentEmail,
  });

  final String email;
  final VoidCallback onGoToLogin;
  final VoidCallback onUseDifferentEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const AuthHeader(
          title: 'Verify your email',
          subtitle: 'One quick step before setting up your study profile.',
        ),
        const SizedBox(height: AppSpacing.lg),
        AuthNotice(
          tone: AuthNoticeTone.info,
          message:
              'We sent a verification link to $email. Open the link in your '
              'inbox, then log in to continue.',
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Go to log in',
          size: AppButtonSize.large,
          expand: true,
          onPressed: onGoToLogin,
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
