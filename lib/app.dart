// Root widget: owns the router, lifecycle observer, post-frame warm-up,
// and theme mode. Supports constructor injection and AppDependencies.
import 'app_imports.dart';

class ChapterNoApp extends StatefulWidget {
  const ChapterNoApp({
    super.key,
    required this.authRepository,
    this.profileRepository,
    this.communityRepository,
    this.homeRepository,
    this.practiceRepository,
    this.subscriptionRepository,
    this.initialDarkMode = false,
    this.sessionResetCoordinator,
    this.onFlushPendingSettings,
    this.onWarmUp,
    this.onAppResumed,
    this.crashLogger,
  });

  factory ChapterNoApp.fromDependencies(
    AppDependencies dependencies, {
    Key? key,
  }) {
    return ChapterNoApp(
      key: key,
      authRepository: dependencies.authRepository,
      profileRepository: dependencies.profileRepository,
      communityRepository: dependencies.communityRepository,
      homeRepository: dependencies.homeRepository,
      practiceRepository: dependencies.practiceRepository,
      subscriptionRepository: dependencies.subscriptionRepository,
      initialDarkMode: dependencies.initialDarkMode,
      sessionResetCoordinator: dependencies.sessionResetCoordinator,
      onFlushPendingSettings: dependencies.onFlushPendingSettings,
      onWarmUp: dependencies.onWarmUp,
      onAppResumed: dependencies.onAppResumed,
      crashLogger: dependencies.crashLogger,
    );
  }

  final AuthRepository authRepository;
  final ProfileRepository? profileRepository;
  final CommunityRepository? communityRepository;
  final HomeRepository? homeRepository;
  final PracticeRepository? practiceRepository;
  final SubscriptionRepository? subscriptionRepository;
  final bool initialDarkMode;
  final SessionResetCoordinator? sessionResetCoordinator;
  final Future<void> Function()? onFlushPendingSettings;
  final Future<void> Function()? onWarmUp;
  final VoidCallback? onAppResumed;
  final AppCrashLogger? crashLogger;

  @override
  State<ChapterNoApp> createState() => _ChapterNoAppState();
}

class _ChapterNoAppState extends State<ChapterNoApp>
    with WidgetsBindingObserver {
  late final GoRouter _router = createAppRouter(
    authRepository: widget.authRepository,
    profileRepository: widget.profileRepository,
    communityRepository: widget.communityRepository,
    homeRepository: widget.homeRepository,
    practiceRepository: widget.practiceRepository,
    subscriptionRepository: widget.subscriptionRepository,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.sessionResetCoordinator?.onSignedOutNavigate = _handleSignedOut;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_runPostFrameWarmUp());
    });
  }

  @override
  void didUpdateWidget(covariant ChapterNoApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionResetCoordinator != widget.sessionResetCoordinator) {
      if (oldWidget.sessionResetCoordinator?.onSignedOutNavigate ==
          _handleSignedOut) {
        oldWidget.sessionResetCoordinator?.onSignedOutNavigate = null;
      }
      widget.sessionResetCoordinator?.onSignedOutNavigate = _handleSignedOut;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        unawaited(_flushPendingSettings());
      case AppLifecycleState.resumed:
        try {
          widget.onAppResumed?.call();
        } catch (error) {
          widget.crashLogger?.recordError(
            operation: 'app_lifecycle',
            stage: 'resumed',
            error: error,
          );
        }
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _handleSignedOut() {
    if (!mounted) return;
    _router.go(AppRoutes.welcome);
  }

  Future<void> _flushPendingSettings() async {
    final flush = widget.onFlushPendingSettings;
    if (flush == null) return;
    try {
      await flush();
    } catch (error) {
      widget.crashLogger?.recordError(
        operation: 'app_lifecycle',
        stage: 'flush_pending_settings',
        error: error,
      );
    }
  }

  Future<void> _runPostFrameWarmUp() async {
    final warmUp = widget.onWarmUp;
    if (warmUp == null) return;
    try {
      await warmUp();
    } catch (error) {
      widget.crashLogger?.recordError(
        operation: 'app_bootstrap',
        stage: 'post_frame_warm_up',
        error: error,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.sessionResetCoordinator?.onSignedOutNavigate ==
        _handleSignedOut) {
      widget.sessionResetCoordinator?.onSignedOutNavigate = null;
    }
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ChapterNo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: widget.initialDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router,
    );
  }
}
