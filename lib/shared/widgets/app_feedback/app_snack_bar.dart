// Shows short, consistent feedback messages (info/success/error/warning).
// Each type has its own icon so meaning does not depend on colour alone;
// replaces any visible snackbar so messages do not queue up.
import 'app_feedback_imports.dart';

enum AppSnackBarType { info, success, warning, error }

abstract final class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final (icon, color) = switch (type) {
      AppSnackBarType.info => (Icons.info_outline, AppColors.info),
      AppSnackBarType.success => (
        Icons.check_circle_outline,
        AppColors.success,
      ),
      AppSnackBarType.warning => (
        Icons.warning_amber_outlined,
        AppColors.warning,
      ),
      AppSnackBarType.error => (Icons.error_outline, AppColors.error),
    };
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: color,
        duration: duration,
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: AppSizes.iconMd),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: AppText(message, color: Colors.white)),
          ],
        ),
        action: actionLabel == null || onAction == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              ),
      ),
    );
  }
}
