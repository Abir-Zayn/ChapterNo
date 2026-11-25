// Widget tests for the Plus subscription page: offer rendering, honest
// pricing copy, purchase feedback, dismissal, and narrow-layout resilience.
import 'package:chapter_no/feature/subscription/data/repo/in_memory_subscription_repository.dart';
import 'package:chapter_no/feature/subscription/domain/entities/subscription_offer.dart';
import 'package:chapter_no/feature/subscription/screens/cubits/subscription_cubit.dart';
import 'package:chapter_no/feature/subscription/screens/subscription_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_page.dart';

const _offer = InMemorySubscriptionRepository.defaultOffer;

Future<void> _pump(
  WidgetTester tester, {
  SubscriptionOffer offer = _offer,
  VoidCallback? onClose,
  VoidCallback? onOpenTerms,
  Size size = const Size(400, 800),
  double textScale = 1,
}) async {
  await tester.pumpPage(
    BlocProvider(
      create: (_) => SubscriptionCubit(
        repository: InMemorySubscriptionRepository(offer: offer),
      )..load(),
      child: SubscriptionPage(
        onClose: onClose ?? () {},
        onOpenTerms: onOpenTerms ?? () {},
      ),
    ),
    size: size,
    textScale: textScale,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the Plus offer with honest pricing copy', (tester) async {
    await _pump(tester);

    expect(find.text(_offer.headline), findsOneWidget);
    expect(find.text('Larger AI explanation allowance*'), findsOneWidget);
    expect(find.textContaining('not unlimited'), findsOneWidget);
    expect(find.text('Pricing will be announced soon.'), findsOneWidget);
    expect(find.text('Get ChapterNo Plus'), findsOneWidget);
  });

  testWidgets('shows the configured price when one is provided', (
    tester,
  ) async {
    const priced = SubscriptionOffer(
      currentTier: PlanTier.free,
      headline: 'Headline',
      summary: 'Summary',
      benefits: [],
      priceLabel: 'BDT 100',
      billingNote: 'per month',
    );
    await _pump(tester, offer: priced);

    expect(find.text('BDT 100 · per month'), findsOneWidget);
  });

  testWidgets('purchase reports unavailability and keeps Free', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Get ChapterNo Plus'));
    await tester.pumpAndSettle();

    expect(
      find.text(InMemorySubscriptionRepository.purchaseUnavailableMessage),
      findsOneWidget,
    );
    expect(find.text('Get ChapterNo Plus'), findsOneWidget);
  });

  testWidgets('Not now, Close and Terms invoke their callbacks', (
    tester,
  ) async {
    var closes = 0;
    var terms = 0;
    await _pump(tester, onClose: () => closes++, onOpenTerms: () => terms++);

    await tester.tap(find.text('Not now'));
    await tester.tap(find.byTooltip('Close'));
    await tester.ensureVisible(find.text('Terms and conditions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terms and conditions'));

    expect(closes, 2);
    expect(terms, 1);
  });

  testWidgets('Plus members see their active plan and no purchase action', (
    tester,
  ) async {
    await _pump(tester, offer: _offer.copyWith(currentTier: PlanTier.plus));

    expect(find.text("You're on ChapterNo Plus"), findsOneWidget);
    expect(find.text('Your Plus plan is active.'), findsOneWidget);
    expect(find.text('Get ChapterNo Plus'), findsNothing);
  });

  testWidgets('renders without overflow at 320dp and 1.5x text', (
    tester,
  ) async {
    await _pump(tester, size: const Size(320, 640), textScale: 1.5);

    expect(tester.takeException(), isNull);
    expect(find.text('Get ChapterNo Plus'), findsOneWidget);
  });
}
