// Inline notice box pairing an icon with text on a soft solid background.
// Used for draft labels and confirmations; never relies on colour alone.
import 'auth_widgets_imports.dart';

enum AuthNoticeTone { info, success }

class AuthNotice extends StatelessWidget {
  const AuthNotice({
    super.key,
    required this.message,
    this.tone = AuthNoticeTone.info,
  });

  final String message;
  final AuthNoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final (icon, color, background) = switch (tone) {
      AuthNoticeTone.info => (
        PhosphorIconsRegular.info,
        AppColors.info,
        AppColors.infoSoft,
      ),
      AuthNoticeTone.success => (
        PhosphorIconsRegular.checkCircle,
        AppColors.success,
        AppColors.successSoft,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: AppSizes.iconMd, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppText(
                message,
                color: AppColors.textPrimary,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
