// Verifies the auth form input rules: email, passwords, and date of birth.
import 'package:chapter_no/feature/auth/domain/usecase/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('email', () {
    test('accepts a normal address, ignoring surrounding spaces', () {
      expect(AuthValidators.email(' student@example.com '), isNull);
    });

    test('rejects empty and malformed addresses', () {
      expect(AuthValidators.email(null), isNotNull);
      expect(AuthValidators.email('   '), isNotNull);
      expect(AuthValidators.email('student'), isNotNull);
      expect(AuthValidators.email('student@example'), isNotNull);
      expect(AuthValidators.email('stu dent@example.com'), isNotNull);
    });
  });

  group('passwords', () {
    test('existing password only needs to be present', () {
      expect(AuthValidators.existingPassword('abc'), isNull);
      expect(AuthValidators.existingPassword(''), isNotNull);
    });

    test('new password needs the minimum length', () {
      expect(AuthValidators.newPassword('1234567'), isNotNull);
      expect(AuthValidators.newPassword('12345678'), isNull);
      expect(AuthValidators.newPassword(null), isNotNull);
    });
  });

  group('dateOfBirth', () {
    final today = DateTime(2026, 11, 12);

    test('requires a date', () {
      expect(AuthValidators.dateOfBirth(null, today: today), isNotNull);
    });

    test('rejects a future date and accepts today or earlier', () {
      expect(
        AuthValidators.dateOfBirth(DateTime(2026, 11, 13), today: today),
        isNotNull,
      );
      expect(AuthValidators.dateOfBirth(today, today: today), isNull);
      expect(
        AuthValidators.dateOfBirth(DateTime(2010, 5, 1), today: today),
        isNull,
      );
    });
  });
}
