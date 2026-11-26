// Tier 1 isolated happy-path E2E tests covering AC-3 (Onboarding Gate
// Enforcement across Splash cold launch and Login transitions).
import 'tier1_ac3_imports.dart';

void registerTier1Ac3Tests() {
  group('Tier 1 — AC-3: Onboarding Gate Enforcement', () {
    testWidgets('T1-AC3-01 signed-out splash routes to welcome', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      final profile = FakeProfileRepository(authRepository: auth);
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
      );
      await tester.pumpAndSettle();
      expect(find.text('Sign up with email'), findsOneWidget);
    });

    testWidgets(
      'T1-AC3-02 signed-in incomplete onboarding routes to onboarding',
      (tester) async {
        final auth = FakeAuthRepository()
          ..seedUser(
            id: 'u1',
            email: 'u1@example.com',
            password: 'password1',
            signedIn: true,
          );
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
        expect(find.text('Complete your profile'), findsOneWidget);
        expect(find.text('Your study dashboard'), findsNothing);
      },
    );

    testWidgets('T1-AC3-03 signed-in completed onboarding routes to home', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..seedUser(
          id: 'u1',
          email: 'u1@example.com',
          password: 'password1',
          signedIn: true,
        );
      final profile = FakeProfileRepository(authRepository: auth)
        ..seedUserProfile(
          userId: 'u1',
          email: 'u1@example.com',
          onboarded: true,
        );
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
      );
      await tester.pumpAndSettle();
      expect(find.text('Your study dashboard'), findsOneWidget);
    });

    testWidgets(
      'T1-AC3-04 login with incomplete onboarding routes to onboarding',
      (tester) async {
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
          initialLocation: AppRoutes.login,
        );
        await enterAuthField(tester, 'Email', 'u1@example.com');
        await enterAuthField(tester, 'Password', 'password1');
        await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
        await tester.pumpAndSettle();
        expect(find.text('Complete your profile'), findsOneWidget);
      },
    );

    testWidgets('T1-AC3-05 login with completed onboarding routes to home', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..seedUser(id: 'u1', email: 'u1@example.com', password: 'password1');
      final profile = FakeProfileRepository(authRepository: auth)
        ..seedUserProfile(
          userId: 'u1',
          email: 'u1@example.com',
          onboarded: true,
        );
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: AppRoutes.login,
      );
      await enterAuthField(tester, 'Email', 'u1@example.com');
      await enterAuthField(tester, 'Password', 'password1');
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pumpAndSettle();
      expect(find.text('Your study dashboard'), findsOneWidget);
    });
  });
}
