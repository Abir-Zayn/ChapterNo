// SSC batch year choice chips for the Onboarding form.
// Renders the configurable OnboardingDraft.batchYears as a Wrap of chips.
import 'widgets_imports.dart';

class BatchYearChips extends StatelessWidget {
  const BatchYearChips({
    super.key,
    required this.selectedYear,
    required this.onSelected,
  });

  final int? selectedYear;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final year in OnboardingDraft.batchYears)
          ChoiceChip(
            label: Text('SSC $year'),
            selected: year == selectedYear,
            onSelected: (_) => onSelected(year),
          ),
      ],
    );
  }
}
