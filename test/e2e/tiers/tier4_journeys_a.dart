// Tier 4 realistic Bangladesh SSC student multi-step journeys (T4-01..T4-03):
// New Chittagong Science student, intermittent mobile data, and sibling switch.
import 'tier4_journeys_a_imports.dart';

void registerTier4JourneysATests() {
  group('Tier 4 — Real-World SSC Student Journeys (Part A)', () {
    testWidgets('T4-01 New Chittagong SSC Science student first-time journey', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      final profile = FakeProfileRepository(authRepository: auth);
      final curriculum = FakeCurriculumCatalogue();
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        curriculum: curriculum,
        today: DateTime(2026, 11, 25),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign up with email'));
      await tester.pumpAndSettle();
      await pickDefaultDob(tester);
      await enterAuthField(tester, 'Email', 'tanvir.ctg@example.com');
      await enterAuthField(tester, 'Password', 'Chittagong27!');
      final createBtn = find.widgetWithText(FilledButton, 'Create account');
      await tester.ensureVisible(createBtn);
      await tester.tap(createBtn);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('onboarding_name_field')),
        'Tanvir Hasan',
      );
      await tester.tap(find.textContaining('Chittagong'));
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();
      expect(find.text('Your study dashboard'), findsOneWidget);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Tanvir Hasan'), findsOneWidget);
      expect(find.text('Tier: Free'), findsOneWidget);
      expect(find.text('MCQs Solved: 0'), findsOneWidget);
      expect(find.text('Unranked'), findsOneWidget);

      await tester.ensureVisible(find.text('Learning Analytics'));
      await tester.tap(find.text('Learning Analytics'));
      await tester.pumpAndSettle();
      expect(find.text('No practice data yet'), findsOneWidget);

      final subjects = await curriculum.getSubjectsForGroup(
        E2eAcademicGroup.science,
      );
      subjects.fold((_) => fail('expected subjects'), (items) {
        expect(
          items.map((s) => s.titleEn),
          containsAll(['Bangla', 'English', 'ICT', 'Physics', 'Chemistry']),
        );
      });
    });

    testWidgets('T4-02 Returning student cold-start on intermittent data', (
      tester,
    ) async {
      var now = DateTime.utc(2026, 11, 25, 8);
      final prefs = FakeAppPrefsStore()..darkModeEnabled = true;
      final auth = FakeAuthRepository(prefs: prefs)
        ..seedUser(
          id: 'u1',
          email: 'u1@example.com',
          password: 'password1',
          signedIn: true,
        );
      final profile = FakeProfileRepository(authRepository: auth, prefs: prefs)
        ..seedUserProfile(
          userId: 'u1',
          email: 'u1@example.com',
          onboarded: true,
        )
        ..nextOnboardingFailure = const ProfileFailure('Network offline');
      final curriculum = FakeCurriculumCatalogue(clock: () => now);
      addTearDown(auth.dispose);

      await curriculum.getSubjectsForGroup(E2eAcademicGroup.science);
      curriculum.isOffline = true;

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        curriculum: curriculum,
        prefs: prefs,
      );
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(find.text('Could not load your profile'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Your study dashboard'), findsOneWidget);

      now = now.add(const Duration(hours: 25));
      curriculum.clearMemoryOnly();
      final staleScience = await curriculum.getSubjectsForGroup(
        E2eAcademicGroup.science,
      );
      expect(staleScience.isRight(), isTrue);
      final uncachedTopics = await curriculum.getTopicsForChapter(404);
      uncachedTopics.fold(
        (f) => expect(f, E2eCurriculumFailure.offline),
        (_) => fail('expected offline miss'),
      );
    });

    testWidgets('T4-03 Shared household phone sibling switch & isolation', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..seedUser(
          id: 'ayesha',
          email: 'ayesha@example.com',
          password: 'Password1',
          signedIn: true,
        )
        ..seedUser(
          id: 'karim',
          email: 'karim@example.com',
          password: 'Password2',
        );
      final profile = FakeProfileRepository(authRepository: auth)
        ..seedUserProfile(
          userId: 'ayesha',
          email: 'ayesha@example.com',
          fullName: 'Ayesha Siddiqua',
          academicGroup: 'Science',
          onboarded: true,
          settings: const AppSettings(
            notificationsEnabled: false,
            soundEffectsEnabled: true,
            hapticsEnabled: true,
            learningTrack: LearningTrack.examSprint,
            language: AppLanguage.english,
            darkModeEnabled: true,
          ),
        )
        ..seedUserProfile(
          userId: 'karim',
          email: 'karim@example.com',
          fullName: 'Karim',
          onboarded: false,
        );
      final curriculum = FakeCurriculumCatalogue();
      addTearDown(auth.dispose);
      await curriculum.getEducationBoards();

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        curriculum: curriculum,
        initialLocation: AppRoutes.settings,
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Log Out'));
      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();
      await confirmLogoutDialog(tester);

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
      await enterAuthField(tester, 'Email', 'karim@example.com');
      await enterAuthField(tester, 'Password', 'Password2');
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pumpAndSettle();

      expect(find.text('Complete your profile'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('onboarding_name_field')),
        'Karim Uddin',
      );
      await tester.tap(find.text('Humanities'));
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Karim Uddin'), findsOneWidget);
      expect(find.textContaining('Humanities'), findsOneWidget);
      expect(find.text('Ayesha Siddiqua'), findsNothing);

      await tester.ensureVisible(find.text('App Settings'));
      await tester.tap(find.text('App Settings'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SwitchListTile>(
              find.widgetWithText(SwitchListTile, 'Dark Mode'),
            )
            .value,
        isFalse,
      );
      expect(
        tester
            .widget<SwitchListTile>(
              find.widgetWithText(SwitchListTile, 'Notifications'),
            )
            .value,
        isTrue,
      );
    });
  });
}
