// App entry point: runs cold-launch bootstrap and starts ChapterNoApp.
// Error handlers, startup prefs, and Supabase init complete before runApp.
// Missing compile-time Supabase config stops here with a visible screen
// instead of a blank launch.
import 'main_imports.dart';

Future<void> main() async {
  try {
    final dependencies = await bootstrap(requireEnv: true);
    runApp(ChapterNoApp.fromDependencies(dependencies));
  } on StateError catch (error) {
    runApp(_MissingConfigApp(message: error.message));
  }
}

/// Startup fallback shown when compile-time Supabase config is absent,
/// so a mis-built binary explains itself instead of showing nothing.
class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '$message\n\n'
              'Build or run the app with:\n'
              'flutter run --dart-define-from-file=.env',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
