// Maps auth failures to short, learner-facing messages with a next step.
// Keeps wording in one place so every auth screen explains errors alike.
import 'auth_widgets_imports.dart';

extension AuthFailureMessage on AuthFailure {
  String get message => switch (this) {
    AuthFailure.invalidCredentials =>
      'Email or password is incorrect. Check them and try again.',
    AuthFailure.emailAlreadyInUse =>
      'An account with this email already exists. Log in instead.',
    AuthFailure.emailNotConfirmed =>
      'Confirm your email address first. Check your inbox for the '
          'verification link.',
    AuthFailure.rateLimited =>
      'Too many attempts right now. Please wait a moment and try again.',
    AuthFailure.weakPassword =>
      'Choose a stronger password with at least 8 characters.',
    AuthFailure.network =>
      'No internet connection. Check your connection and try again.',
    AuthFailure.unavailable =>
      'This is not available yet. Please try again later.',
    AuthFailure.unknown => 'Something went wrong. Please try again.',
  };
}
