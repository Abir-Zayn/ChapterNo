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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton(
                onPressed: () => context.push('/practice/cq'),
                child: const Text('Preview CQ examination'),
              ),
            ),
            Wrap(
              spacing: 12,
              children: [
                OutlinedButton(
                  onPressed: () => context.push('/community'),
                  child: const Text('Preview community'),
                ),
                OutlinedButton(
                  onPressed: () => context.push('/ranked'),
                  child: const Text('Preview ranked quiz'),
                ),
                OutlinedButton(
                  onPressed: () => context.push('/ranked/limit'),
                  child: const Text('Preview daily limit'),
                ),
              ],
            ),
            Expanded(
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
          ],
        ),
      ),
    );
  }
}
