// Input rules for auth forms: email shape, password length, birth date.
// Pure Dart so the same rules run in Cubits, widgets, and tests.
// Each validator returns null when valid, or a learner-facing message.

abstract final class AuthValidators {
  static const int minPasswordLength = 8;

  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter your email address.';
    if (!_email.hasMatch(text)) return 'Enter a valid email address.';
    return null;
  }

  /// Sign-in only checks presence so older passwords still work.
  static String? existingPassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password.';
    return null;
  }

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Create a password.';
    if (value.length < minPasswordLength) {
      return 'Use at least $minPasswordLength characters.';
    }
    return null;
  }

  static String? dateOfBirth(DateTime? value, {required DateTime today}) {
    if (value == null) return 'Select your date of birth.';
    if (value.isAfter(today)) return 'Date of birth cannot be in the future.';
    return null;
  }
}
