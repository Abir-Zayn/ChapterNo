/// Compile-time config injected via `--dart-define-from-file=.env`.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Throws early if the app was built without `.env` values.
  static void validate() {
    if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
      throw StateError(
        'Missing Supabase config. Run with --dart-define-from-file=.env',
      );
    }
  }
}
