// Holds compile-time Supabase environment configuration and validation helpers.
// Rejects missing, malformed, or secret-tier keys before initialization.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Throws early if compile-time Supabase configuration is missing or invalid.
  static void validate() =>
      validateValues(url: supabaseUrl, publishableKey: supabasePublishableKey);

  /// Validates explicit [url] and [publishableKey] values before Supabase init.
  static void validateValues({
    required String url,
    required String publishableKey,
  }) {
    final trimmedUrl = url.trim();
    final trimmedKey = publishableKey.trim();
    if (trimmedUrl.isEmpty || trimmedKey.isEmpty) {
      throw StateError(
        'Missing Supabase config. Run with --dart-define-from-file=.env',
      );
    }

    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null ||
        !(uri.scheme == 'https' || uri.scheme == 'http') ||
        uri.host.isEmpty) {
      throw StateError(
        'Invalid SUPABASE_URL. Expected an http(s) URL with a non-empty host.',
      );
    }

    final lowerKey = trimmedKey.toLowerCase();
    if (lowerKey.startsWith('sb_secret_') ||
        lowerKey.contains('service_role')) {
      throw StateError(
        'Invalid SUPABASE_PUBLISHABLE_KEY. Never ship a privileged server key.',
      );
    }
  }
}
