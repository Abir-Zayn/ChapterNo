// Top-level Step 1 E2E sanity smoke suite verifying the complete cycle from
// Splash -> Welcome -> SignUp -> Onboarding -> Home -> Profile -> Analytics ->
// Settings -> SignOut -> Login alongside Tier 1-4 suites in test/e2e/.
import 'step1_e2e_test_imports.dart';

void main() {
  group('Step 1 E2E Smoke Suite', () {
    test('core env and light/dark monochrome theme contracts hold', () {
      expect(() => Env.validate(), throwsStateError);
      expect(AppTheme.light().scaffoldBackgroundColor.a, 1.0);
      expect(AppTheme.dark().scaffoldBackgroundColor.a, 1.0);
      expect(AppRoutes.splash, '/');
    });

    testWidgets(
      'complete Splash -> SignUp -> Onboarding -> Profile -> Logout -> Login',
      (tester) async {
        final prefs = FakeAppPrefsStore();
        final auth = FakeAuthRepository(prefs: prefs);
        final profile = FakeProfileRepository(
          authRepository: auth,
          prefs: prefs,
        );
        final curriculum = FakeCurriculumCatalogue();
        addTearDown(auth.dispose);

        await pumpE2eApp(
          tester,
          authRepository: auth,
          profileRepository: profile,
          curriculum: curriculum,
          prefs: prefs,
          today: DateTime(2026, 11, 25),
        );
        await tester.pumpAndSettle();
        expect(find.text('Sign up with email'), findsOneWidget);

        await tester.tap(find.text('Sign up with email'));
        await tester.pumpAndSettle();
        await pickDefaultDob(tester);
        await enterAuthField(tester, 'Email', 'smoke.student@example.com');
        await enterAuthField(tester, 'Password', 'SmokePass123');
        final createBtn = find.widgetWithText(FilledButton, 'Create account');
        await tester.ensureVisible(createBtn);
        await tester.tap(createBtn);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('onboarding_name_field')),
          'Smoke Student',
        );
        await tester.tap(find.text('Save and continue'));
        await tester.pumpAndSettle();
        expect(find.text('Your study dashboard'), findsOneWidget);

        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        expect(find.text('Smoke Student'), findsOneWidget);
        expect(find.text('Tier: Free'), findsOneWidget);
        expect(find.text('Unranked'), findsOneWidget);

        await tester.ensureVisible(find.text('Learning Analytics'));
        await tester.tap(find.text('Learning Analytics'));
        await tester.pumpAndSettle();
        expect(find.text('No practice data yet'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Log Out'));
        await tester.tap(find.text('Log Out'));
        await tester.pumpAndSettle();
        await confirmLogoutDialog(tester);
        expect(find.text('Sign up with email'), findsOneWidget);

        await tester.tap(find.text('Log in'));
        await tester.pumpAndSettle();
        await enterAuthField(tester, 'Email', 'smoke.student@example.com');
        await enterAuthField(tester, 'Password', 'SmokePass123');
        await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
        await tester.pumpAndSettle();
        expect(find.text('Your study dashboard'), findsOneWidget);
      },
    );
  });
}
