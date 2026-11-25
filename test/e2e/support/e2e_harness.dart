// Opaque-box E2E app shell mirroring Step 1 ChapterNoApp: sync frame-1 theme,
// WidgetsBindingObserver lifecycle flush, session-switch cache reset, and GoRouter.
// Wave 4 swaps E2eTestApp to ChapterNoApp once lib/app.dart compiles cleanly.
import 'e2e_harness_imports.dart';

class E2eRoutes {
  static const String onboarding = '/onboarding';
  static const String splashOffline = '/splash-offline';
}

class E2eTestApp extends StatefulWidget {
  const E2eTestApp({
    super.key,
    required this.authRepository,
    required this.profileRepository,
    this.curriculum,
    this.prefs,
    this.initialLocation = AppRoutes.splash,
    this.splashMinDisplay = Duration.zero,
    this.today,
    this.enforceOnboardingGate = true,
  });

  final FakeAuthRepository authRepository;
  final FakeProfileRepository profileRepository;
  final FakeCurriculumCatalogue? curriculum;
  final FakeAppPrefsStore? prefs;
  final String initialLocation;
  final Duration splashMinDisplay;
  final DateTime? today;
  final bool enforceOnboardingGate;

  @override
  State<E2eTestApp> createState() => _E2eTestAppState();
}

