// Screen title with optional supporting copy for auth forms.
// Marks the title as a header for screen readers.
import 'auth_widgets_imports.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final supporting = subtitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: AppText(
            title,
            variant: AppTextVariant.display,
            style: const TextStyle(fontSize: 28),
          ),
        ),
        if (supporting != null) ...[
          const SizedBox(height: AppSpacing.sm),
          AppText(supporting, color: AppColors.textSecondary),
        ],
      ],
    );
  }
}
