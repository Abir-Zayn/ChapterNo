// Composition root for cold launch: installs global error handlers first,
// loads lightweight display prefs, validates env, initializes Supabase PKCE,
// and assembles immutable AppDependencies with two global error handlers.
import 'bootstrap_imports.dart';

class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.profileRepository,
    required this.homeRepository,
    required this.practiceRepository,
    required this.communityRepository,
    required this.subscriptionRepository,
    this.initialDarkMode = false,
    this.appLanguage = AppLanguage.english,
    this.sessionResetCoordinator,
    this.crashLogger,
    this.onFlushPendingSettings,
    this.onWarmUp,
    this.onAppResumed,
  });

  factory AppDependencies.inMemory({
    bool initialDarkMode = false,
    AppLanguage appLanguage = AppLanguage.english,
    SessionResetCoordinator? sessionResetCoordinator,
    AppCrashLogger? crashLogger,
    Future<void> Function()? onFlushPendingSettings,
    Future<void> Function()? onWarmUp,
    VoidCallback? onAppResumed,
  }) {
    return AppDependencies(
      authRepository: InMemoryAuthRepository(),
      profileRepository: InMemoryProfileRepository(),
      homeRepository: InMemoryHomeRepository(),
      practiceRepository: InMemoryPracticeRepository(),
      communityRepository: InMemoryCommunityRepository(),
      subscriptionRepository: InMemorySubscriptionRepository(),
      initialDarkMode: initialDarkMode,
      appLanguage: appLanguage,
      sessionResetCoordinator:
          sessionResetCoordinator ??
          SessionResetCoordinator(crashLogger: crashLogger),
      crashLogger: crashLogger,
      onFlushPendingSettings: onFlushPendingSettings,
      onWarmUp: onWarmUp,
      onAppResumed: onAppResumed,
    );
  }

  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final HomeRepository homeRepository;
  final PracticeRepository practiceRepository;
  final CommunityRepository communityRepository;
  final SubscriptionRepository subscriptionRepository;
  final bool initialDarkMode;
  final AppLanguage appLanguage;
  final SessionResetCoordinator? sessionResetCoordinator;
  final AppCrashLogger? crashLogger;
  final Future<void> Function()? onFlushPendingSettings;
  final Future<void> Function()? onWarmUp;
  final VoidCallback? onAppResumed;
}

typedef DependenciesBuilder =
    AppDependencies Function(
      StartupPreferencesSnapshot preferences,
      SessionResetCoordinator coordinator,
      AppCrashLogger crashLogger,
    );

void installGlobalErrorHandlers(AppCrashLogger logger) {
  FlutterError.onError = (FlutterErrorDetails details) {
    try {
      logger.recordFlutterError(details);
    } catch (_) {
      // Deliberate: never let an error handler throw into recursion.
    }
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    try {
      logger.recordError(
        operation: 'platform_dispatcher',
        stage: 'uncaught_async',
        error: error,
      );
    } catch (_) {
      // Deliberate: never let an error handler throw into recursion.
    }
    return true;
  };
}

Future<AppDependencies> bootstrap({
  AppCrashLogger? crashLogger,
  StartupPreferences? startupPreferences,
  SupabaseClientProvider? supabaseClientProvider,
  Future<void> Function()? initializeSupabase,
  bool Function()? isEnvConfigured,
  void Function()? validateEnv,
  bool requireEnv = true,
  bool installErrorHandlers = true,
  Future<void> Function()? onFlushPendingSettings,
  DependenciesBuilder? dependenciesBuilder,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = crashLogger ?? AppCrashLogger();
  if (installErrorHandlers) {
    installGlobalErrorHandlers(logger);
  }

  final preferences = startupPreferences ?? const StartupPreferences();
  final snapshot = await preferences.load(logger: logger);

  final clientProvider =
      supabaseClientProvider ?? const SupabaseClientProvider();
  final hasEnv =
      isEnvConfigured?.call() ??
      (Env.supabaseUrl.trim().isNotEmpty &&
          Env.supabasePublishableKey.trim().isNotEmpty);

  if (hasEnv || requireEnv) {
    (validateEnv ?? Env.validate)();
    if (!clientProvider.isAvailable) {
      await (initializeSupabase ?? _defaultInitializeSupabase)();
    }
  } else {
    logger.recordError(
      operation: 'bootstrap',
      stage: 'env_missing_in_memory_fallback',
    );
  }

  final client = clientProvider.clientOrNull;
  final coordinator = SessionResetCoordinator(
    authStateChanges: client?.auth.onAuthStateChange,
    initialUserId: client?.auth.currentUser?.id,
    crashLogger: logger,
  );

  if (dependenciesBuilder != null) {
    return dependenciesBuilder(snapshot, coordinator, logger);
  }

  return AppDependencies.inMemory(
    initialDarkMode: snapshot.initialDarkMode,
    appLanguage: snapshot.appLanguage,
    sessionResetCoordinator: coordinator,
    crashLogger: logger,
    onFlushPendingSettings: onFlushPendingSettings,
  );
}

Future<void> _defaultInitializeSupabase() {
  return Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    debug: false,
  );
}
