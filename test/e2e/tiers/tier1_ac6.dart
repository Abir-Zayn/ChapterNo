// Tier 1 isolated happy-path E2E tests covering AC-6 (Sign-Out & Shared-Device
// Account Isolation across Profile, Settings, and Public Curriculum Cache).
import 'tier1_ac6_imports.dart';

void registerTier1Ac6Tests() {
  group('Tier 1 — AC-6: Sign-Out & Shared-Device Account Isolation', () {
    testWidgets('T1-AC6-01 confirmed Profile Log Out clears cache to welcome', (
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
      expect(profile.cachedProfile, isNotNull);

      await tester.ensureVisible(find.text('Log Out'));
      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, 'Log Out'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign up with email'), findsOneWidget);
      expect(auth.currentUser, isNull);
      expect(profile.cachedProfile, isNull);
    });

    testWidgets(
      'T1-AC6-02 confirmed Settings Log Out clears cache to welcome',
      (tester) async {
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
          initialLocation: AppRoutes.settings,
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Log Out'));
        await tester.tap(find.text('Log Out'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.widgetWithText(FilledButton, 'Log Out'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Sign up with email'), findsOneWidget);
        expect(profile.clearCacheCount, greaterThanOrEqualTo(1));
      },
    );

    testWidgets('T1-AC6-03 Student A -> Student B switch isolates profile', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..seedUser(
          id: 'a',
          email: 'a@example.com',
          password: 'password1',
          signedIn: true,
        )
        ..seedUser(id: 'b', email: 'b@example.com', password: 'password1');
      final profile = FakeProfileRepository(authRepository: auth)
        ..seedUserProfile(
          userId: 'a',
          email: 'a@example.com',
          fullName: 'Ayesha Rahman',
          academicGroup: 'Science',
        )
        ..seedUserProfile(
          userId: 'b',
          email: 'b@example.com',
          fullName: 'Karim Uddin',
          academicGroup: 'Humanities',
        );
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: AppRoutes.profile,
      );
      await tester.pumpAndSettle();
      expect(find.text('Ayesha Rahman'), findsOneWidget);

      await tester.ensureVisible(find.text('Log Out'));
      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, 'Log Out'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
      await enterAuthField(tester, 'Email', 'b@example.com');
      await enterAuthField(tester, 'Password', 'password1');
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Karim Uddin'), findsOneWidget);
      expect(find.textContaining('Humanities'), findsOneWidget);
      expect(find.text('Ayesha Rahman'), findsNothing);
    });

    testWidgets('T1-AC6-04 Student A -> Student B switch isolates settings', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..seedUser(
          id: 'a',
          email: 'a@example.com',
          password: 'password1',
          signedIn: true,
        )
        ..seedUser(id: 'b', email: 'b@example.com', password: 'password1');
      final profile = FakeProfileRepository(authRepository: auth)
        ..seedUserProfile(
          userId: 'a',
          email: 'a@example.com',
          fullName: 'Ayesha',
          settings: const AppSettings(
            notificationsEnabled: false,
            soundEffectsEnabled: false,
            hapticsEnabled: true,
            learningTrack: LearningTrack.examSprint,
            language: AppLanguage.english,
            darkModeEnabled: true,
          ),
        )
        ..seedUserProfile(
          userId: 'b',
          email: 'b@example.com',
          fullName: 'Karim',
          settings: const AppSettings(
            notificationsEnabled: true,
            soundEffectsEnabled: true,
            hapticsEnabled: false,
            learningTrack: LearningTrack.standardSsc,
            language: AppLanguage.english,
            darkModeEnabled: false,
          ),
        );
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: AppRoutes.settings,
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SwitchListTile>(
              find.widgetWithText(SwitchListTile, 'Dark Mode'),
            )
            .value,
        isTrue,
      );

      await tester.ensureVisible(find.text('Log Out'));
      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(FilledButton, 'Log Out'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
      await enterAuthField(tester, 'Email', 'b@example.com');
      await enterAuthField(tester, 'Password', 'password1');
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<SwitchListTile>(
              find.widgetWithText(SwitchListTile, 'Dark Mode'),
            )
            .value,
        isFalse,
      );
    });

    test('T1-AC6-05 sign-out preserves public curriculum cache', () async {
      final auth = FakeAuthRepository()
        ..seedUser(
          id: 'u1',
          email: 'u1@example.com',
          password: 'password1',
          signedIn: true,
        );
      final profile = FakeProfileRepository(authRepository: auth);
      final curriculum = FakeCurriculumCatalogue();
      addTearDown(auth.dispose);

      await curriculum.getEducationBoards();
      expect(curriculum.remoteCalls, 1);

      await auth.signOut();
      await profile.clearCachedUserData();
      curriculum.isOffline = true;

      final boards = await curriculum.getEducationBoards();
      expect(boards.isRight(), isTrue);
      expect(curriculum.remoteCalls, 1);
    });
  });
}
