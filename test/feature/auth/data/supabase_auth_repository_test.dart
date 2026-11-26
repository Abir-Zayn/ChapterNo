// Unit tests for SupabaseAuthRepository against an isolated remote double.
// Verifies session restore, normalized sign-in/up, UTC ISO DOB formatting,
// confirmation vs active-session sign-up, reset redirect, and local sign-out.
import 'supabase_auth_repository_test_imports.dart';

class _MockRemoteDataSource extends Mock
    implements SupabaseAuthRemoteDataSource {}

void main() {
  const testUser = User(
    id: 'user-123',
    appMetadata: <String, dynamic>{},
    userMetadata: null,
    aud: 'authenticated',
    email: 'Student@Example.com',
    createdAt: '2026-11-26T00:00:00Z',
  );
  final testSession = Session(
    accessToken: 'test-access-token',
    tokenType: 'bearer',
    user: testUser,
  );

  late _MockRemoteDataSource remote;
  late AppCrashLogger crashLogger;
  late List<String> loggedLines;
  late int resetCount;
  late int navCount;
  late SessionResetCoordinator coordinator;
  late SupabaseAuthRepository repository;

  setUpAll(() => registerFallbackValue(SignOutScope.local));

  setUp(() {
    remote = _MockRemoteDataSource();
    loggedLines = <String>[];
    crashLogger = AppCrashLogger(debugSink: loggedLines.add);
    resetCount = 0;
    navCount = 0;
    coordinator = SessionResetCoordinator(
      onSignedOutNavigate: () => navCount++,
      initialUserId: 'user-123',
    )..registerUserCacheReset(() => resetCount++);
    repository = SupabaseAuthRepository(
      remoteDataSource: remote,
      sessionResetCoordinator: coordinator,
      crashLogger: crashLogger,
    );
  });

  tearDown(() => coordinator.dispose());

  group('restoreSession', () {
    test('returns Right(null) when signed out', () async {
      when(() => remote.currentUser).thenReturn(null);
      when(() => remote.currentSession).thenReturn(null);

      expect(
        await repository.restoreSession(),
        const Right<AuthFailure, AuthUser?>(null),
      );
    });

    test('returns normalized AuthUser when session exists', () async {
      when(() => remote.currentUser).thenReturn(null);
      when(() => remote.currentSession).thenReturn(testSession);

      expect(
        await repository.restoreSession(),
        const Right<AuthFailure, AuthUser?>(
          AuthUser(id: 'user-123', email: 'student@example.com'),
        ),
      );
    });
  });

  group('signIn', () {
    test('trims and lowercases email and returns AuthUser', () async {
      when(
        () => remote.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => AuthResponse(session: testSession, user: testUser),
      );

      final result = await repository.signIn(
        email: '  Student@Example.com ',
        password: 'password123',
      );

      verify(
        () => remote.signInWithPassword(
          email: 'student@example.com',
          password: 'password123',
        ),
      ).called(1);
      expect(
        result,
        const Right<AuthFailure, AuthUser>(
          AuthUser(id: 'user-123', email: 'student@example.com'),
        ),
      );
    });

    test('maps errors cleanly and never logs email or raw message', () async {
      when(
        () => remote.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const AuthApiException(
          'Invalid credentials for student@example.com',
          code: 'invalid_credentials',
          statusCode: '400',
        ),
      );

      final result = await repository.signIn(
        email: 'student@example.com',
        password: 'wrong',
      );

      expect(
        result,
        const Left<AuthFailure, AuthUser>(AuthFailure.invalidCredentials),
      );
      expect(crashLogger.recentEntries.single.stage, 'sign_in');
      expect(crashLogger.recentEntries.single.errorCode, 'invalid_credentials');
      expect(loggedLines.join('\n'), isNot(contains('student@example.com')));
      expect(loggedLines.join('\n'), isNot(contains('Invalid credentials')));
    });
  });

  group('signUp', () {
    test('formats UTC ISO DOB and returns authenticated outcome', () async {
      when(
        () => remote.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
          emailRedirectTo: any(named: 'emailRedirectTo'),
        ),
      ).thenAnswer(
        (_) async => AuthResponse(session: testSession, user: testUser),
      );

      final result = await repository.signUp(
        email: '  Student@Example.com  ',
        password: 'password123',
        dateOfBirth: DateTime(2010, 5, 1),
      );

      final captured =
          verify(
                () => remote.signUp(
                  email: 'student@example.com',
                  password: 'password123',
                  data: captureAny(named: 'data'),
                  emailRedirectTo:
                      SupabaseAuthRepository.authCallbackRedirectUrl,
                ),
              ).captured.single
              as Map<String, dynamic>;

      expect(captured['date_of_birth'], '2010-05-01');
      expect(
        SupabaseAuthRepository.formatDateOfBirthIso(DateTime(1990, 1, 1)),
        '1990-01-01',
      );
      expect(
        result,
        Right<AuthFailure, SignUpOutcome>(
          SignUpOutcome.authenticated(
            const AuthUser(id: 'user-123', email: 'student@example.com'),
          ),
        ),
      );
    });

    test('returns verificationRequired when session is null', () async {
      when(
        () => remote.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
          emailRedirectTo: any(named: 'emailRedirectTo'),
        ),
      ).thenAnswer((_) async => AuthResponse(user: testUser));

      final result = await repository.signUp(
        email: ' Student@Example.com ',
        password: 'password123',
        dateOfBirth: DateTime(2010, 5, 1),
      );

      expect(
        result,
        const Right<AuthFailure, SignUpOutcome>(
          SignUpOutcome.verificationRequired('student@example.com'),
        ),
      );
    });
  });

  group('sendPasswordReset & signOut', () {
    test('normalizes email and passes PKCE redirectTo', () async {
      when(
        () => remote.resetPasswordForEmail(
          email: any(named: 'email'),
          redirectTo: any(named: 'redirectTo'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.sendPasswordReset(
        email: ' Student@Example.com ',
      );

      verify(
        () => remote.resetPasswordForEmail(
          email: 'student@example.com',
          redirectTo: SupabaseAuthRepository.authCallbackRedirectUrl,
        ),
      ).called(1);
      expect(result, const Right<AuthFailure, Unit>(unit));
    });

    test('signOut triggers local scope and SessionResetCoordinator', () async {
      when(
        () => remote.signOut(scope: any(named: 'scope')),
      ).thenAnswer((_) async {});

      final result = await repository.signOut();

      verify(() => remote.signOut(scope: SignOutScope.local)).called(1);
      expect(result, const Right<AuthFailure, Unit>(unit));
      expect(resetCount, 1);
      expect(navCount, 1);
    });

    test('offline signOut clears caches and returns Right(unit)', () async {
      when(
        () => remote.signOut(scope: any(named: 'scope')),
      ).thenThrow(const SocketException('Offline'));

      final result = await repository.signOut();

      expect(result, const Right<AuthFailure, Unit>(unit));
      expect(resetCount, 1);
      expect(navCount, 1);
    });

    test('non-network signOut failure still clears caches', () async {
      when(() => remote.signOut(scope: any(named: 'scope'))).thenThrow(
        AuthRetryableFetchException(message: 'Server error', statusCode: '503'),
      );

      final result = await repository.signOut();

      expect(result, const Left<AuthFailure, Unit>(AuthFailure.unavailable));
      expect(resetCount, 1);
      expect(navCount, 1);
    });
  });
}
