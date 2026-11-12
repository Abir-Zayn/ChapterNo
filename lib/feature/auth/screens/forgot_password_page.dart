// Password-reset request screen: email form, then a confirmation view.
// Validates input locally and renders ForgotPasswordCubit state; the
// entered email is kept when a request fails.
import 'auth_form_page_imports.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, required this.onBackToLogin});

  final VoidCallback onBackToLogin;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ForgotPasswordCubit>().submit(email: _email.text);
  }

  void _onState(BuildContext context, AuthFormState state) {
    final failure = state.failure;
    if (failure != null) {
      AppSnackBar.show(context, failure.message, type: AppSnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, AuthFormState>(
      listener: _onState,
      builder: (context, state) {
        final busy = state.isSubmitting;
        if (state.status == AuthFormStatus.success) {
          return AuthScaffold(
            showBack: true,
            body: ResetLinkSentView(
              email: _email.text.trim(),
              onBackToLogin: widget.onBackToLogin,
              onUseDifferentEmail: context.read<ForgotPasswordCubit>().reset,
            ),
          );
        }
        return AuthScaffold(
          showBack: true,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AuthHeader(
                  title: 'Forgot password?',
                  subtitle:
                      'Enter the email you signed up with. We will send '
                      'you a link to set a new password.',
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  controller: _email,
                  label: 'Email',
                  hint: 'you@example.com',
                  prefixIcon: PhosphorIconsRegular.envelopeSimple,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  validator: AuthValidators.email,
                  onSubmitted: (_) => _submit(),
                  enabled: !busy,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Send reset link',
                  size: AppButtonSize.large,
                  expand: true,
                  isLoading: busy,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
