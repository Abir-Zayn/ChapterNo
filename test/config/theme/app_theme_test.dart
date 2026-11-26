// Verifies the monochrome primary: near-black in the light theme, white in
// the dark theme, and that the context.primary* getters follow the theme.
import 'package:chapter_no/config/theme/app_colors.dart';
import 'package:chapter_no/config/theme/app_palette.dart';
import 'package:chapter_no/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light theme primary is near-black with white foreground', () {
    final scheme = AppTheme.light().colorScheme;
    expect(scheme.brightness, Brightness.light);
    expect(scheme.primary, AppColors.primary);
    expect(scheme.primary, const Color(0xFF18181B));
    expect(scheme.onPrimary, Colors.white);
  });

  test('dark theme primary is white with dark foreground', () {
    final scheme = AppTheme.dark().colorScheme;
    expect(scheme.brightness, Brightness.dark);
    expect(scheme.primary, const Color(0xFFFAFAFA));
    expect(scheme.onPrimary, AppColors.onPrimaryDark);
    expect(scheme.surface, AppColors.surfaceDark);
  });

  for (final (name, theme, expected) in [
    ('light', AppTheme.light(), AppColors.primary),
    ('dark', AppTheme.dark(), AppColors.primaryDark),
  ]) {
    testWidgets('context.primary resolves from the $name theme', (
      tester,
    ) async {
      late Color resolved;
      late Color resolvedSoft;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              resolved = context.primary;
              resolvedSoft = context.primarySoft;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(resolved, expected);
      expect(resolvedSoft, theme.colorScheme.primaryContainer);
    });
  }
}
