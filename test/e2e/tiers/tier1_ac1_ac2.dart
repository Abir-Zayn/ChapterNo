// Tier 1 isolated happy-path E2E tests covering AC-1 (Bootstrap & Lifecycle)
// and AC-2 (Sign-Up, Normalization, Legal Documents, and Password Reset).
import 'tier1_ac1_ac2_imports.dart';

void registerTier1Ac1ToAc2Tests() {
  group('Tier 1 — AC-1: Cold-Start Bootstrap & Lifecycle Safety', () {
    testWidgets(
      'T1-AC1-01 cold launch with light preference paints light theme',
      (tester) async {
        final prefs = FakeAppPrefsStore()..darkModeEnabled = false;
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
        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.themeMode, ThemeMode.light);
        expect(materialApp.theme?.scaffoldBackgroundColor, AppColors.canvas);
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'T1-AC1-02 cold launch with dark preference paints dark theme',
      (tester) async {
        final prefs = FakeAppPrefsStore()..darkModeEnabled = true;
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
        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.themeMode, ThemeMode.dark);
        expect(
          materialApp.darkTheme?.scaffoldBackgroundColor,
          AppColors.canvasDark,
        );
        await tester.pumpAndSettle();
      },
    );

    testWidgets('T1-AC1-03 slow restoreSession does not block frame 1 splash', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      final pending = Completer<Either<AuthFailure, AuthUser?>>();
      auth.restoreCompleter = pending;
      final profile = FakeProfileRepository(authRepository: auth);
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
      );
      expect(find.text('ChapterNo'), findsOneWidget);
      expect(find.text('Master every chapter.'), findsOneWidget);

      pending.complete(const Right(null));
      await tester.pumpAndSettle();
      expect(find.text('Sign up with email'), findsOneWidget);
    });

    testWidgets('T1-AC1-04 lifecycle inactive and paused flush settings', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      final profile = FakeProfileRepository(authRepository: auth);
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: AppRoutes.welcome,
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(profile.flushCount, 2);
    });

    test('T1-AC1-05 Env contract and AppRoutes Step 1 paths are defined', () {
      expect(AppRoutes.splash, '/');
      expect(AppRoutes.welcome, '/welcome');
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.signUp, '/sign-up');
      expect(AppRoutes.forgotPassword, '/forgot-password');
      expect(AppRoutes.terms, '/terms');
      expect(AppRoutes.privacy, '/privacy');
      expect(AppRoutes.home, '/home');
      expect(AppRoutes.profile, '/profile');
      expect(AppRoutes.learningAnalytics, '/analytics');
      expect(AppRoutes.settings, '/settings');
      expect(() => Env.validate(), throwsStateError);
    });
  });

  group('Tier 1 — AC-2: Sign-Up, Normalization, Legal & Password Reset', () {
    testWidgets('T1-AC2-01 active-session sign-up routes to onboarding', (
      tester,
    ) async {
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
      await enterAuthField(tester, 'Email', 'nusrat@example.com');
      await enterAuthField(tester, 'Password', 'Secret123!');
      final btn = find.widgetWithText(FilledButton, 'Create account');
      await tester.ensureVisible(btn);
      await tester.tap(btn);
      await tester.pumpAndSettle();

      expect(find.text('Complete your profile'), findsOneWidget);
      expect(auth.currentUser?.email, 'nusrat@example.com');
    });

    testWidgets('T1-AC2-02 normalizes email and formats DOB as UTC ISO date', (
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
        today: DateTime(2026, 11, 25),
      );
      await pickDefaultDob(tester);
      await enterAuthField(tester, 'Email', '  Rafi.SSC@Example.COM  ');
      await enterAuthField(tester, 'Password', 'Secret123!');
      final btn = find.widgetWithText(FilledButton, 'Create account');
      await tester.ensureVisible(btn);
      await tester.tap(btn);
      await tester.pumpAndSettle();

      expect(auth.dobIsoByEmail['rafi.ssc@example.com'], '2011-11-25');
      expect(auth.currentUser?.email, 'rafi.ssc@example.com');
    });

    testWidgets('T1-AC2-03 legal documents open and return cleanly', (
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
      await enterAuthField(tester, 'Email', 'keep@example.com');
      final consent = tester.widget<RichText>(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('By signing'),
        ),
      );
      final taps = <TapGestureRecognizer>[];
      consent.text.visitChildren((span) {
        final r = span is TextSpan ? span.recognizer : null;
        if (r is TapGestureRecognizer) taps.add(r);
        return true;
      });
      expect(taps.length, 2);

      taps[0].onTap?.call();
      await tester.pumpAndSettle();
      expect(find.text('Terms of Service'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      taps[1].onTap?.call();
      await tester.pumpAndSettle();
      expect(find.text('Privacy Policy'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('keep@example.com'), findsOneWidget);
    });

    testWidgets('T1-AC2-04 forgot password sends reset and returns to login', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      final profile = FakeProfileRepository(authRepository: auth);
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: AppRoutes.welcome,
      );
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      await enterAuthField(tester, 'Email', ' Reset.User@Example.COM ');
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();

      expect(auth.sentResetEmails, ['reset.user@example.com']);
      expect(find.text('Check your email'), findsOneWidget);
      await tester.tap(find.text('Back to log in'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('T1-AC2-05 password field toggles visibility via tooltip', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      final profile = FakeProfileRepository(authRepository: auth);
      addTearDown(auth.dispose);

      await pumpE2eApp(
        tester,
        authRepository: auth,
        profileRepository: profile,
        initialLocation: AppRoutes.login,
      );
      final fieldBefore = tester.widget<TextField>(find.byType(TextField).last);
      expect(fieldBefore.obscureText, isTrue);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      final fieldAfter = tester.widget<TextField>(find.byType(TextField).last);
      expect(fieldAfter.obscureText, isFalse);
      expect(find.byTooltip('Hide password'), findsOneWidget);
    });
  });
}
