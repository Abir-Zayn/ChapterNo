// Tier 2 boundary & negative E2E cases for AC-1 (Bootstrap/Theme/Lifecycle)
// and AC-2 (Auth Validation, Failure Retention, Duplicate Tap & DOB Bounds).
import 'tier2_ac1_ac2_imports.dart';

void registerTier2Ac1ToAc2Tests() {
  group('Tier 2 — AC-1: Bootstrap, Theme & Lifecycle Boundaries', () {
    test(
      'T2-AC1-01 Env.validate throws StateError when dart-defines absent',
      () {
        expect(Env.supabaseUrl, isEmpty);
        expect(Env.supabasePublishableKey, isEmpty);
        expect(() => Env.validate(), throwsStateError);
      },
    );

    testWidgets(
      'T2-AC1-02 rapid lifecycle cycling flushes only on background',
      (tester) async {
        final auth = FakeAuthRepository();
        final profile = FakeProfileRepository(authRepository: auth);
        addTearDown(auth.dispose);

        await pumpE2eApp(
          tester,
          authRepository: auth,
          profileRepository: profile,
          initialLocation: AppRoutes.welcome,
        );
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();
        expect(profile.flushCount, 3);
      },
    );

    testWidgets(
      'T2-AC1-03 corrupted local prefs fall back safely to defaults',
      (tester) async {
        final prefs = FakeAppPrefsStore()
          ..writeRawCorrupted(rawDarkMode: 'corrupt-value', rawLang: 'invalid');
        final auth = FakeAuthRepository(prefs: prefs);
        final profile = FakeProfileRepository(
          authRepository: auth,
          prefs: prefs,
        );
        addTearDown(auth.dispose);

        await pumpE2eApp(
          tester,
          authRepository: auth,
          profileRepository: profile,
          prefs: prefs,
        );
        final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(app.themeMode, ThemeMode.light);
        expect(prefs.language, AppLanguage.english);
        await tester.pumpAndSettle();
      },
    );

    test('T2-AC1-04 light and dark themes use opaque solid surfaces', () {
      final light = AppTheme.light();
      final dark = AppTheme.dark();
      expect(light.scaffoldBackgroundColor.a, 1.0);
      expect(light.colorScheme.surface.a, 1.0);
      expect(dark.scaffoldBackgroundColor.a, 1.0);
      expect(dark.colorScheme.surface.a, 1.0);
    });

    testWidgets(
      'T2-AC1-05 welcome renders at 360x800 1.3x scale without overflow',
      (tester) async {
        final auth = FakeAuthRepository();
        final profile = FakeProfileRepository(authRepository: auth);
        addTearDown(auth.dispose);

        await pumpE2eApp(
          tester,
          authRepository: auth,
          profileRepository: profile,
          initialLocation: AppRoutes.welcome,
          size: const Size(360, 800),
          textScale: 1.3,
        );
        await tester.pumpAndSettle();
        expectNoRenderOverflow(tester);
        expect(find.text('Sign up with email'), findsOneWidget);
      },
    );
  });

  group('Tier 2 — AC-2: Auth Validation, Failure Recovery & Concurrency', () {
    testWidgets('T2-AC2-01 invalid SignUp inputs block submission locally', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      final profile = FakeProfileRepository(authRepository: auth);
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: AppRoutes.signUp,
      );
      await enterAuthField(tester, 'Email', 'abc@');
      await enterAuthField(tester, 'Password', 'short');
      final btn = find.widgetWithText(FilledButton, 'Create account');
      await tester.ensureVisible(btn);
      await tester.tap(btn);
      await tester.pump();

      expect(find.text('Select your date of birth.'), findsOneWidget);
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Use at least 8 characters.'), findsOneWidget);
      expect(auth.signUpCalls, 0);
    });

    test('T2-AC2-02 future DOB is rejected by AuthValidators.dateOfBirth', () {
      final today = DateTime(2026, 11, 25);
      expect(
        AuthValidators.dateOfBirth(DateTime(2026, 11, 26), today: today),
        'Date of birth cannot be in the future.',
      );
      expect(AuthValidators.dateOfBirth(today, today: today), isNull);
    });

    testWidgets(
      'T2-AC2-03 duplicate email failure preserves entered sign-up form',
      (tester) async {
        final auth = FakeAuthRepository()
          ..seedUser(
            id: 'u1',
            email: 'taken@example.com',
            password: 'Password1',
          );
        final profile = FakeProfileRepository(authRepository: auth);
        addTearDown(auth.dispose);

        await pumpE2eApp(
          tester,
          authRepository: auth,
          profileRepository: profile,
          initialLocation: AppRoutes.signUp,
          today: DateTime(2026, 11, 25),
        );
        await pickDefaultDob(tester);
        await enterAuthField(tester, 'Email', 'taken@example.com');
        await enterAuthField(tester, 'Password', 'Password1');
        final btn = find.widgetWithText(FilledButton, 'Create account');
        await tester.ensureVisible(btn);
        await tester.tap(btn);
        await tester.pumpAndSettle();

        expect(
          find.textContaining('An account with this email already exists'),
          findsOneWidget,
        );
        expect(find.text('taken@example.com'), findsOneWidget);
        expect(find.text('Complete your profile'), findsNothing);
      },
    );

    testWidgets(
      'T2-AC2-04 invalid login keeps entered email and stays off home',
      (tester) async {
        final auth = FakeAuthRepository()
          ..seedUser(id: 'u1', email: 'u1@example.com', password: 'Password1');
        final profile = FakeProfileRepository(authRepository: auth);
        addTearDown(auth.dispose);

        await pumpE2eApp(
          tester,
          authRepository: auth,
          profileRepository: profile,
          initialLocation: AppRoutes.login,
        );
        await enterAuthField(tester, 'Email', 'u1@example.com');
        await enterAuthField(tester, 'Password', 'wrong-pass');
        await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Email or password is incorrect'),
          findsOneWidget,
        );
        expect(find.text('u1@example.com'), findsOneWidget);
        expect(find.text('Your study dashboard'), findsNothing);
      },
    );

    testWidgets('T2-AC2-05 duplicate tap while login is pending is ignored', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      final pending = Completer<Either<AuthFailure, AuthUser>>();
      auth.signInCompleter = pending;
      final profile = FakeProfileRepository(authRepository: auth);
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: AppRoutes.login,
      );
      await enterAuthField(tester, 'Email', 'u1@example.com');
      await enterAuthField(tester, 'Password', 'Password1');
      await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
      await tester.pump();

      final btn = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Log in'),
      );
      expect(btn.onPressed, isNull);
      await tester.tap(
        find.widgetWithText(FilledButton, 'Log in'),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(auth.signInCalls, 1);

      pending.complete(const Left(AuthFailure.network));
      await tester.pumpAndSettle();
      expect(find.textContaining('No internet connection'), findsOneWidget);
    });

    test(
      'T2-AC2-06 pre-1990 DOB fails the client check (DB CHECK floor 1990-01-01)',
      () {
        final today = DateTime(2026, 11, 25);
        expect(
          AuthValidators.dateOfBirth(DateTime(1989, 12, 31), today: today),
          'Date of birth must be on or after Jan 1, 1990.',
        );
      },
    );
  });
}
