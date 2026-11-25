// App entry point: runs cold-launch bootstrap and starts ChapterNoApp.
// Error handlers, startup prefs, and Supabase init complete before runApp.
import 'main_imports.dart';

Future<void> main() async {
  final dependencies = await bootstrap(requireEnv: true);
  runApp(ChapterNoApp.fromDependencies(dependencies));
}
