// Verifies AppCrashLogger never throws, logs sanitized metadata only,
// strips sensitive values, and bounds its in-memory diagnostic buffer.
import 'app_crash_logger_test_imports.dart';

void main() {
  group('AppCrashLogger', () {
    test('logs sanitized operation, stage, errorType, and code', () {
      final lines = <String>[];
      final logger = AppCrashLogger(debugSink: lines.add);

      logger.recordError(
        operation: 'auth.sign_in',
        stage: 'submit',
        error: StateError('secret_email=student@example.com jwt=eyJhbGciOi'),
        errorCode: 'invalid_credentials',
      );

      expect(lines, hasLength(1));
      final line = lines.single;
      expect(
        line,
        '[auth.sign_in] stage=submit errorType=StateError code=invalid_credentials',
      );
      expect(line, isNot(contains('student@example.com')));
      expect(line, isNot(contains('eyJhbGciOi')));
      expect(line, isNot(contains('secret_email')));
    });

    test('redacts email or JWT strings if passed in metadata fields', () {
      final lines = <String>[];
      final logger = AppCrashLogger(debugSink: lines.add);

      logger.recordError(
        operation: 'student@example.com',
        stage: 'eyJhbGciOiJIUzI1NiJ9.payload',
        errorCode: 'bearer@token',
      );

      expect(
        lines.single,
        '[<redacted>] stage=<redacted> errorType=none code=<redacted>',
      );
    });

    test(
      'redacts case-insensitive secret/token substrings anywhere in field',
      () {
        final lines = <String>[];
        final logger = AppCrashLogger(debugSink: lines.add);

        logger.recordError(
          operation: 'prefix_EYJtoken123',
          stage: 'key=SB_SECRET_abc',
          errorCode: 'role:Service_Role_admin',
        );
        logger.recordError(
          operation: 'auth',
          stage: 'header=BEARER secret-jwt',
          errorCode: 'bearer_missing',
        );

        expect(
          lines[0],
          '[<redacted>] stage=<redacted> errorType=none code=<redacted>',
        );
        expect(
          lines[1],
          '[auth] stage=<redacted> errorType=none code=bearer_missing',
        );
      },
    );

    test(
      'redacts non-space bearer delimiters, token fields, and publishable keys '
      'while keeping safe error codes unredacted',
      () {
        final lines = <String>[];
        final logger = AppCrashLogger(debugSink: lines.add);

        for (final value in const <String>[
          'Bearer\tsecret',
          'Bearer\nsecret',
          'Bearer:secret',
          'Bearer=secret',
          'refresh_token=rt_live',
          '"access_token":"at_live"',
          '{"apikey":"sb_publishable_dummy"}',
          'sb_publishable_dummy',
        ]) {
          logger.recordError(
            operation: 'auth',
            stage: value,
            errorCode: 'refresh_token_not_found',
          );
        }
        logger.recordError(
          operation: 'auth',
          stage: 'submit',
          errorCode: 'bearer_missing',
        );

        for (var i = 0; i < 8; i++) {
          expect(
            lines[i],
            '[auth] stage=<redacted> errorType=none code=refresh_token_not_found',
          );
        }
        expect(
          lines[8],
          '[auth] stage=submit errorType=none code=bearer_missing',
        );
      },
    );

    test(
      'never throws when debugSink fails during recordError or FlutterError',
      () {
        final logger = AppCrashLogger(
          debugSink: (_) => throw StateError('sink failure'),
        );

        expect(
          () => logger.recordError(
            operation: 'bootstrap',
            stage: 'env_validate',
            error: const FormatException('sensitive-payload'),
          ),
          returnsNormally,
        );

        expect(
          () => logger.recordFlutterError(
            FlutterErrorDetails(
              exception: ArgumentError('token=eyJabc123'),
              library: 'widgets library',
            ),
          ),
          returnsNormally,
        );

        expect(logger.recentEntries, hasLength(2));
        expect(logger.recentEntries.last.operation, 'flutter_framework');
        expect(logger.recentEntries.last.stage, 'widgets_library');
        expect(logger.recentEntries.last.errorType, 'ArgumentError');
      },
    );

    test('caps retained recentEntries to maxEntries', () {
      final logger = AppCrashLogger(debugSink: (_) {}, maxEntries: 3);

      for (var i = 0; i < 5; i++) {
        logger.recordError(operation: 'op_$i', stage: 'step_$i');
      }

      expect(logger.recentEntries.map((e) => e.operation), [
        'op_2',
        'op_3',
        'op_4',
      ]);

      logger.clear();
      expect(logger.recentEntries, isEmpty);
    });
  });
}
