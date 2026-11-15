// Widget tests for AppText, AppTextField, and AppPasswordField.
// Covers system-font usage, Bangla-safe styling, input, validation, toggling.
import 'package:chapter_no/shared/widgets/app_password_field/app_password_field.dart';
import 'package:chapter_no/shared/widgets/app_text/app_text.dart';
import 'package:chapter_no/shared/widgets/app_text_field/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppText', () {
    testWidgets('keeps theme (system) font and applies Bangla-safe style', (
      tester,
    ) async {
      await tester.pumpApp(const AppText.title('অধ্যায় ১'));

      final text = tester.widget<Text>(find.text('অধ্যায় ১'));
      final context = tester.element(find.text('অধ্যায় ১'));
      final themeFont = Theme.of(context).textTheme.titleMedium?.fontFamily;

      expect(text.style?.fontFamily, themeFont);
      expect(text.style?.height, AppText.banglaSafeHeight);
      expect(text.style?.letterSpacing, 0);
    });

    testWidgets('ellipsizes when maxLines is set', (tester) async {
      await tester.pumpApp(const AppText('long text', maxLines: 1));

      final text = tester.widget<Text>(find.text('long text'));
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });

  group('AppTextField', () {
    testWidgets('shows label, reports changes, and validates', (tester) async {
      final formKey = GlobalKey<FormState>();
      String? changed;
      await tester.pumpApp(
        Form(
          key: formKey,
          child: AppTextField(
            label: 'Email',
            hint: 'you@example.com',
            onChanged: (v) => changed = v,
            validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'a@b.co');
      expect(changed, 'a@b.co');
      expect(formKey.currentState!.validate(), isTrue);
    });
  });

  group('AppPasswordField', () {
    testWidgets('is obscured by default and toggles visibility', (
      tester,
    ) async {
      await tester.pumpApp(const AppPasswordField(label: 'Password'));

      TextField field() => tester.widget<TextField>(find.byType(TextField));
      expect(field().obscureText, isTrue);
      expect(field().enableSuggestions, isFalse);
      expect(find.byTooltip('Show password'), findsOneWidget);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();

      expect(field().obscureText, isFalse);
      expect(find.byTooltip('Hide password'), findsOneWidget);
    });

    testWidgets('toggle is disabled when field is disabled', (tester) async {
      await tester.pumpApp(const AppPasswordField(enabled: false));

      // Disabled IconButton ignores pointers, so the tap is expected to miss.
      await tester.tap(find.byType(IconButton), warnIfMissed: false);
      await tester.pump();

      expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText,
        isTrue,
      );
    });
  });
}
