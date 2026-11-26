// Tier 1 isolated happy-path E2E tests covering AC-4 (Onboarding Submission,
// Board Picker Loading, Username Handle, and Mode Selector Exclusion).
import 'tier1_ac4_imports.dart';

void registerTier1Ac4Tests() {
  group('Tier 1 — AC-4: Onboarding Submission & Board Selection', () {
    testWidgets('T1-AC4-01 Science student onboarding submits and opens home', (
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
          onboarded: false,
        );
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: E2eRoutes.onboarding,
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('onboarding_name_field')),
        'Nusrat Jahan',
      );
      await tester.tap(find.textContaining('Chittagong'));
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();

      expect(find.text('Your study dashboard'), findsOneWidget);
      expect(profile.boardForUser('u1'), 'chittagong');
      final loaded = await profile.getProfile();
      loaded.fold((_) => fail('expected profile'), (p) {
        expect(p.fullName, 'Nusrat Jahan');
        expect(p.academicGroup, 'Science');
      });
    });

    testWidgets('T1-AC4-02 Business Studies & Intensive pace persist', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..seedUser(
          id: 'u2',
          email: 'u2@example.com',
          password: 'password1',
          signedIn: true,
        );
      final profile = FakeProfileRepository(authRepository: auth);
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: E2eRoutes.onboarding,
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('onboarding_name_field')),
        'Tariq Hasan',
      );
      await tester.tap(find.text('SSC 2028'));
      await tester.tap(find.text('Business Studies'));
      await tester.tap(find.text('Intensive'));
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();

      final loaded = await profile.getProfile();
      loaded.fold((_) => fail('expected profile'), (p) {
        expect(p.targetExam, 'SSC 2028');
        expect(p.academicGroup, 'Business Studies');
        expect(p.learningPace, 'Intensive');
      });
    });

    testWidgets('T1-AC4-03 optional privacy-safe username is persisted', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..seedUser(
          id: 'u3',
          email: 'u3@example.com',
          password: 'password1',
          signedIn: true,
        );
      final profile = FakeProfileRepository(authRepository: auth);
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: E2eRoutes.onboarding,
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('onboarding_name_field')),
        'Nusrat Jahan',
      );
      await tester.enterText(
        find.byKey(const Key('onboarding_username_field')),
        'nusrat_ssc27',
      );
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();

      expect(profile.usernameForUser('u3'), 'nusrat_ssc27');
    });

    testWidgets('T1-AC4-04 education boards load from curriculum service', (
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
        initialLocation: E2eRoutes.onboarding,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Dhaka'), findsOneWidget);
      expect(find.textContaining('Chittagong'), findsOneWidget);
      expect(find.textContaining('চট্টগ্রাম বোর্ড'), findsOneWidget);
    });

    testWidgets('T1-AC4-05 excludes Foundation vs Standard mode selector', (
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
        initialLocation: E2eRoutes.onboarding,
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Foundation'), findsNothing);
    });
  });
}
