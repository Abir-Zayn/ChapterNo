// Centered progress indicator with an optional message for loading states.
// Announces the message to screen readers via a live region.
import 'app_loader_imports.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.message, this.size = 32});

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    final text = message;
    return Center(
      child: Semantics(
        liveRegion: true,
        label: text,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: size,
              child: const CircularProgressIndicator(strokeWidth: 3),
            ),
            if (text != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppText.caption(text, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
