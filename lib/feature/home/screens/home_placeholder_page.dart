// Temporary signed-in destination until the real Home screen is built.
// States plainly that this is a preview and offers sign-out; it shows no
// learning data because none exists yet.
import 'home_placeholder_page_imports.dart';

class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AppStateView(
          icon: PhosphorIconsRegular.house,
          title: 'You are signed in',
          message:
              'Home is not built yet. This preview keeps accounts on this '
              'device only until the app is closed.',
          actionLabel: 'Sign out',
          onAction: onSignOut,
        ),
      ),
    );
  }
}
