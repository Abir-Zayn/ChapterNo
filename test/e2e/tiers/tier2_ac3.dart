// Tier 2 boundary & negative E2E cases for AC-3 (Splash Offline Recovery,
// Login Gate Failure Safety, and SplashCubit Close Guard).
import 'tier2_ac3_imports.dart';

void registerTier2Ac3Tests() {
  group('Tier 2 — AC-3: Onboarding Gate & Splash Boundaries', () {
    testWidgets('T2-AC3-01 offline onboarding check shows retry & sign out', (
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
        ..nextOnboardingFailure = const ProfileFailure('Network error');
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not verify profile'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
      expect(find.text('Sign up with email'), findsNothing);
    });

    testWidgets('T2-AC3-02 Splash offline Retry recovers when online', (
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
        )
        ..nextOnboardingFailure = const ProfileFailure('Network error');
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Your study dashboard'), findsOneWidget);
    });

    testWidgets('T2-AC3-03 Splash offline Sign out clears session to welcome', (
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
        ..nextOnboardingFailure = const ProfileFailure('Network error');
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.text('Sign up with email'), findsOneWidget);
      expect(auth.currentUser, isNull);
    });

    testWidgets('T2-AC3-04 login with offline onboarding check blocks home', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..seedUser(id: 'u1', email: 'u1@example.com', password: 'password1');
      final profile = FakeProfileRepository(authRepository: auth)
        ..nextOnboardingFailure = const ProfileFailure('Offline');
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

      expect(find.text('Could not verify profile'), findsOneWidget);
      expect(find.text('Your study dashboard'), findsNothing);
    });

    test(
      'T2-AC3-05 closing SplashCubit mid-restore does not emit after close',
      () async {
        final auth = FakeAuthRepository();
        final pending = Completer<Either<AuthFailure, AuthUser?>>();
        auth.restoreCompleter = pending;
        addTearDown(auth.dispose);

        final cubit = SplashCubit(
          authRepository: auth,
          minimumDisplay: Duration.zero,
        );
        final future = cubit.start();
        await cubit.close();
        pending.complete(const Right(null));
        await future;
        expect(cubit.isClosed, isTrue);
      },
    );
  });
}
