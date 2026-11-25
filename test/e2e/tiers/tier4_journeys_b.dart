// Tier 4 realistic Bangladesh SSC student multi-step journeys (T4-04..T4-06):
// Verification + reset + login, mid-submit drop + pause flush, route recovery.
import 'tier4_journeys_b_imports.dart';

void registerTier4JourneysBTests() {
  group('Tier 4 — Real-World SSC Student Journeys (Part B)', () {
    testWidgets('T4-04 Verification sign-up + password reset + onboarding', (
      tester,
    ) async {
      final auth = FakeAuthRepository()..nextSignUpRequiresVerification = true;
      final profile = FakeProfileRepository(authRepository: auth);
      addTearDown(auth.dispose);

      await auth.signUp(
        email: 'sadia@example.com',
        password: 'Password1',
        dateOfBirth: DateTime(2010, 6, 15),
      );
      expect(auth.currentUser, isNull);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: AppRoutes.login,
      );
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      await enterAuthField(tester, 'Email', 'sadia@example.com');
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();
      expect(auth.sentResetEmails, ['sadia@example.com']);
      await tester.tap(find.text('Back to log in'));
      await tester.pumpAndSettle();

      await enterAuthField(tester, 'Email', 'sadia@example.com');
      await enterAuthField(tester, 'Password', 'Password1');
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pumpAndSettle();
      expect(find.text('Your study dashboard'), findsNothing);

      auth.confirmEmail('sadia@example.com');
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pumpAndSettle();
      expect(find.text('Complete your profile'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('onboarding_name_field')),
        'Sadia Islam',
      );
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save and continue'));
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();
      expect(find.text('Your study dashboard'), findsOneWidget);
    });

    testWidgets('T4-05 Network drop + background flush + dark theme restart', (
      tester,
    ) async {
      final prefs = FakeAppPrefsStore();
      final auth = FakeAuthRepository(prefs: prefs)
        ..seedUser(
          id: 'u1',
          email: 'u1@example.com',
          password: 'password1',
          signedIn: true,
        );
      final profile = FakeProfileRepository(authRepository: auth, prefs: prefs)
        ..nextCompleteOnboardingFailure = const ProfileFailure('Network lost');
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        prefs: prefs,
        initialLocation: '/onboarding',
        size: const Size(360, 800),
        textScale: 1.3,
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('onboarding_name_field')),
        'Mehedi Hasan',
      );
      await tester.ensureVisible(find.text('Save and continue'));
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();
      expectNoRenderOverflow(tester);
      expect(find.text('Network lost'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save and continue'));
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(LearningTrack.examSprint.label));
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(profile.flushCount, 2);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        prefs: prefs,
      );
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Your study dashboard'), findsOneWidget);
    });

    testWidgets('T4-06 Signed-out recovery & incomplete onboarding gate loop', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..seedUser(id: 'u1', email: 'u1@example.com', password: 'password1');
      final profile = FakeProfileRepository(authRepository: auth)
        ..seedUserProfile(
          userId: 'u1',
          email: 'u1@example.com',
          onboarded: false,
        );
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
      );
      await tester.pumpAndSettle();
      expect(find.text('Sign up with email'), findsOneWidget);

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
      await enterAuthField(tester, 'Email', 'u1@example.com');
      await enterAuthField(tester, 'Password', 'password1');
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pumpAndSettle();
      expect(find.text('Complete your profile'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
      );
      await tester.pumpAndSettle();
      expect(find.text('Complete your profile'), findsOneWidget);
      expect(find.text('Your study dashboard'), findsNothing);
    });
  });
}
