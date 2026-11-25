// Tier 2 boundary & negative E2E cases for AC-4 (Onboarding Network Recovery,
// Display Name & Handle Limits, 360px/1.3x Scaling, and Bangla Unicode).
import 'tier2_ac4_imports.dart';

void registerTier2Ac4Tests() {
  group('Tier 2 — AC-4: Onboarding Form, Network Drop & 360px/Bangla', () {
    testWidgets('T2-AC4-01 mid-submit drop preserves selections and retries', (
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
        ..nextCompleteOnboardingFailure = const ProfileFailure('No internet');
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
      await tester.tap(find.text('Intensive'));
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();

      expect(find.text('No internet'), findsOneWidget);
      expect(find.text('Nusrat Jahan'), findsOneWidget);
      expect(find.text('Complete your profile'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Save and continue'));
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();
      expect(find.text('Your study dashboard'), findsOneWidget);
      expect(profile.boardForUser('u1'), 'chittagong');
    });

    test(
      'T2-AC4-02 display name length boundaries enforce 2..60 chars',
      () async {
        final auth = FakeAuthRepository()
          ..seedUser(
            id: 'u1',
            email: 'u1@example.com',
            password: 'password1',
            signedIn: true,
          );
        final profile = FakeProfileRepository(authRepository: auth);
        addTearDown(auth.dispose);

        for (final bad in ['   ', 'A', 'A' * 61]) {
          final res = await profile.completeOnboarding(
            displayName: bad,
            sscBatchYear: 'SSC 2027',
            boardId: 'dhaka',
            academicGroup: 'Science',
            learningPace: 'Standard',
          );
          expect(res.isLeft(), isTrue);
        }
        final ok = await profile.completeOnboarding(
          displayName: 'Ab',
          sscBatchYear: 'SSC 2027',
          boardId: 'dhaka',
          academicGroup: 'Science',
          learningPace: 'Standard',
        );
        expect(ok.isRight(), isTrue);
      },
    );

    testWidgets('T2-AC4-03 Bangla Unicode name and board render cleanly', (
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
      await tester.enterText(
        find.byKey(const Key('onboarding_name_field')),
        'নুসরাত জাহান',
      );
      await tester.tap(find.textContaining('চট্টগ্রাম বোর্ড'));
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();

      expectNoRenderOverflow(tester);
      final saved = await profile.getProfile();
      saved.fold((_) => fail('expected profile'), (p) {
        expect(p.fullName, 'নুসরাত জাহান');
      });
    });

    testWidgets(
      'T2-AC4-04 360px at 1.3x scale has zero overflow and >=48dp CTA',
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
          initialLocation: E2eRoutes.onboarding,
          size: const Size(360, 800),
          textScale: 1.3,
        );
        await tester.pumpAndSettle();
        expectNoRenderOverflow(tester);
        final ctaSize = tester.getSize(
          find.widgetWithText(FilledButton, 'Save and continue'),
        );
        expect(ctaSize.height, greaterThanOrEqualTo(48));
      },
    );

    testWidgets('T2-AC4-05 duplicate submit tap during Completer is ignored', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..seedUser(
          id: 'u1',
          email: 'u1@example.com',
          password: 'password1',
          signedIn: true,
        );
      final pending = Completer<Either<ProfileFailure, StudentProfile>>();
      final profile = FakeProfileRepository(authRepository: auth)
        ..completeOnboardingCompleter = pending;
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
      await tester.tap(find.text('Save and continue'));
      await tester.pump();
      await tester.tap(
        find.widgetWithText(FilledButton, 'Save and continue'),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(profile.completeOnboardingCalls, 1);
      pending.complete(const Left(ProfileFailure('Canceled')));
      await tester.pumpAndSettle();
    });

    test('T2-AC4-06 invalid username formats are rejected', () async {
      final auth = FakeAuthRepository()
        ..seedUser(
          id: 'u1',
          email: 'u1@example.com',
          password: 'password1',
          signedIn: true,
        );
      final profile = FakeProfileRepository(authRepository: auth);
      addTearDown(auth.dispose);

      for (final bad in const ['ab', 'bad handle', 'User@123']) {
        final res = await profile.completeOnboarding(
          displayName: 'Valid Name',
          sscBatchYear: 'SSC 2027',
          boardId: 'dhaka',
          academicGroup: 'Science',
          learningPace: 'Standard',
          username: bad,
        );
        expect(res.isLeft(), isTrue, reason: 'Should reject "$bad"');
      }
    });
  });
}
