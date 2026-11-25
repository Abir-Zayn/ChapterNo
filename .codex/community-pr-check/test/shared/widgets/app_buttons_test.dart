// Widget tests for AppButton, AppIconButton, and AppTileIconButton.
// Covers taps, disabled/loading states, touch targets, and narrow layouts.
import 'package:chapter_no/shared/widgets/app_button/app_button.dart';
import 'package:chapter_no/shared/widgets/app_icon_button/app_icon_button.dart';
import 'package:chapter_no/shared/widgets/app_tile_icon_button/app_tile_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppButton', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      var taps = 0;
      await tester.pumpApp(AppButton(label: 'Start', onPressed: () => taps++));

      await tester.tap(find.text('Start'));
      expect(taps, 1);
    });

    testWidgets('loading shows spinner and blocks taps', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        AppButton(label: 'Save', isLoading: true, onPressed: () => taps++),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Save'));
      expect(taps, 0);
    });

    testWidgets('label uses button foreground, not body text colour', (
      tester,
    ) async {
      await tester.pumpApp(AppButton(label: 'Go', onPressed: () {}));

      final context = tester.element(find.text('Go'));
      final scheme = Theme.of(context).colorScheme;
      expect(DefaultTextStyle.of(context).style.color, scheme.onPrimary);
    });

    testWidgets('meets 48dp height for every variant', (tester) async {
      for (final variant in AppButtonVariant.values) {
        await tester.pumpApp(
          AppButton(label: 'V', variant: variant, onPressed: () {}),
        );
        final size = tester.getSize(find.byType(AppButton));
        expect(size.height, greaterThanOrEqualTo(48), reason: '$variant');
      }
    });

    testWidgets('long Bangla label fits narrow width at 2x text', (
      tester,
    ) async {
      await tester.pumpApp(
        AppButton(
          label: 'অনুশীলন শুরু করুন এবং অগ্রগতি সংরক্ষণ করুন',
          icon: Icons.play_arrow,
          expand: true,
          onPressed: () {},
        ),
        width: 320,
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('AppIconButton', () {
    testWidgets('exposes tooltip and 48dp target', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        AppIconButton(
          icon: Icons.close,
          tooltip: 'Close',
          onPressed: () => taps++,
        ),
      );

      await tester.tap(find.byTooltip('Close'));
      expect(taps, 1);
      final size = tester.getSize(find.byType(IconButton));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });

  group('AppTileIconButton', () {
    testWidgets('taps when enabled and ignores taps when disabled', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        AppTileIconButton(
          icon: Icons.quiz_outlined,
          label: 'MCQ',
          onTap: () => taps++,
        ),
      );
      await tester.tap(find.text('MCQ'));
      expect(taps, 1);

      await tester.pumpApp(
        const AppTileIconButton(
          icon: Icons.quiz_outlined,
          label: 'MCQ',
          onTap: null,
        ),
      );
      await tester.tap(find.text('MCQ'));
      expect(taps, 1);
    });

    testWidgets('wraps long labels on a narrow tile without overflow', (
      tester,
    ) async {
      await tester.pumpApp(
        AppTileIconButton(
          icon: Icons.auto_stories_outlined,
          label: 'অধ্যায়ভিত্তিক অনুশীলন প্রশ্ন',
          subtitle: '১২টি অধ্যায়',
          onTap: () {},
        ),
        width: 96,
        textScale: 1.5,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
