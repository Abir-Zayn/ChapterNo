// In-memory SubscriptionRepository used until the purchase provider is chosen.
// Price stays unset because pricing is unresolved, and purchases honestly
// report that they are unavailable instead of faking an upgrade.
import 'repo_imports.dart';

class InMemorySubscriptionRepository implements SubscriptionRepository {
  InMemorySubscriptionRepository({SubscriptionOffer? offer})
    : _offer = offer ?? defaultOffer;

  final SubscriptionOffer _offer;

  static const String purchaseUnavailableMessage =
      'Plus purchases are not available yet. Your Free plan stays active.';

  static const SubscriptionOffer defaultOffer = SubscriptionOffer(
    currentTier: PlanTier.free,
    headline: 'Go further with every chapter',
    summary:
        'Get broader practice access and larger AI allowances for your SSC '
        'preparation. Your Free plan keeps working either way.',
    benefits: [
      PlusBenefit(
        kind: PlusBenefitKind.practice,
        title: 'More topic and board practice',
      ),
      PlusBenefit(
        kind: PlusBenefitKind.aiSupport,
        title: 'Larger AI explanation allowance*',
      ),
      PlusBenefit(
        kind: PlusBenefitKind.feedback,
        title: 'Step-by-step CQ answer feedback*',
      ),
      PlusBenefit(
        kind: PlusBenefitKind.revision,
        title: 'Mistake Notebook re-practice',
      ),
      PlusBenefit(
        kind: PlusBenefitKind.analytics,
        title: 'Detailed learning analytics',
      ),
    ],
    footnotes: [
      '*AI features use fair-use allowances. They are not unlimited.',
      'Teacher question banks are sold separately.',
    ],
  );

  @override
  Future<Either<String, SubscriptionOffer>> getOffer() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return Right(_offer);
  }

  @override
  Future<Either<String, PlanTier>> startPlusPurchase() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return const Left(purchaseUnavailableMessage);
  }
}
