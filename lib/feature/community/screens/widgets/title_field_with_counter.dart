// Post title field with a live character counter above it. The parent owns
// the controller; this widget only observes it and disposes its listener.
import 'community_widgets_imports.dart';

class TitleFieldWithCounter extends StatelessWidget {
  const TitleFieldWithCounter({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.required = true,
    this.enabled = true,
    this.autovalidateMode,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool required;
  final bool enabled;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppText.label(label),
                const SizedBox(width: AppSpacing.xs),
                AppText.caption(
                  required ? '(required)' : '(optional)',
                  color: AppColors.textSecondary,
                ),

                AppText.caption(
                  '${value.text.characters.length}/'
                  '${PostDraftValidator.titleMaxLength}',
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              controller: controller,
              hint: hint,
              enabled: enabled,
              validator: PostDraftValidator.titleFieldError,
              autovalidateMode: autovalidateMode,
              textInputAction: TextInputAction.next,
            ),
          ],
        );
      },
    );
  }
}
