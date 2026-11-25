// Tier 2 boundary & negative E2E cases for AC-5 (Unranked Bounds, 360px/1.3x
// Scaling, Load/Save Error Recovery, Timeframe Switches, and Race Protection).
import 'tier2_ac5_imports.dart';

void registerTier2Ac5Tests() {
  group('Tier 2 — AC-5: Profile, Analytics & Settings Boundaries', () {
    testWidgets('T2-AC5-01 rank 0 and -1 display Unranked never Rank #0', (
      tester,
    ) async {
      for (final rank in [0, -1]) {
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
            leaderboardRank: rank,
          );
        addTearDown(auth.dispose);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        await pumpE2eApp(
          tester,
          authRepository: auth,
          profileRepository: profile,
          initialLocation: AppRoutes.profile,
        );
        await tester.pumpAndSettle();

        expect(find.text('Unranked'), findsOneWidget);
        expect(find.text('Rank #$rank'), findsNothing);
      }
    });

    testWidgets(
      'T2-AC5-02 Profile, Analytics, Settings fit 360px at 1.3x scale',
      (tester) async {
        for (final route in [
          AppRoutes.profile,
          AppRoutes.learningAnalytics,
          AppRoutes.settings,
        ]) {
          final auth = FakeAuthRepository()
            ..seedUser(
              id: 'u1',
              email: 'u1@example.com',
              password: 'password1',
              signedIn: true,
            );
          final profile = FakeProfileRepository(authRepository: auth);
          addTearDown(auth.dispose);

          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          await pumpE2eApp(
            tester,
            authRepository: auth,
            profileRepository: profile,
            initialLocation: route,
            size: const Size(360, 800),
            textScale: 1.3,
          );
          await tester.pumpAndSettle();
          expectNoRenderOverflow(tester);
        }
      },
    );

    testWidgets('T2-AC5-03 Profile initial load error recovers via Try again', (
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
        ..nextProfileFailure = const ProfileFailure('Server unreachable');
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: AppRoutes.profile,
      );
      await tester.pumpAndSettle();
      expect(find.text('Could not load profile'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Tier: Free'), findsOneWidget);
    });

    testWidgets(
      'T2-AC5-04 Settings update failure reverts toggle and shows error',
      (tester) async {
        final auth = FakeAuthRepository()
          ..seedUser(
            id: 'u1',
            email: 'u1@example.com',
            password: 'password1',
            signedIn: true,
          );
        final profile = FakeProfileRepository(authRepository: auth)
          ..nextUpdateSettingsFailure = const ProfileFailure('Save failed');
        addTearDown(auth.dispose);

        await pumpE2eApp(
          tester,
          authRepository: auth,
          profileRepository: profile,
          initialLocation: AppRoutes.settings,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Dark Mode'));
        await tester.pumpAndSettle();

        expect(find.text('Save failed'), findsOneWidget);
        expect(
          tester
              .widget<SwitchListTile>(
                find.widgetWithText(SwitchListTile, 'Dark Mode'),
              )
              .value,
          isFalse,
        );
      },
    );

    testWidgets(
      'T2-AC5-05 Analytics timeframe switch keeps honest zero stats',
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
          initialLocation: AppRoutes.learningAnalytics,
        );
        await tester.pumpAndSettle();

        for (final tf in AnalyticsTimeframe.values) {
          await tester.ensureVisible(find.text(tf.label));
          await tester.tap(find.text(tf.label));
          await tester.pumpAndSettle();
          expect(find.text('0 questions'), findsOneWidget);
          expect(find.text('Unranked'), findsOneWidget);
        }
      },
    );

    test(
      'T2-AC5-06 ProfileCubit ignores stale response after newer load',
      () async {
        final auth = FakeAuthRepository()
          ..seedUser(
            id: 'u1',
            email: 'u1@example.com',
            password: 'password1',
            signedIn: true,
          );
        final slow = Completer<Either<ProfileFailure, StudentProfile>>();
        final profile = FakeProfileRepository(authRepository: auth)
          ..seedUserProfile(
            userId: 'u1',
            email: 'u1@example.com',
            fullName: 'Fresh Name',
          )
          ..profileCompleter = slow;
        addTearDown(auth.dispose);

        final cubit = ProfileCubit(profileRepository: profile);
        addTearDown(cubit.close);

        final first = cubit.load();
        profile.profileCompleter = null;
        await cubit.load();
        slow.complete(
          const Right(
            StudentProfile(
              id: 'u1',
              fullName: 'Stale Name',
              initials: 'SN',
              email: 'u1@example.com',
              targetExam: 'SSC 2027',
              academicGroup: 'Science',
              learningPace: 'Standard',
              membershipTier: 'Free',
              mcqsSolved: 99,
              mcqsTodayDelta: 0,
              accuracyPercent: 99,
              accuracyDeltaPercent: 0,
              cqsPracticed: 0,
              streakDays: 0,
              communityPostsCount: 0,
              communityNotesCount: 0,
              leaderboardRank: 1,
              plannedStudyCount: 0,
            ),
          ),
        );
        await first;

        expect(cubit.state, isA<ProfileLoaded>());
        expect((cubit.state as ProfileLoaded).profile.fullName, 'Fresh Name');
      },
    );
  });
}
