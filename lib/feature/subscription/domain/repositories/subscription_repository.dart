// Contract for reading the Plus offer and requesting a Plus purchase.
// Entitlements are granted by trusted server infrastructure, never the client.
import 'repositories_imports.dart';

abstract interface class SubscriptionRepository {
  /// Loads the student's current plan and the Plus offer to display.
  Future<Either<String, SubscriptionOffer>> getOffer();

  /// Starts the Plus purchase flow; returns the server-confirmed plan tier.
  Future<Either<String, PlanTier>> startPlusPurchase();
}
