// Verifies the local mock examination workflow and timer cleanup.
// Exercises the actual screen without services or arbitrary delays.
import 'package:chapter_no/feature/cq/screens/cq_flow_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('writing timer, submission, and read-only review work', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CqFlowPage()));
    await tester.tap(find.text('Start CQ exam'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('59:59'), findsOneWidget);
    await tester.tap(find.text('Finish writing & add sheets'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep writing'));
    await tester.pumpAndSettle();
    expect(find.text('Timed CQ examination'), findsOneWidget);
    await tester.tap(find.text('Finish writing & add sheets'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish session'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review 5 sample pages'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Move page earlier').first);
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Remove page').first);
    await tester.pump();
    expect(find.text('Sample page 1'), findsNothing);
    await tester.tap(find.text('Submit demo for evaluation'));
    await tester.pumpAndSettle();
    expect(find.text('Submission preview ready'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Advance demo progress'), 350);
    await tester.ensureVisible(find.text('Advance demo progress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Advance demo progress'));
    await tester.pumpAndSettle();
    expect(find.text('Demo evaluation complete'), findsOneWidget);
    await tester.ensureVisible(find.text('View submitted sample pages'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View submitted sample pages'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove page'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('exam supports narrow screen and enlarged text', (tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: const CqFlowPage(),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
