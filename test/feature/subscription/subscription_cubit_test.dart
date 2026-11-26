// Unit tests for SubscriptionCubit: offer loading, purchase outcomes, and
// guards against duplicate or unnecessary purchase requests.
import 'package:bloc_test/bloc_test.dart';
import 'package:chapter_no/feature/subscription/data/repo/in_memory_subscription_repository.dart';
import 'package:chapter_no/feature/subscription/domain/entities/subscription_offer.dart';
import 'package:chapter_no/feature/subscription/domain/repositories/subscription_repository.dart';
import 'package:chapter_no/feature/subscription/screens/cubits/subscription_cubit.dart';
import 'package:chapter_no/feature/subscription/screens/cubits/subscription_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

const _offer = InMemorySubscriptionRepository.defaultOffer;

void main() {
  late MockSubscriptionRepository repo;

  setUp(() {
    repo = MockSubscriptionRepository();
    when(() => repo.getOffer()).thenAnswer((_) async => const Right(_offer));
  });

  blocTest<SubscriptionCubit, SubscriptionState>(
    'load emits loading then the offer',
    build: () => SubscriptionCubit(repository: repo),
    act: (cubit) => cubit.load(),
    expect: () => const [
      SubscriptionLoading(),
      SubscriptionLoaded(offer: _offer),
    ],
  );

  blocTest<SubscriptionCubit, SubscriptionState>(
    'load emits error when the offer cannot be fetched',
    build: () {
      when(() => repo.getOffer()).thenAnswer((_) async => const Left('down'));
      return SubscriptionCubit(repository: repo);
    },
    act: (cubit) => cubit.load(),
    expect: () => const [
      SubscriptionLoading(),
      SubscriptionError(message: 'down'),
    ],
  );

  blocTest<SubscriptionCubit, SubscriptionState>(
    'failed purchase keeps Free and surfaces the message',
    build: () {
      when(
        () => repo.startPlusPurchase(),
      ).thenAnswer((_) async => const Left('unavailable'));
      return SubscriptionCubit(repository: repo);
    },
    seed: () => const SubscriptionLoaded(offer: _offer),
    act: (cubit) => cubit.startPurchase(),
    expect: () => const [
      SubscriptionLoaded(offer: _offer, isPurchasing: true),
      SubscriptionLoaded(offer: _offer, purchaseError: 'unavailable'),
    ],
  );

  blocTest<SubscriptionCubit, SubscriptionState>(
    'server-confirmed purchase switches the offer to Plus',
    build: () {
      when(
        () => repo.startPlusPurchase(),
      ).thenAnswer((_) async => const Right(PlanTier.plus));
      return SubscriptionCubit(repository: repo);
    },
    seed: () => const SubscriptionLoaded(offer: _offer),
    act: (cubit) => cubit.startPurchase(),
    expect: () => [
      const SubscriptionLoaded(offer: _offer, isPurchasing: true),
      SubscriptionLoaded(
        offer: _offer.copyWith(currentTier: PlanTier.plus),
        upgraded: true,
      ),
    ],
  );

  blocTest<SubscriptionCubit, SubscriptionState>(
    'ignores purchase taps while a request is in flight',
    build: () => SubscriptionCubit(repository: repo),
    seed: () => const SubscriptionLoaded(offer: _offer, isPurchasing: true),
    act: (cubit) => cubit.startPurchase(),
    expect: () => const <SubscriptionState>[],
    verify: (_) => verifyNever(() => repo.startPlusPurchase()),
  );

  blocTest<SubscriptionCubit, SubscriptionState>(
    'does not request a purchase when already on Plus',
    build: () => SubscriptionCubit(repository: repo),
    seed: () =>
        SubscriptionLoaded(offer: _offer.copyWith(currentTier: PlanTier.plus)),
    act: (cubit) => cubit.startPurchase(),
    expect: () => const <SubscriptionState>[],
    verify: (_) => verifyNever(() => repo.startPlusPurchase()),
  );

  test('in-memory repository never grants Plus on its own', () async {
    final result = await InMemorySubscriptionRepository().startPlusPurchase();
    expect(result.isLeft(), isTrue);
  });
}
