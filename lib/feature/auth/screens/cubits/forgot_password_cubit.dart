// Requests a password-reset email and exposes the request's progress.
// Ignores repeat taps while a request is running and never emits after close.
import 'auth_form_state.dart';
import 'cubits_imports.dart';

class ForgotPasswordCubit extends Cubit<AuthFormState> {
  ForgotPasswordCubit({required this._authRepository})
    : super(const AuthFormState());

  final AuthRepository _authRepository;

  Future<void> submit({required String email}) async {
    if (state.isSubmitting) return;
    emit(const AuthFormState.submitting());
    final result = await _authRepository.sendPasswordReset(email: email.trim());
    if (isClosed) return;
    emit(
      result.fold(AuthFormState.failed, (_) => const AuthFormState.success()),
    );
  }

  /// Returns to the form so the student can try another address.
  void reset() => emit(const AuthFormState());
}
