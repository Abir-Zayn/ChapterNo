// Read-only date-of-birth input that opens the platform date picker.
// Reports the chosen date through a callback; validation rules are passed
// in by the page so this widget stays presentational and holds no state.
import 'auth_widgets_imports.dart';

class DateOfBirthField extends StatelessWidget {
  const DateOfBirthField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.today,
    this.validator,
    this.enabled = true,
  });

  static const int _defaultAge = 15;

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  /// Latest selectable date.
  final DateTime today;
  final String? Function(DateTime? value)? validator;
  final bool enabled;

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          value ?? DateTime(today.year - _defaultAge, today.month, today.day),
      firstDate: DateTime(1950),
      lastDate: today,
      helpText: 'Date of birth',
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final date = value;
    return AppTextField(
      // A new key rebuilds the field with the newly picked date as its text.
      key: ValueKey(date),
      initialValue: date == null
          ? null
          : MaterialLocalizations.of(context).formatMediumDate(date),
      label: 'Date of birth',
      hint: 'Select date',
      helperText: 'Used to confirm your age. Not shown on your profile.',
      prefixIcon: PhosphorIconsRegular.calendarBlank,
      readOnly: true,
      enabled: enabled,
      onTap: () => _pick(context),
      validator: (_) => validator?.call(date),
    );
  }
}
