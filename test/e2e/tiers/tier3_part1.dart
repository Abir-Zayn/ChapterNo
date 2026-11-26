// Tier 3 pairwise cross-feature E2E scenarios (T3-01..T3-04) combining
// Auth, Onboarding, Curriculum, Profile, Analytics, Settings, and Lifecycle.
import 'tier3_part1_imports.dart';

void registerTier3Part1Tests() {
  group('Tier 3 — Cross-Feature Pairwise Interactions (Part 1)', () {
    testWidgets(
      'T3-01 Sign-Up -> Onboarding -> Home -> Cold Restart skips gate',
      (tester) async {
        final auth = FakeAuthRepository();
        final profile = FakeProfileRepository(authRepository: auth);
        addTearDown(auth.dispose);

        await pumpE2eApp(
          tester,
          authRepository: auth,
          profileRepository: profile,
          initialLocation: AppRoutes.welcome,
          today: DateTime(2026, 11, 25),
        );
        await tester.tap(find.text('Sign up with email'));
        await tester.pumpAndSettle();
        await pickDefaultDob(tester);
        await enterAuthField(tester, 'Email', 't301@example.com');
        await enterAuthField(tester, 'Password', 'Secret123!');
        final createBtn = find.widgetWithText(FilledButton, 'Create account');
        await tester.ensureVisible(createBtn);
        await tester.tap(createBtn);
        await tester.pumpAndSettle();

        expect(find.text('Complete your profile'), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('onboarding_name_field')),
          'Farhan Ahmed',
        );
        await tester.tap(find.text('Save and continue'));
        await tester.pumpAndSettle();
        expect(find.text('Your study dashboard'), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await pumpE2eApp(
          tester,
          authRepository: auth,
          profileRepository: profile,
          initialLocation: AppRoutes.splash,
        );
        await tester.pumpAndSettle();
        expect(find.text('Your study dashboard'), findsOneWidget);
      },
    );

    testWidgets('T3-02 Onboarding board & Business Studies feeds curriculum', (
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
      final curriculum = FakeCurriculumCatalogue();
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        curriculum: curriculum,
        initialLocation: '/onboarding',
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('onboarding_name_field')),
        'Mahi Chowdhury',
      );
      await tester.tap(find.text('Business Studies'));
      await tester.tap(find.textContaining('Cumilla'));
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();

      final subjects = await curriculum.getSubjectsForGroup(
        E2eAcademicGroup.businessStudies,
      );
      subjects.fold((_) => fail('expected subjects'), (items) {
        final names = items.map((s) => s.titleEn).toList();
        expect(names, containsAll(['Bangla', 'English', 'Accounting']));
        expect(names, isNot(contains('Physics')));
      });
    });

    testWidgets(
      'T3-03 Onboarding -> Profile & Analytics show honest zero state',
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
          initialLocation: '/onboarding',
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('onboarding_name_field')),
          'Nusrat Jahan',
        );
        await tester.tap(find.text('Casual'));
        await tester.tap(find.text('Save and continue'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        expect(find.text('Nusrat Jahan'), findsOneWidget);
        expect(find.text('Tier: Free'), findsOneWidget);
        expect(find.text('Unranked'), findsOneWidget);
        expect(find.text('Pace: Casual'), findsOneWidget);

        await tester.ensureVisible(find.text('Learning Analytics'));
        await tester.tap(find.text('Learning Analytics'));
        await tester.pumpAndSettle();
        expect(find.text('0 questions'), findsOneWidget);
        expect(find.text('Unranked'), findsOneWidget);
      },
    );

    testWidgets(
      'T3-04 Settings update -> pause flush -> cold restart dark theme',
      (tester) async {
        final prefs = FakeAppPrefsStore();
        final auth = FakeAuthRepository(prefs: prefs)
          ..seedUser(
            id: 'u1',
            email: 'u1@example.com',
            password: 'password1',
            signedIn: true,
          );
        final profile =
            FakeProfileRepository(authRepository: auth, prefs: prefs)
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
          prefs: prefs,
          initialLocation: AppRoutes.settings,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Dark Mode'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(LearningTrack.examSprint.label));
        await tester.pumpAndSettle();

        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();
        expect(profile.flushCount, 1);

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
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
        expect(find.text('Your study dashboard'), findsOneWidget);
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<ChoiceChip>(
                find.widgetWithText(ChoiceChip, LearningTrack.examSprint.label),
              )
              .selected,
          isTrue,
        );
      },
    );
  });
}
