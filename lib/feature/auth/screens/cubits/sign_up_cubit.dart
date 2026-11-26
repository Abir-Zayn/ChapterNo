// Handles the create-account form submission and exposes its progress.
// Ignores repeat taps while a request is running, distinguishes active
// sessions from email-verification outcomes, and never emits after close.
import 'auth_form_state.dart';
import 'cubits_imports.dart';

class SignUpCubit extends Cubit<AuthFormState> {
  SignUpCubit({required this._authRepository}) : super(const AuthFormState());

  final AuthRepository _authRepository;

  Future<void> submit({
    required String email,
    required String password,
    required DateTime dateOfBirth,
  }) async {
    if (state.isSubmitting) return;
    emit(const AuthFormState.submitting());
    final result = await _authRepository.signUp(
      email: email.trim(),
      password: password,
      dateOfBirth: dateOfBirth,
    );
    if (isClosed) return;
    emit(
      result.fold(
        AuthFormState.failed,
        (outcome) => outcome.requiresEmailVerification
            ? AuthFormState.verificationRequired(outcome.email)
            : const AuthFormState.success(),
      ),
    );
  }

  /// Returns to the form so the student can try another email address.
  void reset() => emit(const AuthFormState());
}
