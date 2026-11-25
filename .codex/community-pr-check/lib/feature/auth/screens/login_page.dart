// Email and password login form for returning students.
// Validates input locally, renders LoginCubit state, and reports outcomes
// through callbacks; entered text is kept when a request fails.
import 'auth_form_page_imports.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onLoggedIn,
    required this.onForgotPassword,
    required this.onSignUp,
  });

  final VoidCallback onLoggedIn;
  final VoidCallback onForgotPassword;
  final VoidCallback onSignUp;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<LoginCubit>().submit(
      email: _email.text,
      password: _password.text,
    );
  }

  void _onState(BuildContext context, AuthFormState state) {
    final failure = state.failure;
    if (state.status == AuthFormStatus.success) {
      widget.onLoggedIn();
    } else if (failure != null) {
      AppSnackBar.show(context, failure.message, type: AppSnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, AuthFormState>(
      listener: _onState,
      builder: (context, state) {
        final busy = state.isSubmitting;
        return AuthScaffold(
          showBack: true,
          body: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AuthHeader(
                    title: 'Welcome back',
                    subtitle: 'Log in to continue your study plan.',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    controller: _email,
                    label: 'Email',
                    hint: 'you@example.com',
                    prefixIcon: PhosphorIconsRegular.envelopeSimple,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: AuthValidators.email,
                    enabled: !busy,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppPasswordField(
                    controller: _password,
                    label: 'Password',
                    prefixIcon: PhosphorIconsRegular.lockSimple,
                    textInputAction: TextInputAction.done,
                    validator: AuthValidators.existingPassword,
                    onSubmitted: (_) => _submit(),
                    enabled: !busy,
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: AppButton(
                      label: 'Forgot password?',
                      variant: AppButtonVariant.text,
                      onPressed: busy ? null : widget.onForgotPassword,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'Log in',
                    size: AppButtonSize.large,
                    expand: true,
                    isLoading: busy,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
          footer: AuthSwitchPrompt(
            prompt: 'New to ChapterNo?',
            actionLabel: 'Sign up',
            onAction: busy ? null : widget.onSignUp,
          ),
        );
      },
    );
  }
}
