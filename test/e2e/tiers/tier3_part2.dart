// Tier 3 pairwise cross-feature E2E scenarios (T3-05..T3-08) combining
// Shared-Device Reset, Curriculum Cache Survival, Verification, and 360px A11y.
import 'tier3_part2_imports.dart';

void registerTier3Part2Tests() {
  group('Tier 3 — Cross-Feature Pairwise Interactions (Part 2)', () {
    testWidgets('T3-05 Sign-Out -> Re-Login isolates Profile & Settings', (
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
          academicGroup: 'Science',
          settings: const AppSettings(
            notificationsEnabled: true,
            soundEffectsEnabled: true,
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
          academicGroup: 'Humanities',
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
      await tester.ensureVisible(find.text('Log Out'));
      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();
      await confirmLogoutDialog(tester);

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
      await enterAuthField(tester, 'Email', 'b@example.com');
      await enterAuthField(tester, 'Password', 'password1');
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Karim'), findsOneWidget);
      expect(find.textContaining('Humanities'), findsOneWidget);
      expect(find.text('Ayesha'), findsNothing);

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
    });

    testWidgets(
      'T3-06 Curriculum cache survives sign-out for next offline user',
      (tester) async {
        final auth = FakeAuthRepository()
          ..seedUser(
            id: 'a',
            email: 'a@example.com',
            password: 'password1',
            signedIn: true,
          )
          ..seedUser(id: 'b', email: 'b@example.com', password: 'password1');
        final profile = FakeProfileRepository(authRepository: auth);
        final curriculum = FakeCurriculumCatalogue();
        addTearDown(auth.dispose);

        await curriculum.getEducationBoards();
        await curriculum.getSubjectsForGroup(E2eAcademicGroup.science);
        expect(curriculum.remoteCalls, 2);

        await auth.signOut();
        await profile.clearCachedUserData();
        curriculum.isOffline = true;

        await auth.signIn(email: 'b@example.com', password: 'password1');
        final cachedBoards = await curriculum.getEducationBoards();
        final cachedScience = await curriculum.getSubjectsForGroup(
          E2eAcademicGroup.science,
        );
        expect(cachedBoards.isRight(), isTrue);
        expect(cachedScience.isRight(), isTrue);
        expect(curriculum.remoteCalls, 2);
      },
    );

    testWidgets(
      'T3-07 Verification-gated sign-up -> confirm -> login -> onboarding',
      (tester) async {
        final auth = FakeAuthRepository()
          ..nextSignUpRequiresVerification = true;
        final profile = FakeProfileRepository(authRepository: auth);
        addTearDown(auth.dispose);

        final signUpRes = await auth.signUp(
          email: 'verify.me@example.com',
          password: 'Password1',
          dateOfBirth: DateTime(2010, 4, 20),
        );
        expect(signUpRes.isRight(), isTrue);
        expect(auth.currentUser, isNull);

        await pumpE2eApp(
          tester,
          authRepository: auth,
          profileRepository: profile,
          initialLocation: AppRoutes.login,
        );
        await enterAuthField(tester, 'Email', 'verify.me@example.com');
        await enterAuthField(tester, 'Password', 'Password1');
        await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
        await tester.pumpAndSettle();
        expect(find.text('Your study dashboard'), findsNothing);

        auth.confirmEmail('verify.me@example.com');
        await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
        await tester.pumpAndSettle();
        expect(find.text('Complete your profile'), findsOneWidget);
      },
    );

    testWidgets(
      'T3-08 360px 1.3x scale Onboarding failure preserves & recovers',
      (tester) async {
        final auth = FakeAuthRepository()
          ..seedUser(
            id: 'u1',
            email: 'u1@example.com',
            password: 'password1',
            signedIn: true,
          );
        final profile = FakeProfileRepository(authRepository: auth)
          ..nextCompleteOnboardingFailure = const ProfileFailure('Offline');
        addTearDown(auth.dispose);

        await pumpE2eApp(
          tester,
          authRepository: auth,
          profileRepository: profile,
          initialLocation: '/onboarding',
          size: const Size(360, 800),
          textScale: 1.3,
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('onboarding_name_field')),
          'Tasnim Akter',
        );
        await tester.ensureVisible(find.text('Save and continue'));
        await tester.tap(find.text('Save and continue'));
        await tester.pumpAndSettle();

        expectNoRenderOverflow(tester);
        expect(find.text('Offline'), findsOneWidget);
        expect(find.text('Tasnim Akter'), findsOneWidget);

        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Save and continue'));
        await tester.tap(find.text('Save and continue'));
        await tester.pumpAndSettle();
        expect(find.text('Your study dashboard'), findsOneWidget);
      },
    );
  });
}
