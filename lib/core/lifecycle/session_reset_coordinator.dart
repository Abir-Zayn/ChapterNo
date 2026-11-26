// Coordinates private user-cache cleanup on sign-out or account switch.
// Preserves device-wide public curriculum caches across shared-device logins.
import 'session_reset_coordinator_imports.dart';

typedef UserCacheResetCallback = FutureOr<void> Function();

class SessionResetCoordinator {
  SessionResetCoordinator({
    Stream<AuthState>? authStateChanges,
    this.onSignedOutNavigate,
    this._crashLogger,
    String? initialUserId,
  }) : _lastUserId = initialUserId {
    if (authStateChanges != null) {
      attach(authStateChanges);
    }
  }

  final AppCrashLogger? _crashLogger;
  final List<UserCacheResetCallback> _resetCallbacks =
      <UserCacheResetCallback>[];

  VoidCallback? onSignedOutNavigate;
  StreamSubscription<AuthState>? _subscription;
  String? _lastUserId;
  bool _disposed = false;
  Future<void>? _pending;

  String? get lastUserId => _lastUserId;
  bool get hasActiveSubscription => _subscription != null;

  void attach(Stream<AuthState> authStateChanges) {
    if (_disposed) return;
    _subscription?.cancel();
    _subscription = authStateChanges.listen(
      (authState) {
        unawaited(
          handleAuthStateChange(
            userId: authState.session?.user.id,
            isSignedOut: authState.event == AuthChangeEvent.signedOut,
          ),
        );
      },
      onError: (Object error, StackTrace _) {
        _crashLogger?.recordError(
          operation: 'session_reset_coordinator',
          stage: 'auth_stream_error',
          error: error,
        );
      },
    );
  }

  VoidCallback registerUserCacheReset(UserCacheResetCallback callback) {
    if (_disposed) return () {};
    _resetCallbacks.add(callback);
    return () => _resetCallbacks.remove(callback);
  }

  void unregisterUserCacheReset(UserCacheResetCallback callback) {
    _resetCallbacks.remove(callback);
  }

  Future<void> handleAuthStateChange({
    required String? userId,
    required bool isSignedOut,
  }) {
    if (_disposed) return Future<void>.value();
    return _enqueue(
      () => _handleAuthStateChangeInternal(
        userId: userId,
        isSignedOut: isSignedOut,
      ),
    );
  }

  Future<void> _handleAuthStateChangeInternal({
    required String? userId,
    required bool isSignedOut,
  }) {
    if (_disposed) return Future<void>.value();
    if (isSignedOut) {
      // gotrue also emits signedOut on the auth stream; skip the second reset
      // when the direct resetForSignOut() call already cleared this session.
      if (_lastUserId == null) return Future<void>.value();
      return _performReset(nextUserId: null, shouldNavigate: true);
    }
    if (userId == null) {
      if (_lastUserId != null) {
        return _performReset(nextUserId: null, shouldNavigate: true);
      }
      return Future<void>.value();
    }
    if (_lastUserId != null && _lastUserId != userId) {
      return _performReset(nextUserId: userId, shouldNavigate: false);
    }
    _lastUserId = userId;
    return Future<void>.value();
  }

  Future<void> resetForSignOut() {
    if (_disposed || _lastUserId == null) return Future<void>.value();
    return _enqueue(
      () => _performReset(nextUserId: null, shouldNavigate: true),
    );
  }

  Future<void> _enqueue(Future<void> Function() task) {
    final base = _pending ?? Future<void>.value();
    late final Future<void> next;
    next = base
        .then((_) {
          if (_disposed) return Future<void>.value();
          return task();
        })
        .catchError((Object error) {
          _crashLogger?.recordError(
            operation: 'session_reset_coordinator',
            stage: 'queued_event',
            error: error,
          );
        })
        .whenComplete(() {
          if (identical(_pending, next)) {
            _pending = null;
          }
        });
    _pending = next;
    return next;
  }

  Future<void> _performReset({
    required String? nextUserId,
    required bool shouldNavigate,
  }) async {
    if (_disposed) return;
    _lastUserId = nextUserId;
    final callbacks = List<UserCacheResetCallback>.of(_resetCallbacks);
    for (final callback in callbacks) {
      if (_disposed) return;
      try {
        await callback();
      } catch (error) {
        _crashLogger?.recordError(
          operation: 'session_reset_coordinator',
          stage: 'reset_callback',
          error: error,
        );
      }
    }
    if (_disposed || !shouldNavigate) return;
    try {
      onSignedOutNavigate?.call();
    } catch (error) {
      _crashLogger?.recordError(
        operation: 'session_reset_coordinator',
        stage: 'navigate_signed_out',
        error: error,
      );
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    onSignedOutNavigate = null;
    _resetCallbacks.clear();
    await _subscription?.cancel();
    _subscription = null;
    final pending = _pending;
    if (pending != null) {
      await pending.catchError((Object _) {});
    }
  }
}
