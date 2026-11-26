// Submission state shared by the login, sign-up, and forgot-password forms.
// Immutable with value equality; field text stays in the form widgets so
// entered work survives recoverable errors.
import 'cubits_imports.dart';

enum AuthFormStatus { idle, submitting, success, verificationRequired, failure }

class AuthFormState extends Equatable {
  const AuthFormState({
    this.status = AuthFormStatus.idle,
    this.failure,
    this.verificationEmail,
  });

  const AuthFormState.submitting()
    : status = AuthFormStatus.submitting,
      failure = null,
      verificationEmail = null;

  const AuthFormState.success()
    : status = AuthFormStatus.success,
      failure = null,
      verificationEmail = null;

  const AuthFormState.verificationRequired(String email)
    : status = AuthFormStatus.verificationRequired,
      failure = null,
      verificationEmail = email;

  const AuthFormState.failed(AuthFailure this.failure)
    : status = AuthFormStatus.failure,
      verificationEmail = null;

  final AuthFormStatus status;

  /// Set only when [status] is [AuthFormStatus.failure].
  final AuthFailure? failure;

  /// Set only when [status] is [AuthFormStatus.verificationRequired].
  final String? verificationEmail;

  bool get isSubmitting => status == AuthFormStatus.submitting;

  bool get requiresVerification =>
      status == AuthFormStatus.verificationRequired;

  @override
  List<Object?> get props => [status, failure, verificationEmail];
}
