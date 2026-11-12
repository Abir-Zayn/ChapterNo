// Submission state shared by the login, sign-up, and forgot-password forms.
// Immutable with value equality; field text stays in the form widgets so
// entered work survives recoverable errors.
import 'cubits_imports.dart';

enum AuthFormStatus { idle, submitting, success, failure }

class AuthFormState extends Equatable {
  const AuthFormState({this.status = AuthFormStatus.idle, this.failure});

  const AuthFormState.submitting()
    : status = AuthFormStatus.submitting,
      failure = null;

  const AuthFormState.success()
    : status = AuthFormStatus.success,
      failure = null;

  const AuthFormState.failed(AuthFailure this.failure)
    : status = AuthFormStatus.failure;

  final AuthFormStatus status;

  /// Set only when [status] is [AuthFormStatus.failure].
  final AuthFailure? failure;

  bool get isSubmitting => status == AuthFormStatus.submitting;

  @override
  List<Object?> get props => [status, failure];
}
