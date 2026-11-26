// Verifies sign-out dedupe: the direct resetForSignOut() call and gotrue's
// own signedOut stream event must clear caches and navigate only once.
import 'session_reset_coordinator_test_imports.dart';

void main() {
  group('SessionResetCoordinator sign-out dedupe', () {
    test(
      'repeated sign-out signals reset only once per signed-in session',
      () async {
        final authStream = StreamController<AuthState>();
        addTearDown(authStream.close);

        var clears = 0;
        var navigations = 0;

        final coordinator = SessionResetCoordinator(
          authStateChanges: authStream.stream,
          initialUserId: 'student-a',
          onSignedOutNavigate: () => navigations++,
        );
        addTearDown(coordinator.dispose);

        coordinator.registerUserCacheReset(() => clears++);

        // The repo calls resetForSignOut() AND gotrue emits signedOut on the
        // auth stream; the second signal must not clear or navigate again.
        await coordinator.resetForSignOut();
        authStream.add(const AuthState(AuthChangeEvent.signedOut, null));
        await pumpEventQueue();

        expect(clears, 1);
        expect(navigations, 1);
        expect(coordinator.lastUserId, isNull);
      },
    );

    test('sign-out with no signed-in user is a no-op', () async {
      final coordinator = SessionResetCoordinator(
        onSignedOutNavigate: () => fail('nothing to navigate from'),
      );
      addTearDown(coordinator.dispose);

      var clears = 0;
      coordinator.registerUserCacheReset(() => clears++);

      await coordinator.resetForSignOut();
      await coordinator.handleAuthStateChange(userId: null, isSignedOut: true);

      expect(clears, 0);
      expect(coordinator.lastUserId, isNull);
    });
  });
}
