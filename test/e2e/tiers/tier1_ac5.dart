// Tier 1 isolated happy-path E2E tests covering AC-5 (Honest Zero-State
// Profile, Analytics & Settings Persistence).
import 'tier1_ac5_imports.dart';

void registerTier1Ac5Tests() {
  group('Tier 1 — AC-5: Honest Zero-State Profile, Analytics & Settings', () {
    testWidgets('T1-AC5-01 new student profile renders Free tier and 0 stats', (
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
          fullName: 'Nusrat Jahan',
        );
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: AppRoutes.profile,
      );
      await tester.pumpAndSettle();

      expect(find.text('Nusrat Jahan'), findsOneWidget);
      expect(find.text('Tier: Free'), findsOneWidget);
      expect(find.text('Plus Tier'), findsNothing);
      expect(find.text('MCQs Solved: 0'), findsOneWidget);
      expect(find.text('Accuracy: 0%'), findsOneWidget);
      expect(find.text('Unranked'), findsOneWidget);
    });

    testWidgets('T1-AC5-02 LearningAnalyticsPage shows zero metrics honestly', (
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
        initialLocation: AppRoutes.learningAnalytics,
      );
      await tester.pumpAndSettle();

      // Wave 4 M1.4: update assertion to AppStateView empty state + Practice CTA.
      expect(find.text('Learning Analytics'), findsOneWidget);
      expect(find.text('Unranked'), findsOneWidget);
      expect(find.text('0 Days'), findsOneWidget);
      expect(find.text('0 questions'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('0 Enrolled'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('0 Enrolled'), findsOneWidget);
      expect(find.text('Physics'), findsNothing);
    });

    testWidgets('T1-AC5-03 updating learning pace persists via ProfileCubit', (
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
      await tester.tap(find.text('Intensive'));
      await tester.pumpAndSettle();

      expect(find.text('Pace: Intensive'), findsOneWidget);
    });

    testWidgets('T1-AC5-04 settings toggles and track update persist', (
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
      final profile = FakeProfileRepository(authRepository: auth, prefs: prefs);
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        prefs: prefs,
        initialLocation: AppRoutes.settings,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(LearningTrack.examSprint.label));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(AppLanguage.bangla.label));
      await tester.tap(find.text(AppLanguage.bangla.label));
      await tester.pumpAndSettle();

      final saved = await profile.getSettings();
      saved.fold((_) => fail('expected settings'), (s) {
        expect(s.notificationsEnabled, isFalse);
        expect(s.learningTrack, LearningTrack.examSprint);
        expect(s.language, AppLanguage.bangla);
      });
      expect(prefs.language, AppLanguage.bangla);
    });

    testWidgets('T1-AC5-05 dark mode mirror applies on next cold launch', (
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
      final profile = FakeProfileRepository(authRepository: auth, prefs: prefs);
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        prefs: prefs,
        initialLocation: AppRoutes.settings,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();
      expect(prefs.darkModeEnabled, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        prefs: prefs,
        initialLocation: AppRoutes.splash,
      );
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      await tester.pumpAndSettle();
    });
  });
}
