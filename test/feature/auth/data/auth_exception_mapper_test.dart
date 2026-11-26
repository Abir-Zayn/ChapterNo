// Verifies AuthExceptionMapper mappings from Supabase, network, and timeout
// errors to safe AuthFailure values without exposing raw error text.
import 'supabase_auth_repository_test_imports.dart';

class _FakeClientException implements Exception {}

void main() {
  group('AuthExceptionMapper', () {
    test('maps network and timeout errors to AuthFailure.network', () {
      expect(
        AuthExceptionMapper.map(const SocketException('Offline')),
        AuthFailure.network,
      );
      expect(
        AuthExceptionMapper.map(TimeoutException('Timed out')),
        AuthFailure.network,
      );
      expect(
        AuthExceptionMapper.map(_FakeClientException()),
        AuthFailure.network,
      );
      expect(
        AuthExceptionMapper.map(
          AuthRetryableFetchException(message: 'Failed host lookup'),
        ),
        AuthFailure.network,
      );
      expect(
        AuthExceptionMapper.map(
          const AuthApiException(
            'timeout',
            code: 'request_timeout',
            statusCode: '408',
          ),
        ),
        AuthFailure.network,
      );
    });

    test('maps 5xx AuthRetryableFetchException to AuthFailure.unavailable', () {
      expect(
        AuthExceptionMapper.map(
          AuthRetryableFetchException(
            message: 'Bad gateway',
            statusCode: '502',
          ),
        ),
        AuthFailure.unavailable,
      );
      expect(
        AuthExceptionMapper.map(
          const AuthApiException('Service unavailable', statusCode: '503'),
        ),
        AuthFailure.unavailable,
      );
    });

    test('maps AuthWeakPasswordException and weak_password code', () {
      expect(
        AuthExceptionMapper.map(
          AuthWeakPasswordException(
            message: 'Too weak',
            statusCode: '422',
            reasons: const ['length'],
          ),
        ),
        AuthFailure.weakPassword,
      );
      expect(
        AuthExceptionMapper.map(
          const AuthApiException(
            'Password failed policy',
            code: 'weak_password',
            statusCode: '422',
          ),
        ),
        AuthFailure.weakPassword,
      );
    });

    test('maps GoTrue error codes and HTTP 429 rate limits', () {
      expect(
        AuthExceptionMapper.map(
          const AuthApiException(
            'Email not confirmed',
            code: 'email_not_confirmed',
            statusCode: '400',
          ),
        ),
        AuthFailure.emailNotConfirmed,
      );
      expect(
        AuthExceptionMapper.map(
          const AuthApiException(
            'Already exists',
            code: 'user_already_exists',
            statusCode: '422',
          ),
        ),
        AuthFailure.emailAlreadyInUse,
      );
      expect(
        AuthExceptionMapper.map(
          const AuthApiException(
            'Email exists',
            code: 'email_exists',
            statusCode: '422',
          ),
        ),
        AuthFailure.emailAlreadyInUse,
      );
      expect(
        AuthExceptionMapper.map(
          const AuthApiException(
            'Invalid',
            code: 'invalid_credentials',
            statusCode: '400',
          ),
        ),
        AuthFailure.invalidCredentials,
      );
      expect(
        AuthExceptionMapper.map(
          const AuthApiException(
            'Too many',
            code: 'over_request_rate_limit',
            statusCode: '429',
          ),
        ),
        AuthFailure.rateLimited,
      );
      expect(
        AuthExceptionMapper.map(
          const AuthException('Slow down', statusCode: '429'),
        ),
        AuthFailure.rateLimited,
      );
      expect(
        AuthExceptionMapper.map(
          const AuthApiException(
            'Signups disabled',
            code: 'signup_disabled',
            statusCode: '403',
          ),
        ),
        AuthFailure.unavailable,
      );
    });

    test('maps message fallbacks and unknown errors safely', () {
      expect(
        AuthExceptionMapper.map(const AuthException('Email not confirmed')),
        AuthFailure.emailNotConfirmed,
      );
      expect(
        AuthExceptionMapper.map(const AuthException('User already registered')),
        AuthFailure.emailAlreadyInUse,
      );
      expect(
        AuthExceptionMapper.map(
          const AuthException('Invalid login credentials'),
        ),
        AuthFailure.invalidCredentials,
      );
      expect(
        AuthExceptionMapper.map(
          const AuthException('Password should be at least 8 characters'),
        ),
        AuthFailure.weakPassword,
      );
      expect(
        AuthExceptionMapper.map(const AuthException('Too many requests')),
        AuthFailure.rateLimited,
      );
      expect(
        AuthExceptionMapper.map(StateError('unexpected')),
        AuthFailure.unknown,
      );
    });

    test('safeErrorCode extracts only code or statusCode, never message', () {
      expect(
        AuthExceptionMapper.safeErrorCode(
          const AuthApiException(
            'secret@email.com failed',
            code: 'invalid_credentials',
            statusCode: '400',
          ),
        ),
        'invalid_credentials',
      );
      expect(
        AuthExceptionMapper.safeErrorCode(
          const AuthException('raw message', statusCode: '429'),
        ),
        '429',
      );
      expect(AuthExceptionMapper.safeErrorCode(StateError('secret')), isNull);
    });
  });
}
