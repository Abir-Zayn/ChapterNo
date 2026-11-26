// Verifies Env.validateValues rejects missing, malformed, and secret-tier
// keys while accepting valid hosted HTTPS and local HTTP Supabase URLs.
import 'env_test_imports.dart';

void main() {
  group('Env.validateValues', () {
    test('rejects empty and whitespace-only URL or key', () {
      for (final pair in const <(String, String)>[
        ('', 'sb_publishable_dummy'),
        ('   ', 'sb_publishable_dummy'),
        ('https://example.supabase.co', ''),
        ('https://example.supabase.co', '   '),
      ]) {
        expect(
          () => Env.validateValues(url: pair.$1, publishableKey: pair.$2),
          throwsStateError,
        );
      }
    });

    test('rejects unsupported schemes, malformed URLs, and missing hosts', () {
      for (final url in const <String>[
        'ftp://example.supabase.co',
        'not-a-url',
        'https://',
        'http:///path',
      ]) {
        expect(
          () => Env.validateValues(
            url: url,
            publishableKey: 'sb_publishable_dummy',
          ),
          throwsStateError,
        );
      }
    });

    test('rejects secret and privileged server keys case-insensitively', () {
      for (final key in const <String>[
        'sb_secret_dummy',
        'SB_SECRET_dummy',
        'service_role_dummy',
        'Service_Role_dummy',
      ]) {
        expect(
          () => Env.validateValues(
            url: 'https://example.supabase.co',
            publishableKey: key,
          ),
          throwsStateError,
        );
      }
    });

    test('accepts valid HTTPS hosted URL and HTTP local Supabase URL', () {
      expect(
        () => Env.validateValues(
          url: '  https://example.supabase.co  ',
          publishableKey: '  sb_publishable_dummy  ',
        ),
        returnsNormally,
      );
      expect(
        () => Env.validateValues(
          url: 'http://127.0.0.1:54321',
          publishableKey: 'sb_publishable_dummy',
        ),
        returnsNormally,
      );
    });
  });
}
