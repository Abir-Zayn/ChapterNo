// Temporary signed-in destination until the real Home screen is built.
// States plainly that this is a preview and offers sign-out; it shows no
// learning data because none exists yet.
import 'home_placeholder_page_imports.dart';

class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({
    super.key,
    required this.onSignOut,
    this.onOpenProfile,
  });

  final VoidCallback onSignOut;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: onOpenProfile == null
          ? null
          : AppBar(
              title: const Text('ChapterNo'),
              actions: [
                IconButton(
                  tooltip: 'Profile',
                  icon: const Icon(PhosphorIconsRegular.userCircle),
                  onPressed: onOpenProfile,
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/community'),
        label: const Text('Preview community'),
        icon: const Icon(PhosphorIconsRegular.users),
      ),
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
