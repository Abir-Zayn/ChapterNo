// Pinned bottom bar of the Plus screen: price line, primary upgrade action,
// and a quiet "Not now" dismissal. Shows honest copy while pricing is unset.
import 'widgets_imports.dart';

class PlusCheckoutBar extends StatelessWidget {
  const PlusCheckoutBar({
    super.key,
    required this.priceLabel,
    required this.billingNote,
    required this.isOnPlus,
    required this.isPurchasing,
    required this.onPurchase,
    required this.onDismiss,
  });

  final String? priceLabel;
  final String? billingNote;
  final bool isOnPlus;
  final bool isPurchasing;
  final VoidCallback onPurchase;
  final VoidCallback onDismiss;

  String get _priceLine {
    if (isOnPlus) return 'Your Plus plan is active.';
    final price = priceLabel;
    if (price == null) return 'Pricing will be announced soon.';
    final note = billingNote;
    return note == null ? price : '$price · $note';
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.md,
            AppSpacing.gutter,
            AppSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.caption(
                _priceLine,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: isOnPlus ? 'Current plan' : 'Get ChapterNo Plus',
                icon: isOnPlus ? PhosphorIconsRegular.sealCheck : null,
                size: AppButtonSize.large,
                expand: true,
                isLoading: isPurchasing,
                onPressed: isOnPlus ? null : onPurchase,
              ),
              AppButton(
                label: isOnPlus ? 'Close' : 'Not now',
                variant: AppButtonVariant.text,
                expand: true,
                onPressed: isPurchasing ? null : onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
