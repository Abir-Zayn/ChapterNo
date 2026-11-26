// Unit tests for SupabaseAuthRemoteDataSource GoTrueClient delegation.
// Ensures timeouts, sign-out scope, and parameter forwarding work cleanly.
import 'supabase_auth_repository_test_imports.dart';

class _MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  const testUser = User(
    id: 'user-123',
    appMetadata: <String, dynamic>{},
    userMetadata: null,
    aud: 'authenticated',
    email: 'student@example.com',
    createdAt: '2026-11-26T00:00:00Z',
  );
  final testSession = Session(
    accessToken: 'test-access-token',
    tokenType: 'bearer',
    user: testUser,
  );

  late _MockGoTrueClient goTrue;
  late SupabaseAuthRemoteDataSource dataSource;

  setUpAll(() => registerFallbackValue(SignOutScope.local));

  setUp(() {
    goTrue = _MockGoTrueClient();
    dataSource = SupabaseAuthRemoteDataSource(authClient: goTrue);
  });

  test('exposes currentUser and currentSession from GoTrueClient', () {
    when(() => goTrue.currentUser).thenReturn(testUser);
    when(() => goTrue.currentSession).thenReturn(testSession);

    expect(dataSource.currentUser, testUser);
    expect(dataSource.currentSession, testSession);
  });

  test('delegates signInWithPassword, signUp, reset, and signOut', () async {
    final authResponse = AuthResponse(session: testSession, user: testUser);
    when(
      () => goTrue.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => authResponse);
    when(
      () => goTrue.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        data: any(named: 'data'),
        emailRedirectTo: any(named: 'emailRedirectTo'),
      ),
    ).thenAnswer((_) async => authResponse);
    when(
      () => goTrue.resetPasswordForEmail(
        any(),
        redirectTo: any(named: 'redirectTo'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => goTrue.signOut(scope: any(named: 'scope')),
    ).thenAnswer((_) async {});

    await dataSource.signInWithPassword(
      email: 'student@example.com',
      password: 'password123',
    );
    await dataSource.signUp(
      email: 'student@example.com',
      password: 'password123',
      data: const {'date_of_birth': '2010-05-01'},
      emailRedirectTo: 'ai.actionboard.chapterno://auth-callback',
    );
    await dataSource.resetPasswordForEmail(
      email: 'student@example.com',
      redirectTo: 'ai.actionboard.chapterno://auth-callback',
    );
    await dataSource.signOut();

    verify(
      () => goTrue.signInWithPassword(
        email: 'student@example.com',
        password: 'password123',
      ),
    ).called(1);
    verify(
      () => goTrue.signUp(
        email: 'student@example.com',
        password: 'password123',
        data: const {'date_of_birth': '2010-05-01'},
        emailRedirectTo: 'ai.actionboard.chapterno://auth-callback',
      ),
    ).called(1);
    verify(
      () => goTrue.resetPasswordForEmail(
        'student@example.com',
        redirectTo: 'ai.actionboard.chapterno://auth-callback',
      ),
    ).called(1);
    verify(() => goTrue.signOut(scope: SignOutScope.local)).called(1);
  });

  test('times out hanging GoTrue requests cleanly', () async {
    final shortTimeoutSource = SupabaseAuthRemoteDataSource(
      authClient: goTrue,
      requestTimeout: const Duration(milliseconds: 10),
    );
    when(
      () => goTrue.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return AuthResponse(session: testSession, user: testUser);
    });

    expect(
      () => shortTimeoutSource.signInWithPassword(
        email: 'student@example.com',
        password: 'password123',
      ),
      throwsA(isA<TimeoutException>()),
    );
  });
}
