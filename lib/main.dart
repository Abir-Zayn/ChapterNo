// App entry point: builds the dependencies and starts ChapterNo.
// Auth uses the in-memory repository until Supabase is connected.
import 'main_imports.dart';

void main() {
  runApp(ChapterNoApp(authRepository: InMemoryAuthRepository()));
}
