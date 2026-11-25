// Full-width "Continue with <provider>" button with a provider logo.
// Light bordered style for Google, dark solid style for Apple; text scales
// and wraps to the available width instead of clipping.
import 'auth_widgets_imports.dart';

enum SocialAuthProvider { google, apple }

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  static const String googleLogoAsset = 'assets/illustrations/google_g.svg';

  final SocialAuthProvider provider;
  final VoidCallback? onPressed;

  String get _label => switch (provider) {
    SocialAuthProvider.google => 'Continue with Google',
    SocialAuthProvider.apple => 'Continue with Apple',
  };

  @override
  Widget build(BuildContext context) {
    final isApple = provider == SocialAuthProvider.apple;
    final foreground = isApple ? Colors.white : AppColors.textPrimary;
    final logo = isApple
        ? Icon(PhosphorIconsFill.appleLogo, size: AppSizes.iconMd)
        : SvgPicture.asset(
            googleLogoAsset,
            width: AppSizes.iconMd,
            height: AppSizes.iconMd,
          );
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            AppSizes.minTouch,
            AppSizes.buttonHeightLarge,
          ),
          backgroundColor: isApple ? AppColors.textPrimary : AppColors.surface,
          foregroundColor: foreground,
          side: BorderSide(
            color: isApple ? AppColors.textPrimary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(child: logo),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: AppText.label(
                _label,
                color: foreground,
                maxLines: 1,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
