// Launch screen showing the ChapterNo brand while the session is checked.
// Listens to SplashCubit and hands the outcome to navigation callbacks;
// holds no timers or business logic of its own.
import 'splash_page_imports.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({
    super.key,
    required this.onSignedOut,
    required this.onSignedIn,
  });

  final VoidCallback onSignedOut;
  final VoidCallback onSignedIn;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashStatus>(
      listener: (context, status) => switch (status) {
        SplashStatus.checking => null,
        SplashStatus.signedOut => onSignedOut(),
        SplashStatus.signedIn => onSignedIn(),
      },
      child: const Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
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
          ),
        ),
      ),
    );
  }
}
