// The Plus offer shown to a student: their current plan, the copy and
// benefits of Plus, and the configured price (null until pricing is final).
import 'entities_imports.dart';

/// Baseline plan names from the project guide; do not add tiers here.
enum PlanTier { free, plus }

class SubscriptionOffer extends Equatable {
  const SubscriptionOffer({
    required this.currentTier,
    required this.headline,
    required this.summary,
    required this.benefits,
    this.footnotes = const [],
    this.priceLabel,
    this.billingNote,
  });

  final PlanTier currentTier;
  final String headline;
  final String summary;
  final List<PlusBenefit> benefits;

  /// Fine print such as fair-use and separately sold content notes.
  final List<String> footnotes;

  /// Display price from server configuration; null while not yet announced.
  final String? priceLabel;
  final String? billingNote;

  bool get isOnPlus => currentTier == PlanTier.plus;

  bool get hasPrice => priceLabel != null;

  SubscriptionOffer copyWith({PlanTier? currentTier}) => SubscriptionOffer(
    currentTier: currentTier ?? this.currentTier,
    headline: headline,
    summary: summary,
    benefits: benefits,
    footnotes: footnotes,
    priceLabel: priceLabel,
    billingNote: billingNote,
  );

  @override
  List<Object?> get props => [
    currentTier,
    headline,
    summary,
    benefits,
    footnotes,
    priceLabel,
    billingNote,
  ];
}
