// Widget tests for AppStateView, AppLoader, AppCard, snackbar, and dialog.
// Covers retry actions, card taps, feedback display, and dialog results.
import 'package:chapter_no/shared/widgets/app_button/app_button.dart';
import 'package:chapter_no/shared/widgets/app_card/app_card.dart';
import 'package:chapter_no/shared/widgets/app_feedback/app_confirm_dialog.dart';
import 'package:chapter_no/shared/widgets/app_feedback/app_snack_bar.dart';
import 'package:chapter_no/shared/widgets/app_loader/app_loader.dart';
import 'package:chapter_no/shared/widgets/app_state_view/app_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('AppStateView.error shows message and triggers retry', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpApp(
      AppStateView.error(
        title: 'Could not load',
        message: 'Check your connection.',
        onAction: () => retries++,
      ),
    );

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('AppStateView hides action without a callback', (tester) async {
    await tester.pumpApp(
      const AppStateView(icon: Icons.inbox_outlined, title: 'Nothing yet'),
    );
    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('AppLoader shows spinner and message', (tester) async {
    await tester.pumpApp(const AppLoader(message: 'Loading…'));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading…'), findsOneWidget);
  });

  testWidgets('AppCard forwards taps', (tester) async {
    var taps = 0;
    await tester.pumpApp(
      AppCard(onTap: () => taps++, child: const Text('Card')),
    );
    await tester.tap(find.text('Card'));
    expect(taps, 1);
  });

  testWidgets('AppSnackBar shows message with type icon', (tester) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () =>
              AppSnackBar.show(context, 'Saved', type: AppSnackBarType.success),
          child: const Text('show'),
        ),
      ),
    );

    await tester.tap(find.text('show'));
    await tester.pump();
    expect(find.text('Saved'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  group('AppConfirmDialog', () {
    Future<bool?> open(WidgetTester tester, String tapLabel) async {
      bool? result;
      await tester.pumpApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await AppConfirmDialog.show(
                context,
                title: 'Leave practice?',
              );
            },
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Leave practice?'), findsOneWidget);
      await tester.tap(find.text(tapLabel));
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('returns true on confirm', (tester) async {
      expect(await open(tester, 'Confirm'), isTrue);
    });

    testWidgets('returns false on cancel', (tester) async {
      expect(await open(tester, 'Cancel'), isFalse);
    });
  });
}
