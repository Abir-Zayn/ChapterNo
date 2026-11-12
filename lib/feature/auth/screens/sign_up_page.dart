// Create-account form: date of birth, email, and password.
// Validates input locally, renders SignUpCubit state, and reports outcomes
// through callbacks; entered text is kept when a request fails.
import 'auth_form_page_imports.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    super.key,
    required this.onSignedUp,
    required this.onLogIn,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
    this.today,
  });

  final VoidCallback onSignedUp;
  final VoidCallback onLogIn;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  /// Overrides the current date in tests.
  final DateTime? today;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final DateTime _today = widget.today ?? DateTime.now();
  DateTime? _dateOfBirth;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final dateOfBirth = _dateOfBirth;
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || dateOfBirth == null) return;
    context.read<SignUpCubit>().submit(
      email: _email.text,
      password: _password.text,
      dateOfBirth: dateOfBirth,
    );
  }

  void _onState(BuildContext context, AuthFormState state) {
    final failure = state.failure;
    if (state.status == AuthFormStatus.success) {
      widget.onSignedUp();
    } else if (failure != null) {
      AppSnackBar.show(context, failure.message, type: AppSnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpCubit, AuthFormState>(
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
                  const AuthHeader(title: 'Create account'),
                  const SizedBox(height: AppSpacing.xl),
                  DateOfBirthField(
                    value: _dateOfBirth,
                    today: _today,
                    enabled: !busy,
                    onChanged: (date) => setState(() => _dateOfBirth = date),
                    validator: (date) =>
                        AuthValidators.dateOfBirth(date, today: _today),
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
                    helperText:
                        'At least ${AuthValidators.minPasswordLength} '
                        'characters.',
                    prefixIcon: PhosphorIconsRegular.lockSimple,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: AuthValidators.newPassword,
                    onSubmitted: (_) => _submit(),
                    enabled: !busy,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  LegalConsentText(
                    onOpenTerms: widget.onOpenTerms,
                    onOpenPrivacy: widget.onOpenPrivacy,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Create account',
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
            prompt: 'Already have an account?',
            actionLabel: 'Log in',
            onAction: busy ? null : widget.onLogIn,
          ),
        );
      },
    );
  }
}
