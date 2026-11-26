// Academic group selection cards for the Onboarding form.
// Solid surfaces with a highlighted border when selected; no blur effects.
import 'widgets_imports.dart';

class AcademicGroupSelector extends StatelessWidget {
  const AcademicGroupSelector({
    super.key,
    required this.selectedGroup,
    required this.onSelected,
  });

  final String? selectedGroup;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final option in OnboardingDraft.academicGroupOptions) ...[
          AppCard(
            onTap: () => onSelected(option.value),
            color: option.value == selectedGroup ? context.primarySoft : null,
            borderColor: option.value == selectedGroup ? context.primary : null,
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    option.label,
                    fontWeight: option.value == selectedGroup
                        ? FontWeight.w700
                        : FontWeight.w600,
                  ),
                ),
                if (option.value == selectedGroup)
                  Icon(PhosphorIconsRegular.check, color: context.primary),
              ],
            ),
          ),
          if (option != OnboardingDraft.academicGroupOptions.last)
            const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
