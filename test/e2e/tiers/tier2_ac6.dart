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
          )
          ..profileCompleter = pending;
        addTearDown(auth.dispose);

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
        await tester.pump();
        pending.complete(
          await FakeProfileRepository(authRepository: auth).getProfile(),
        );
        await tester.pump();

        expect(profile.cachedProfile, isNull);
      },
    );

    test(
      'T2-AC6-05 direct user switch A -> B clears cached user data',
      () async {
        final auth = FakeAuthRepository()
          ..seedUser(
            id: 'a',
            email: 'a@example.com',
            password: 'password1',
            signedIn: true,
          );
        final profile = FakeProfileRepository(authRepository: auth);
        addTearDown(auth.dispose);

        await profile.getProfile();
        expect(profile.cachedProfile, isNotNull);

        final clears = <int>[];
        final sub = auth.authUserChanges.listen((uid) async {
          if (uid != 'a') {
            await profile.clearCachedUserData();
            clears.add(profile.clearCacheCount);
          }
        });
        addTearDown(sub.cancel);

        auth.seedUser(
          id: 'b',
          email: 'b@example.com',
          password: 'password1',
          signedIn: true,
        );
        await Future<void>.delayed(Duration.zero);
        expect(clears, isNotEmpty);
        expect(profile.cachedProfile, isNull);
      },
    );
  });
}
