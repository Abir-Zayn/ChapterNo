// Displays the ChapterNo Plus upgrade screen (Quizlet-inspired layout):
// ink hero, benefit checklist, fine print, and a pinned checkout bar.
// Renders SubscriptionCubit state; purchase feedback arrives via a listener.
import 'subscription_page_imports.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({
    super.key,
    required this.onClose,
    required this.onOpenTerms,
  });

  final VoidCallback onClose;
  final VoidCallback onOpenTerms;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
          listenWhen: (previous, current) =>
              previous is SubscriptionLoaded &&
              previous.isPurchasing &&
              current is SubscriptionLoaded &&
              !current.isPurchasing,
          listener: _onPurchaseFinished,
          builder: (context, state) => switch (state) {
            SubscriptionInitial() || SubscriptionLoading() => _StatusFrame(
              onClose: onClose,
              child: const AppLoader(),
            ),
            SubscriptionError(:final message) => _StatusFrame(
              onClose: onClose,
              child: AppStateView.error(
                title: 'Could not load Plus details',
                message: message,
                onAction: () => context.read<SubscriptionCubit>().load(),
              ),
            ),
            SubscriptionLoaded(:final offer, :final isPurchasing) => _OfferView(
              offer: offer,
              isPurchasing: isPurchasing,
              onClose: onClose,
              onOpenTerms: onOpenTerms,
            ),
          },
        ),
      ),
    );
  }

  void _onPurchaseFinished(BuildContext context, SubscriptionState state) {
    if (state is! SubscriptionLoaded) return;
    final error = state.purchaseError;
    if (error != null) {
      AppSnackBar.show(context, error, type: AppSnackBarType.warning);
    } else if (state.upgraded) {
      AppSnackBar.show(
        context,
        'Welcome to ChapterNo Plus!',
        type: AppSnackBarType.success,
      );
    }
  }
}

class _OfferView extends StatelessWidget {
  const _OfferView({
    required this.offer,
    required this.isPurchasing,
    required this.onClose,
    required this.onOpenTerms,
  });

  final SubscriptionOffer offer;
  final bool isPurchasing;
  final VoidCallback onClose;
  final VoidCallback onOpenTerms;

  @override
  Widget build(BuildContext context) {
    final gutter = MediaQuery.sizeOf(context).width < AppSizes.narrowBreakpoint
        ? AppSpacing.lg
        : AppSpacing.gutter;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                children: [
                  PlusHeroHeader(
                    headline: offer.headline,
                    summary: offer.summary,
                    isOnPlus: offer.isOnPlus,
                    onClose: onClose,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      AppSpacing.xl,
                      gutter,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PlusBenefitList(benefits: offer.benefits),
                        const SizedBox(height: AppSpacing.lg),
                        PlusFinePrint(
                          footnotes: offer.footnotes,
                          onOpenTerms: onOpenTerms,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PlusCheckoutBar(
              priceLabel: offer.priceLabel,
              billingNote: offer.billingNote,
              isOnPlus: offer.isOnPlus,
              isPurchasing: isPurchasing,
              onPurchase: () =>
                  context.read<SubscriptionCubit>().startPurchase(),
              onDismiss: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusFrame extends StatelessWidget {
  const _StatusFrame({required this.onClose, required this.child});

  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onClose,
                tooltip: 'Close',
                icon: const Icon(PhosphorIconsRegular.x),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
