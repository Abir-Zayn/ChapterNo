// Immutable states for the Plus subscription screen: loading the offer,
// showing it, an in-flight purchase request, and its outcome.
import 'cubits_imports.dart';

sealed class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

final class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

final class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

final class SubscriptionLoaded extends SubscriptionState {
  const SubscriptionLoaded({
    required this.offer,
    this.isPurchasing = false,
    this.purchaseError,
    this.upgraded = false,
  });

  final SubscriptionOffer offer;
  final bool isPurchasing;

  /// Message from the last failed purchase request, shown once as feedback.
  final String? purchaseError;

  /// True once the server confirmed Plus during this visit.
  final bool upgraded;

  @override
  List<Object?> get props => [offer, isPurchasing, purchaseError, upgraded];
}

final class SubscriptionError extends SubscriptionState {
  const SubscriptionError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
