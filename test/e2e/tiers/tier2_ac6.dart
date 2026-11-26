// Tier 2 boundary & negative E2E cases for AC-6 (Offline Sign-Out, Dialog
// Cancel, Failed Sign-Out, In-Flight Request Disposal, Direct User Switch).
import 'tier2_ac6_imports.dart';

void registerTier2Ac6Tests() {
  group('Tier 2 — AC-6: Session Isolation & Sign-Out Boundaries', () {
    testWidgets('T2-AC6-01 offline sign-out clears local session to welcome', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..seedUser(
          id: 'u1',
          email: 'u1@example.com',
          password: 'password1',
          signedIn: true,
        )
        ..nextSignOutFailure = AuthFailure.network;
      final profile = FakeProfileRepository(authRepository: auth);
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: AppRoutes.profile,
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Log Out'));
      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();
      await confirmLogoutDialog(tester);

      expect(find.text('Sign up with email'), findsOneWidget);
      expect(auth.currentUser, isNull);
      expect(profile.cachedProfile, isNull);
    });

    testWidgets('T2-AC6-02 cancelling sign-out dialog keeps user signed in', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..seedUser(
          id: 'u1',
          email: 'u1@example.com',
          password: 'password1',
          signedIn: true,
        );
      final profile = FakeProfileRepository(authRepository: auth);
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: AppRoutes.profile,
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Log Out'));
      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(auth.signOutCalls, 0);
      expect(auth.currentUser, isNotNull);
      expect(find.text('Tier: Free'), findsOneWidget);
    });

    testWidgets(
      'T2-AC6-03 failed signOut stays on Settings with error feedback',
      (tester) async {
        final auth = FakeAuthRepository()
          ..seedUser(
            id: 'u1',
            email: 'u1@example.com',
            password: 'password1',
            signedIn: true,
          )
          ..nextSignOutFailure = AuthFailure.unknown;
        final profile = FakeProfileRepository(authRepository: auth);
        addTearDown(auth.dispose);

        await pumpE2eApp(
          tester,
          authRepository: auth,
          profileRepository: profile,
          initialLocation: AppRoutes.settings,
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Log Out'));
        await tester.tap(find.text('Log Out'));
        await tester.pumpAndSettle();
        await confirmLogoutDialog(tester);

        expect(
          find.text('Could not sign out. Please try again.'),
          findsOneWidget,
        );
        expect(find.text('Settings'), findsOneWidget);
        expect(auth.currentUser, isNotNull);
      },
    );

    testWidgets(
      'T2-AC6-04 sign-out during pending getProfile drops late data',
      (tester) async {
        final auth = FakeAuthRepository()
          ..seedUser(
            id: 'a',
            email: 'a@example.com',
            password: 'password1',
            signedIn: true,
          );
        final pending = Completer<Either<ProfileFailure, StudentProfile>>();
        final profile = FakeProfileRepository(authRepository: auth)
          ..seedUserProfile(
            userId: 'a',
            email: 'a@example.com',
            fullName: 'Secret User A',
          );
        addTearDown(auth.dispose);

        final userAResult = await profile.getProfile();
        final userAProfile = userAResult.getOrElse(
          () => throw StateError('Expected User A profile'),
        );
        expect(userAProfile.fullName, 'Secret User A');
        expect(profile.cachedProfile, isNotNull);
        profile.profileCompleter = pending;

        await pumpE2eApp(
          tester,
          authRepository: auth,
          profileRepository: profile,
          initialLocation: AppRoutes.home,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Profile'));
        await tester.pump();

        await auth.signOut();
        await tester.pumpAndSettle();

        pending.complete(Right(userAProfile));
        await tester.pumpAndSettle();

        expect(find.text('Secret User A'), findsNothing);
        expect(find.text('Sign up with email'), findsOneWidget);
        expect(profile.clearCacheCount, greaterThanOrEqualTo(1));
        expect(profile.cachedProfile, isNull);
      },
    );

    testWidgets('T2-AC6-05 direct user switch A -> B clears cached user data', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..seedUser(
          id: 'a',
          email: 'a@example.com',
          password: 'password1',
          signedIn: true,
        );
      final profile = FakeProfileRepository(authRepository: auth)
        ..seedUserProfile(
          userId: 'a',
          email: 'a@example.com',
          fullName: 'Student A',
        );
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: AppRoutes.profile,
      );
      await tester.pumpAndSettle();
      expect(find.text('Student A'), findsOneWidget);
      expect(profile.cachedProfile, isNotNull);

      auth.seedUser(
        id: 'b',
        email: 'b@example.com',
        password: 'password1',
        signedIn: true,
      );
      await tester.pumpAndSettle();

      expect(profile.clearCacheCount, greaterThanOrEqualTo(1));
      expect(profile.cachedProfile, isNull);
      expect(find.text('Student A'), findsNothing);
    });
  });
}