class _E2eTestAppState extends State<E2eTestApp> with WidgetsBindingObserver {
  late final ValueNotifier<ThemeMode> _themeMode;
  late final FakeCurriculumCatalogue _curriculum;
  late final GoRouter _router;
  StreamSubscription<String?>? _authSub;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _curriculum = widget.curriculum ?? FakeCurriculumCatalogue();
    final dark = widget.prefs?.darkModeEnabled ?? false;
    _themeMode = ValueNotifier(dark ? ThemeMode.dark : ThemeMode.light);
    _lastUserId = widget.authRepository.currentUser?.id;
    _authSub = widget.authRepository.authUserChanges.listen(_onAuthChange);
    _router = _createRouter();
  }

  void _onAuthChange(String? userId) {
    if (userId == null || (_lastUserId != null && _lastUserId != userId)) {
      unawaited(widget.profileRepository.clearCachedUserData());
    }
    _lastUserId = userId;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(widget.profileRepository.flushPendingSettings());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_authSub?.cancel());
    _themeMode.dispose();
    _router.dispose();
    super.dispose();
  }

  Future<void> _routeAfterAuth(BuildContext context) async {
    if (!widget.enforceOnboardingGate) {
      if (context.mounted) context.go(AppRoutes.home);
      return;
    }
    final status = await widget.profileRepository.isOnboardingComplete();
    if (!context.mounted) return;
    status.fold(
      (_) => context.go(E2eRoutes.splashOffline),
      (done) => context.go(done ? AppRoutes.home : E2eRoutes.onboarding),
    );
  }

  Future<void> _signOutAndReset(BuildContext context) async {
    final res = await widget.authRepository.signOut();
    if (!context.mounted) return;
    res.fold(
      (_) => AppSnackBar.show(
        context,
        'Could not sign out. Please try again.',
        type: AppSnackBarType.error,
      ),
      (_) async {
        await widget.profileRepository.clearCachedUserData();
        if (context.mounted) context.go(AppRoutes.welcome);
      },
    );
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: widget.initialLocation,
      overridePlatformDefaultLocation: true,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, _) => BlocProvider(
            create: (_) => SplashCubit(
              authRepository: widget.authRepository,
              minimumDisplay: widget.splashMinDisplay,
            )..start(),
            child: SplashPage(
              onSignedOut: () => context.go(AppRoutes.welcome),
              onSignedIn: () => _routeAfterAuth(context),
            ),
          ),
        ),
        GoRoute(
          path: E2eRoutes.splashOffline,
          builder: (context, _) => Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppStateView.offline(
                  title: 'Could not verify profile',
                  message: 'Check your connection and retry.',
                  onAction: () => _routeAfterAuth(context),
                ),
                AppButton(
                  label: 'Sign out',
                  variant: AppButtonVariant.outline,
                  onPressed: () => _signOutAndReset(context),
                ),
              ],
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (context, _) => WelcomePage(
            onContinueWithGoogle: () => AppSnackBar.show(
              context,
              'Google sign-in is not available yet.',
            ),
            onContinueWithApple: () => AppSnackBar.show(
              context,
              'Apple sign-in is not available yet.',
            ),
            onSignUpWithEmail: () => context.push(AppRoutes.signUp),
            onLogIn: () => context.push(AppRoutes.login),
            onOpenTerms: () => context.push(AppRoutes.terms),
            onOpenPrivacy: () => context.push(AppRoutes.privacy),
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, _) => BlocProvider(
            create: (_) => LoginCubit(authRepository: widget.authRepository),
            child: LoginPage(
              onLoggedIn: () => _routeAfterAuth(context),
              onForgotPassword: () => context.push(AppRoutes.forgotPassword),
              onSignUp: () => context.pushReplacement(AppRoutes.signUp),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.signUp,
          builder: (context, _) => BlocProvider(
            create: (_) => SignUpCubit(authRepository: widget.authRepository),
            child: SignUpPage(
              today: widget.today,
              onSignedUp: () => _routeAfterAuth(context),
              onLogIn: () => context.pushReplacement(AppRoutes.login),
              onOpenTerms: () => context.push(AppRoutes.terms),
              onOpenPrivacy: () => context.push(AppRoutes.privacy),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (context, _) => BlocProvider(
            create: (_) =>
                ForgotPasswordCubit(authRepository: widget.authRepository),
            child: ForgotPasswordPage(onBackToLogin: () => context.pop()),
          ),
        ),
        GoRoute(
          path: AppRoutes.terms,
          builder: (_, _) =>
              const LegalDocumentPage(document: LocalLegalDocuments.terms),
        ),
        GoRoute(
          path: AppRoutes.privacy,
          builder: (_, _) =>
              const LegalDocumentPage(document: LocalLegalDocuments.privacy),
        ),
        GoRoute(
          path: E2eRoutes.onboarding,
          builder: (context, _) => E2eOnboardingShellPage(
            profileRepository: widget.profileRepository,
            curriculum: _curriculum,
            onCompleted: () => context.go(AppRoutes.home),
          ),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, _) => E2eHomeShellPage(
            onOpenProfile: () => context.push(AppRoutes.profile),
            onOpenAnalytics: () => context.push(AppRoutes.learningAnalytics),
            onOpenSettings: () => context.push(AppRoutes.settings),
            onSignOut: () => _signOutAndReset(context),
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, _) => BlocProvider(
            create: (_) =>
                ProfileCubit(profileRepository: widget.profileRepository)
                  ..load(),
            child: E2eProfileShellPage(
              onOpenAnalytics: () => context.push(AppRoutes.learningAnalytics),
              onOpenSettings: () => context.push(AppRoutes.settings),
              onSignOut: () => _signOutAndReset(context),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.learningAnalytics,
          builder: (_, _) => BlocProvider(
            create: (_) => LearningAnalyticsCubit(
              profileRepository: widget.profileRepository,
            )..load(),
            child: const LearningAnalyticsPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, _) => BlocProvider(
            create: (_) => SettingsCubit(
              profileRepository: widget.profileRepository,
              authRepository: widget.authRepository,
            )..load(),
            child: E2eSettingsShellPage(
              onDarkModeChanged: (dark) {
                _themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
              },
              onSignedOut: () async {
                await widget.profileRepository.clearCachedUserData();
                if (context.mounted) context.go(AppRoutes.welcome);
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (_, mode, _) => MaterialApp.router(
        title: 'ChapterNo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        routerConfig: _router,
      ),
    );
  }
}
