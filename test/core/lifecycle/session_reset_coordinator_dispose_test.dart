// Verifies SessionResetCoordinator.dispose awaits an in-flight reset callback
// while skipping subsequent queued resets and signed-out navigation.
import 'session_reset_coordinator_dispose_test_imports.dart';

void main() {
  group('SessionResetCoordinator.dispose', () {
    test(
      'awaits in-flight reset callback while suppressing queued callbacks and navigation',
      () async {
        final firstStarted = Completer<void>();
        final releaseFirst = Completer<void>();
        var firstFinished = false;
        var secondCallbackCalled = false;
        var queuedResetCalled = false;
        var navigated = 0;

        final coordinator = SessionResetCoordinator(
          initialUserId: 'student-a',
          onSignedOutNavigate: () => navigated++,
        );

        coordinator.registerUserCacheReset(() async {
          firstStarted.complete();
          await releaseFirst.future;
          firstFinished = true;
        });
        coordinator.registerUserCacheReset(() {
          secondCallbackCalled = true;
        });

        final inFlightReset = coordinator.resetForSignOut();
        await firstStarted.future;

        final queuedReset = coordinator.handleAuthStateChange(
          userId: 'student-b',
          isSignedOut: false,
        );
        coordinator.registerUserCacheReset(() {
          queuedResetCalled = true;
        });

        var disposeResolved = false;
        final disposeFuture = coordinator.dispose().then((_) {
          disposeResolved = true;
        });
        await pumpEventQueue();

        expect(disposeResolved, isFalse);
        expect(firstFinished, isFalse);

        releaseFirst.complete();
        await disposeFuture;
        await Future.wait([inFlightReset, queuedReset]);

        expect(disposeResolved, isTrue);
        expect(firstFinished, isTrue);
        expect(secondCallbackCalled, isFalse);
        expect(queuedResetCalled, isFalse);
        expect(navigated, 0);
      },
    );

    test(
      'awaits in-flight failing callback cleanly without throwing from dispose',
      () async {
        final started = Completer<void>();
        final release = Completer<void>();
        final coordinator = SessionResetCoordinator(initialUserId: 'student-a');

        coordinator.registerUserCacheReset(() async {
          started.complete();
          await release.future;
          throw StateError('in-flight failure');
        });

        final inFlight = coordinator.resetForSignOut();
        await started.future;

        var disposed = false;
        final disposeFuture = coordinator.dispose().then((_) {
          disposed = true;
        });
        await pumpEventQueue();
        expect(disposed, isFalse);

        release.complete();
        await expectLater(disposeFuture, completes);
        await inFlight;
        expect(disposed, isTrue);
      },
    );
  });
}
