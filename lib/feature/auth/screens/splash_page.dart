// Launch screen showing the ChapterNo brand while the session and
// onboarding gate are checked. Hands routing outcomes to navigation
// callbacks; a failed gate check offers retry or sign-out instead.
import 'splash_page_imports.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({
    super.key,
    required this.onSignedOut,
    required this.onNeedsOnboarding,
    required this.onSignedIn,
    required this.onRetry,
    required this.onSignOutFromFailure,
  });

  final VoidCallback onSignedOut;
  final VoidCallback onNeedsOnboarding;
  final VoidCallback onSignedIn;
  final VoidCallback onRetry;
  final VoidCallback onSignOutFromFailure;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplashCubit, SplashStatus>(
      listener: (context, status) => switch (status) {
        SplashStatus.checking || SplashStatus.profileLoadFailed => null,
        SplashStatus.signedOut => onSignedOut(),
        SplashStatus.needsOnboarding => onNeedsOnboarding(),
        SplashStatus.ready => onSignedIn(),
      },
      builder: (context, status) {
        final body = status == SplashStatus.profileLoadFailed
            ? AppStateView.error(
                title: 'Could not load your profile',
                message:
                    'Your sign-in is safe. Check your connection and '
                    'try again, or sign out and start over.',
                actionLabel: 'Try again',
                onAction: onRetry,
                secondaryActionLabel: 'Sign out',
                onSecondaryAction: onSignOutFromFailure,
              )
            : _brandContent;
        return Scaffold(body: SafeArea(child: body));
      },
    );
  }

  Widget get _brandContent => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BrandMark(size: 88),
          SizedBox(height: AppSpacing.sm),
          AppText(
            'Master every chapter.',
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
