// Widget tests for the welcome and legal document pages: actions,
// platform-specific options, legal links, and narrow large-text layouts.
import 'package:chapter_no/feature/auth/data/resource/local_legal_documents.dart';
import 'package:chapter_no/feature/auth/screens/legal_document_page.dart';
import 'package:chapter_no/feature/auth/screens/welcome_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_page.dart';

void main() {
  group('WelcomePage', () {
    late List<String> taps;

    Widget page() => WelcomePage(
      onContinueWithGoogle: () => taps.add('google'),
      onContinueWithApple: () => taps.add('apple'),
      onSignUpWithEmail: () => taps.add('email'),
      onLogIn: () => taps.add('login'),
      onOpenTerms: () => taps.add('terms'),
      onOpenPrivacy: () => taps.add('privacy'),
    );

    setUp(() => taps = []);

    testWidgets('forwards each action to its callback', (tester) async {
      await tester.pumpPage(page());

      await tester.tap(find.text('Continue with Google'));
      await tester.tap(find.text('Sign up with email'));
      await tester.tap(find.text('Log in'));

      expect(taps, ['google', 'email', 'login']);
    });

    testWidgets('opens terms and privacy from the consent text', (
      tester,
    ) async {
      await tester.pumpPage(page());
      final consent = tester.widget<RichText>(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('By signing'),
        ),
      );
      consent.text.visitChildren((span) {
        final recognizer = span is TextSpan ? span.recognizer : null;
        if (recognizer is TapGestureRecognizer) recognizer.onTap?.call();
        return true;
      });

      expect(taps, ['terms', 'privacy']);
    });

    testWidgets('offers Apple sign-in on iOS only', (tester) async {
      await tester.pumpPage(page());
      expect(find.text('Continue with Apple'), findsNothing);

      await tester.pumpPage(page(), platform: TargetPlatform.iOS);
      await tester.pumpAndSettle();
      expect(find.text('Continue with Apple'), findsOneWidget);
    });

    testWidgets('fits a narrow screen with 1.5x text without overflow', (
      tester,
    ) async {
      await tester.pumpPage(page(), size: const Size(320, 568), textScale: 1.5);
      expect(tester.takeException(), isNull);
    });
  });

  group('LegalDocumentPage', () {
    testWidgets('shows the title, draft notice, and numbered sections', (
      tester,
    ) async {
      await tester.pumpPage(
        const LegalDocumentPage(document: LocalLegalDocuments.terms),
        size: const Size(400, 2400),
      );

      expect(find.text('Terms of Service'), findsOneWidget);
      expect(find.textContaining('Last updated'), findsOneWidget);
      expect(find.textContaining('Draft wording'), findsOneWidget);
      expect(find.text('1. Using ChapterNo'), findsOneWidget);
      expect(
        find.text(
          '${LocalLegalDocuments.terms.sections.length}. '
          '${LocalLegalDocuments.terms.sections.last.heading}',
        ),
        findsOneWidget,
      );
    });

    testWidgets('fits a narrow screen with 1.5x text without overflow', (
      tester,
    ) async {
      await tester.pumpPage(
        const LegalDocumentPage(document: LocalLegalDocuments.privacy),
        size: const Size(320, 568),
        textScale: 1.5,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Privacy Policy'), findsOneWidget);
    });
  });
}
