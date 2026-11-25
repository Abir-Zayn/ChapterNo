// Full-area message for empty, error, and offline states with an action.
// Pairs an icon with text so status never relies on colour alone;
// scrollable so large text scaling on narrow screens does not overflow.
import 'app_state_view_imports.dart';

class AppStateView extends StatelessWidget {
  const AppStateView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  /// Error state with a retry button.
  const AppStateView.error({
    super.key,
    required this.title,
    this.message,
    this.actionLabel = 'Try again',
    this.onAction,
  }) : icon = Icons.error_outline,
       iconColor = null;

  /// Offline state with a retry button.
  const AppStateView.offline({
    super.key,
    required this.title,
    this.message,
    this.actionLabel = 'Try again',
    this.onAction,
  }) : icon = Icons.wifi_off_outlined,
       iconColor = null;

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final body = message;
    final action = actionLabel;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: iconColor ?? scheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.lg),
            AppText.title(title, textAlign: TextAlign.center),
            if (body != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppText.caption(body, textAlign: TextAlign.center),
            ],
            if (action != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: action,
                onPressed: onAction,
                variant: AppButtonVariant.outline,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
