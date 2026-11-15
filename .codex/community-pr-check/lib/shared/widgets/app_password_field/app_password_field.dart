// Password input built on AppTextField with a show/hide visibility toggle.
// Only the obscured flag is local state; suggestions and autocorrect are off.
// Toggle labels are parameters so screens can pass localized Bangla text.
import 'app_password_field_imports.dart';

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.validator,
    this.autovalidateMode,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.enabled = true,
    this.autofocus = false,
    this.autofillHints = const [AutofillHints.password],
    this.prefixIcon = Icons.lock_outline,
    this.showLabel = 'Show password',
    this.hideLabel = 'Hide password',
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool autofocus;
  final Iterable<String>? autofillHints;
  final IconData? prefixIcon;
  final String showLabel;
  final String hideLabel;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscured = true;

  void _toggle() => setState(() => _obscured = !_obscured);

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      label: widget.label,
      hint: widget.hint,
      helperText: widget.helperText,
      errorText: widget.errorText,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      autofillHints: widget.autofillHints,
      prefixIcon: widget.prefixIcon,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscured,
      suffix: IconButton(
        onPressed: widget.enabled ? _toggle : null,
        tooltip: _obscured ? widget.showLabel : widget.hideLabel,
        icon: Icon(
          _obscured ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash,
        ),
      ),
    );
  }
}
