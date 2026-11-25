// Verifies SessionResetCoordinator clears private user caches on sign-out
// and account switch, preserves them on tokenRefresh, and cancels on dispose.
import 'session_reset_coordinator_test_imports.dart';

Session _sessionFor(String userId) {
  return Session(
    accessToken: 'test-access-token',
    tokenType: 'bearer',
    user: User(
      id: userId,
      appMetadata: const <String, dynamic>{},
      userMetadata: null,
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00Z',
    ),
  );
}

void main() {
  group('SessionResetCoordinator', () {
    test('sign-out clears private user-cache callbacks and navigates, '
        'leaving public curriculum cache intact', () async {
      final authStream = StreamController<AuthState>();
      addTearDown(authStream.close);

      var profileCacheCleared = 0;
      var settingsCacheCleared = 0;
      final publicCurriculumCache = <String, String>{'physics': 'motion'};
      var signedOutNavigations = 0;

      final coordinator = SessionResetCoordinator(
        authStateChanges: authStream.stream,
        initialUserId: 'student-a',
        onSignedOutNavigate: () => signedOutNavigations++,
      );
      addTearDown(coordinator.dispose);

      coordinator.registerUserCacheReset(() {
        profileCacheCleared++;
      });
      coordinator.registerUserCacheReset(() async {
        settingsCacheCleared++;
      });

      authStream.add(const AuthState(AuthChangeEvent.signedOut, null));
      await pumpEventQueue();

      expect(profileCacheCleared, 1);
      expect(settingsCacheCleared, 1);
      expect(publicCurriculumCache, {'physics': 'motion'});
      expect(signedOutNavigations, 1);
      expect(coordinator.lastUserId, isNull);
    });

    test(
      'account switch (user A -> user B) clears private user-cache callbacks '
      'without triggering signed-out navigation',
      () async {
        final authStream = StreamController<AuthState>();
        addTearDown(authStream.close);

        var privateClears = 0;
        var signedOutNavigations = 0;

        final coordinator = SessionResetCoordinator(
          authStateChanges: authStream.stream,
          initialUserId: 'student-a',
          onSignedOutNavigate: () => signedOutNavigations++,
        );
        addTearDown(coordinator.dispose);

        coordinator.registerUserCacheReset(() {
          privateClears++;
        });

        authStream.add(
          AuthState(AuthChangeEvent.signedIn, _sessionFor('student-b')),
        );
        await pumpEventQueue();

        expect(privateClears, 1);
        expect(signedOutNavigations, 0);
        expect(coordinator.lastUserId, 'student-b');
      },
    );

    test(
      'same-user tokenRefresh and userUpdated do NOT wipe caches or navigate',
      () async {
        final authStream = StreamController<AuthState>();
        addTearDown(authStream.close);

        var privateClears = 0;
        var signedOutNavigations = 0;

        final coordinator = SessionResetCoordinator(
          authStateChanges: authStream.stream,
          initialUserId: 'student-a',
          onSignedOutNavigate: () => signedOutNavigations++,
        );
        addTearDown(coordinator.dispose);

        coordinator.registerUserCacheReset(() {
          privateClears++;
        });

        authStream.add(
          AuthState(AuthChangeEvent.tokenRefreshed, _sessionFor('student-a')),
        );
        authStream.add(
          AuthState(AuthChangeEvent.userUpdated, _sessionFor('student-a')),
        );
        await pumpEventQueue();

        expect(privateClears, 0);
        expect(signedOutNavigations, 0);
        expect(coordinator.lastUserId, 'student-a');
      },
    );

    test(
      'initial sign-in from signed-out state records userId without wiping',
      () async {
        final coordinator = SessionResetCoordinator();
        addTearDown(coordinator.dispose);

        var privateClears = 0;
        var signedOutNavigations = 0;
        coordinator.onSignedOutNavigate = () => signedOutNavigations++;
        coordinator.registerUserCacheReset(() => privateClears++);

        await coordinator.handleAuthStateChange(
          userId: null,
          isSignedOut: false,
        );
        expect(privateClears, 0);
        expect(signedOutNavigations, 0);

        await coordinator.handleAuthStateChange(
          userId: 'student-a',
          isSignedOut: false,
        );
        expect(privateClears, 0);
        expect(signedOutNavigations, 0);
        expect(coordinator.lastUserId, 'student-a');
      },
    );

    test(
      'failing reset callback does not block other callbacks or navigation',
      () async {
        final logs = <String>[];
        final logger = AppCrashLogger(debugSink: logs.add);
        var secondCleared = 0;
        var navigated = 0;

        final coordinator = SessionResetCoordinator(
          initialUserId: 'student-a',
          crashLogger: logger,
          onSignedOutNavigate: () => navigated++,
        );
        addTearDown(coordinator.dispose);

        coordinator.registerUserCacheReset(() {
          throw StateError('cache reset failed');
        });
        coordinator.registerUserCacheReset(() {
          secondCleared++;
        });

        await coordinator.resetForSignOut();

        expect(secondCleared, 1);
        expect(navigated, 1);
        expect(
          logger.recentEntries.map((e) => e.stage),
          contains('reset_callback'),
        );
      },
    );

    test('unregister disposer removes callback before sign-out', () async {
      final coordinator = SessionResetCoordinator(initialUserId: 'student-a');
      addTearDown(coordinator.dispose);

      var called = 0;
      final unregister = coordinator.registerUserCacheReset(() => called++);
      unregister();

      await coordinator.resetForSignOut();
      expect(called, 0);
    });

    test(
      'dispose cancels stream subscription and ignores subsequent events',
      () async {
        var streamCancelled = false;
        final authStream = StreamController<AuthState>(
          onCancel: () {
            streamCancelled = true;
          },
        );
        addTearDown(() async {
          if (!authStream.isClosed) {
            await authStream.close();
          }
        });

        var clears = 0;
        final coordinator = SessionResetCoordinator(
          authStateChanges: authStream.stream,
          initialUserId: 'student-a',
        );
        coordinator.registerUserCacheReset(() => clears++);

        expect(coordinator.hasActiveSubscription, isTrue);

        await coordinator.dispose();

        expect(streamCancelled, isTrue);
        expect(coordinator.hasActiveSubscription, isFalse);

        authStream.add(const AuthState(AuthChangeEvent.signedOut, null));
        await pumpEventQueue();
        expect(clears, 0);
      },
    );

    test(
      'serializes resetForSignOut and handleAuthStateChange behind in-flight stream resets',
      () async {
        final authStream = StreamController<AuthState>();
        addTearDown(authStream.close);

        final firstResetStarted = Completer<void>();
        final releaseFirstReset = Completer<void>();
        final trace = <String>[];
        var resetRun = 0;

        final coordinator = SessionResetCoordinator(
          authStateChanges: authStream.stream,
          initialUserId: 'student-a',
          onSignedOutNavigate: () => trace.add('navigate'),
        );
        addTearDown(coordinator.dispose);

        coordinator.registerUserCacheReset(() async {
          final run = ++resetRun;
          trace.add('start_$run');
          if (run == 1) {
            firstResetStarted.complete();
            await releaseFirstReset.future;
          }
          trace.add('end_$run');
        });

        authStream.add(
          AuthState(AuthChangeEvent.signedIn, _sessionFor('student-b')),
        );
        await firstResetStarted.future;

        final signOutFuture = coordinator.resetForSignOut();
        final authChangeFuture = coordinator.handleAuthStateChange(
          userId: 'student-c',
          isSignedOut: false,
        );
        await pumpEventQueue();

        expect(trace, ['start_1']);

        releaseFirstReset.complete();
        await Future.wait([signOutFuture, authChangeFuture]);

        expect(trace, ['start_1', 'end_1', 'start_2', 'end_2', 'navigate']);
        expect(coordinator.lastUserId, 'student-c');
      },
    );
  });
}
