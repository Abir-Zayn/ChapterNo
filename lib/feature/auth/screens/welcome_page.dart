// Entry screen for signed-out students: value statement and sign-up options.
// Composes auth widgets and forwards every action to callbacks; it performs
// no sign-in work itself. Apple sign-in is offered on iOS only.
import 'welcome_page_imports.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({
    super.key,
    required this.onContinueWithGoogle,
    required this.onContinueWithApple,
    required this.onSignUpWithEmail,
    required this.onLogIn,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
  });

  final VoidCallback onContinueWithGoogle;
  final VoidCallback onContinueWithApple;
  final VoidCallback onSignUpWithEmail;
  final VoidCallback onLogIn;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  @override
  Widget build(BuildContext context) {
    final showApple = Theme.of(context).platform == TargetPlatform.iOS;
    return AuthScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.xl),
          const Center(child: AuthHeroIllustration()),
          const SizedBox(height: AppSpacing.xxl),
          Semantics(
            header: true,
            child: const AppText(
              'Master every chapter.\nSign up for free.',
              variant: AppTextVariant.display,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, height: 1.25),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SocialAuthButton(
            provider: SocialAuthProvider.google,
            onPressed: onContinueWithGoogle,
          ),
          if (showApple) ...[
            const SizedBox(height: AppSpacing.md),
            SocialAuthButton(
              provider: SocialAuthProvider.apple,
              onPressed: onContinueWithApple,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Sign up with email',
            icon: PhosphorIconsRegular.envelopeSimple,
            size: AppButtonSize.large,
            expand: true,
            onPressed: onSignUpWithEmail,
          ),
          const SizedBox(height: AppSpacing.lg),
          LegalConsentText(
            onOpenTerms: onOpenTerms,
            onOpenPrivacy: onOpenPrivacy,
          ),
        ],
      ),
      footer: AuthSwitchPrompt(
        prompt: 'Have an account?',
        actionLabel: 'Log in',
        onAction: onLogIn,
      ),
    );
  }
}
