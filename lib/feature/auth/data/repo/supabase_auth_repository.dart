// AuthRepository implementation backed by Supabase Auth (PKCE).
// Normalizes emails, formats UTC ISO date_of_birth metadata, maps errors
// safely, and triggers local-safe SessionResetCoordinator cleanup on sign-out.
import 'supabase_auth_repository_imports.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({
    required this.remoteDataSource,
    this.sessionResetCoordinator,
    this.crashLogger,
  });

  static const String authCallbackRedirectUrl =
      'ai.actionboard.chapterno://auth-callback';

  final SupabaseAuthRemoteDataSource remoteDataSource;
  final SessionResetCoordinator? sessionResetCoordinator;
  final AppCrashLogger? crashLogger;

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  /// Formats [dateOfBirth] strictly as UTC calendar date `'YYYY-MM-DD'`
  /// without timezone day-shift.
  static String formatDateOfBirthIso(DateTime dateOfBirth) {
    final utcDate = DateTime.utc(
      dateOfBirth.year,
      dateOfBirth.month,
      dateOfBirth.day,
    );
    final year = utcDate.year.toString().padLeft(4, '0');
    final month = utcDate.month.toString().padLeft(2, '0');
    final day = utcDate.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  @override
  Future<Either<AuthFailure, AuthUser?>> restoreSession() async {
    try {
      final user =
          remoteDataSource.currentUser ?? remoteDataSource.currentSession?.user;
      if (user == null || user.id.isEmpty) {
        return const Right(null);
      }
      return Right(
        AuthUser(id: user.id, email: _normalizeEmail(user.email ?? '')),
      );
    } catch (error) {
      _recordFailure(stage: 'restore_session', error: error);
      return Left(AuthExceptionMapper.map(error));
    }
  }

  @override
  Future<Either<AuthFailure, AuthUser>> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    try {
      final response = await remoteDataSource.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );
      final user = response.user ?? response.session?.user;
      if (user == null || user.id.isEmpty) {
        return const Left(AuthFailure.unknown);
      }
      final resolvedEmail = _normalizeEmail(user.email ?? normalizedEmail);
      return Right(
        AuthUser(
          id: user.id,
          email: resolvedEmail.isEmpty ? normalizedEmail : resolvedEmail,
        ),
      );
    } catch (error) {
      _recordFailure(stage: 'sign_in', error: error);
      return Left(AuthExceptionMapper.map(error));
    }
  }

  @override
  Future<Either<AuthFailure, SignUpOutcome>> signUp({
    required String email,
    required String password,
    required DateTime dateOfBirth,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final dobIso = formatDateOfBirthIso(dateOfBirth);
    try {
      final response = await remoteDataSource.signUp(
        email: normalizedEmail,
        password: password,
        data: <String, dynamic>{'date_of_birth': dobIso},
        emailRedirectTo: authCallbackRedirectUrl,
      );
      final session = response.session;
      final user = response.user ?? session?.user;
      if (session != null && user != null && user.id.isNotEmpty) {
        final resolvedEmail = _normalizeEmail(user.email ?? normalizedEmail);
        return Right(
          SignUpOutcome.authenticated(
            AuthUser(
              id: user.id,
              email: resolvedEmail.isEmpty ? normalizedEmail : resolvedEmail,
            ),
          ),
        );
      }
      if (user != null && session == null) {
        return Right(SignUpOutcome.verificationRequired(normalizedEmail));
      }
      return const Left(AuthFailure.unknown);
    } catch (error) {
      _recordFailure(stage: 'sign_up', error: error);
      return Left(AuthExceptionMapper.map(error));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> sendPasswordReset({
    required String email,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    try {
      await remoteDataSource.resetPasswordForEmail(
        email: normalizedEmail,
        redirectTo: authCallbackRedirectUrl,
      );
      return const Right(unit);
    } catch (error) {
      _recordFailure(stage: 'send_password_reset', error: error);
      return Left(AuthExceptionMapper.map(error));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> signOut() async {
    // shortcut: a 5xx sign-out returns Left(unavailable) AFTER reset+navigate
    // already ran; callers may show a stale error. Known UX edge, revisit in M1.5.
    Object? signOutError;
    try {
      await remoteDataSource.signOut(scope: SignOutScope.local);
    } catch (error) {
      signOutError = error;
      _recordFailure(stage: 'sign_out', error: error);
    }

    await sessionResetCoordinator?.resetForSignOut();

    if (signOutError == null ||
        AuthExceptionMapper.isNetworkOrOffline(signOutError)) {
      return const Right(unit);
    }
    return Left(AuthExceptionMapper.map(signOutError));
  }

  void _recordFailure({required String stage, required Object error}) {
    crashLogger?.recordError(
      operation: 'auth',
      stage: stage,
      error: error,
      errorCode: AuthExceptionMapper.safeErrorCode(error),
    );
  }
}
