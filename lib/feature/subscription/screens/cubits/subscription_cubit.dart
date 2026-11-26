// Loads the Plus offer and forwards purchase requests to the repository.
// Ignores duplicate taps while a request is in flight; the server decides
// the resulting plan, so the client never grants Plus on its own.
import 'cubits_imports.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({required this._repository})
    : super(const SubscriptionInitial());

  final SubscriptionRepository _repository;

  Future<void> load() async {
    emit(const SubscriptionLoading());
    final result = await _repository.getOffer();
    if (isClosed) return;
    result.fold(
      (message) => emit(SubscriptionError(message: message)),
      (offer) => emit(SubscriptionLoaded(offer: offer)),
    );
  }

  Future<void> startPurchase() async {
    final current = state;
    if (current is! SubscriptionLoaded ||
        current.isPurchasing ||
        current.offer.isOnPlus) {
      return;
    }
    emit(SubscriptionLoaded(offer: current.offer, isPurchasing: true));
    final result = await _repository.startPlusPurchase();
    if (isClosed) return;
    result.fold(
      (message) => emit(
        SubscriptionLoaded(offer: current.offer, purchaseError: message),
      ),
      (tier) => emit(
        SubscriptionLoaded(
          offer: current.offer.copyWith(currentTier: tier),
          upgraded: tier == PlanTier.plus,
        ),
      ),
    );
  }
}
