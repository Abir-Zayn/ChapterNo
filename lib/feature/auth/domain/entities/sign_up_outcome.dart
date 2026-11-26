// Outcome of creating a student account via AuthRepository.signUp.
// Distinguishes an immediate active session from pending email verification.
import 'package:equatable/equatable.dart';

import 'auth_user.dart';

class SignUpOutcome extends Equatable {
  const SignUpOutcome._({
    required this.isAuthenticated,
    required this.email,
    this.user,
  });

  factory SignUpOutcome.authenticated(AuthUser user) =>
      SignUpOutcome._(isAuthenticated: true, user: user, email: user.email);

  const SignUpOutcome.verificationRequired(this.email)
    : isAuthenticated = false,
      user = null;

  final bool isAuthenticated;
  final AuthUser? user;
  final String email;

  bool get requiresEmailVerification => !isAuthenticated;

  @override
  List<Object?> get props => [isAuthenticated, user, email];
}
