// Maps auth failures to short, learner-facing messages with a next step.
// Keeps wording in one place so every auth screen explains errors alike.
import 'auth_widgets_imports.dart';

extension AuthFailureMessage on AuthFailure {
  String get message => switch (this) {
    AuthFailure.invalidCredentials =>
      'Email or password is incorrect. Check them and try again.',
    AuthFailure.emailAlreadyInUse =>
      'An account with this email already exists. Log in instead.',
    AuthFailure.network =>
      'No internet connection. Check your connection and try again.',
    AuthFailure.unavailable =>
      'This is not available yet. Please try again later.',
    AuthFailure.unknown => 'Something went wrong. Please try again.',
  };
}
