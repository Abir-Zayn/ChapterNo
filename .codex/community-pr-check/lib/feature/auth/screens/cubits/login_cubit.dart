// Handles the login form submission and exposes its progress.
// Ignores repeat taps while a request is running and never emits after close.
import 'auth_form_state.dart';
import 'cubits_imports.dart';

class LoginCubit extends Cubit<AuthFormState> {
  LoginCubit({required this._authRepository}) : super(const AuthFormState());

  final AuthRepository _authRepository;

  Future<void> submit({required String email, required String password}) async {
    if (state.isSubmitting) return;
    emit(const AuthFormState.submitting());
    final result = await _authRepository.signIn(
      email: email.trim(),
      password: password,
    );
    if (isClosed) return;
    emit(
      result.fold(AuthFormState.failed, (_) => const AuthFormState.success()),
    );
  }
}
