// Verifies cold-launch bootstrap ordering, global error handlers, startup
// preferences fallback, and SupabaseClientProvider testability.
import 'bootstrap_test_imports.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('bootstrap', () {
    test(
      'installs global error handlers before validateEnv and Supabase init',
      () async {
        final previousFlutterOnError = FlutterError.onError;
        final previousPlatformOnError = PlatformDispatcher.instance.onError;
        addTearDown(() {
          FlutterError.onError = previousFlutterOnError;
          PlatformDispatcher.instance.onError = previousPlatformOnError;
        });

        SharedPreferences.setMockInitialValues(<String, Object>{
          StartupPreferences.darkModeKey: true,
          StartupPreferences.appLanguageKey: AppLanguage.bangla.name,
        });

        final events = <String>[];
        final logs = <String>[];
        final logger = AppCrashLogger(debugSink: logs.add);

        final deps = await bootstrap(
          crashLogger: logger,
          supabaseClientProvider: SupabaseClientProvider(
            isInitializedCheck: () => false,
          ),
          isEnvConfigured: () => true,
          validateEnv: () {
            expect(FlutterError.onError, isNot(same(previousFlutterOnError)));
            expect(
              PlatformDispatcher.instance.onError,
              isNot(same(previousPlatformOnError)),
            );
            events.add('validateEnv');
          },
          initializeSupabase: () async {
            events.add('initializeSupabase');
          },
        );
        addTearDown(() => deps.sessionResetCoordinator?.dispose());

        expect(events, ['validateEnv', 'initializeSupabase']);
        expect(deps.initialDarkMode, isTrue);
        expect(deps.appLanguage, AppLanguage.bangla);
        expect(deps.sessionResetCoordinator, isNotNull);
      },
    );

    test(
      'PlatformDispatcher.onError returns true unconditionally and does not throw',
      () {
        final previousFlutterOnError = FlutterError.onError;
        final previousPlatformOnError = PlatformDispatcher.instance.onError;
        addTearDown(() {
          FlutterError.onError = previousFlutterOnError;
          PlatformDispatcher.instance.onError = previousPlatformOnError;
        });

        final throwingLogger = AppCrashLogger(
          debugSink: (_) => throw StateError('broken sink'),
        );
        installGlobalErrorHandlers(throwingLogger);

        final handled = PlatformDispatcher.instance.onError!(
          StateError('sensitive user@example.com'),
          StackTrace.current,
        );
        expect(handled, isTrue);
      },
    );

    test(
      'skips initializeSupabase when SupabaseClientProvider is already available',
      () async {
        final previousFlutterOnError = FlutterError.onError;
        final previousPlatformOnError = PlatformDispatcher.instance.onError;
        addTearDown(() {
          FlutterError.onError = previousFlutterOnError;
          PlatformDispatcher.instance.onError = previousPlatformOnError;
        });

        SharedPreferences.setMockInitialValues(<String, Object>{});
        var initCalls = 0;
        final mockClient = _MockSupabaseClient();
        final mockAuth = _MockGoTrueClient();
        when(() => mockClient.auth).thenReturn(mockAuth);
        when(
          () => mockAuth.onAuthStateChange,
        ).thenAnswer((_) => const Stream<AuthState>.empty());
        when(() => mockAuth.currentUser).thenReturn(null);

        final deps = await bootstrap(
          crashLogger: AppCrashLogger(debugSink: (_) {}),
          supabaseClientProvider: SupabaseClientProvider(
            clientOverride: mockClient,
          ),
          isEnvConfigured: () => true,
          validateEnv: () {},
          initializeSupabase: () async {
            initCalls++;
          },
        );
        addTearDown(() => deps.sessionResetCoordinator?.dispose());

        expect(initCalls, 0);
      },
    );

    test(
      'fails fast with StateError by default when env keys are missing',
      () async {
        final previousFlutterOnError = FlutterError.onError;
        final previousPlatformOnError = PlatformDispatcher.instance.onError;
        addTearDown(() {
          FlutterError.onError = previousFlutterOnError;
          PlatformDispatcher.instance.onError = previousPlatformOnError;
        });

        SharedPreferences.setMockInitialValues(<String, Object>{});
        final logger = AppCrashLogger(debugSink: (_) {});

        await expectLater(
          bootstrap(crashLogger: logger, isEnvConfigured: () => false),
          throwsStateError,
        );
        expect(FlutterError.onError, isNot(same(previousFlutterOnError)));
        expect(
          PlatformDispatcher.instance.onError,
          isNot(same(previousPlatformOnError)),
        );
      },
    );

    test(
      'falls back to in-memory dependencies only when requireEnv is false',
      () async {
        final previousFlutterOnError = FlutterError.onError;
        final previousPlatformOnError = PlatformDispatcher.instance.onError;
        addTearDown(() {
          FlutterError.onError = previousFlutterOnError;
          PlatformDispatcher.instance.onError = previousPlatformOnError;
        });

        final logger = AppCrashLogger(debugSink: (_) {});
        final deps = await bootstrap(
          crashLogger: logger,
          startupPreferences: StartupPreferences(
            prefsLoader: () async => throw StateError('storage unavailable'),
          ),
          isEnvConfigured: () => false,
          requireEnv: false,
        );
        addTearDown(() => deps.sessionResetCoordinator?.dispose());

        expect(deps.initialDarkMode, isFalse);
        expect(deps.appLanguage, AppLanguage.english);
        expect(
          logger.recentEntries.map((e) => e.stage),
          containsAll(['load', 'env_missing_in_memory_fallback']),
        );
      },
    );

    testWidgets(
      'pausing app does not overwrite mid-session preferences with cold-launch snapshot',
      (tester) async {
        final previousFlutterOnError = FlutterError.onError;
        final previousPlatformOnError = PlatformDispatcher.instance.onError;
        addTearDown(() {
          FlutterError.onError = previousFlutterOnError;
          PlatformDispatcher.instance.onError = previousPlatformOnError;
        });

        SharedPreferences.setMockInitialValues(<String, Object>{
          StartupPreferences.darkModeKey: false,
          StartupPreferences.appLanguageKey: AppLanguage.english.name,
        });
        const prefs = StartupPreferences();
        final deps = await bootstrap(
          crashLogger: AppCrashLogger(debugSink: (_) {}),
          startupPreferences: prefs,
          isEnvConfigured: () => false,
          requireEnv: false,
        );
        addTearDown(() => deps.sessionResetCoordinator?.dispose());

        await tester.pumpWidget(ChapterNoApp.fromDependencies(deps));
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        await prefs.save(
          darkModeEnabled: true,
          appLanguage: AppLanguage.bangla,
        );

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();

        final reloaded = await prefs.load();
        expect(reloaded.initialDarkMode, isTrue);
        expect(reloaded.appLanguage, AppLanguage.bangla);
      },
    );
  });

  group('StartupPreferences', () {
    test('save and load round-trip darkModeEnabled and appLanguage', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const prefs = StartupPreferences();

      await prefs.save(darkModeEnabled: true, appLanguage: AppLanguage.bangla);
      final loaded = await prefs.load();

      expect(loaded.initialDarkMode, isTrue);
      expect(loaded.appLanguage, AppLanguage.bangla);
    });
  });

  group('SupabaseClientProvider', () {
    test(
      'throws StateError when uninitialized and returns override when set',
      () {
        const uninitialized = SupabaseClientProvider();
        expect(uninitialized.isAvailable, isFalse);
        expect(uninitialized.clientOrNull, isNull);
        expect(() => uninitialized.client, throwsStateError);

        final mockClient = _MockSupabaseClient();
        final overridden = SupabaseClientProvider(clientOverride: mockClient);
        expect(overridden.isAvailable, isTrue);
        expect(overridden.clientOrNull, same(mockClient));
        expect(overridden.client, same(mockClient));
      },
    );
  });
}
