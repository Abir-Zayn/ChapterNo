// Thin remote boundary wrapping Supabase GoTrueClient auth operations.
// Accepts an injected GoTrueClient or SupabaseClient so unit tests stay
// isolated from live Supabase networks and enforce consistent timeouts.
// shortcut: .timeout abandons the await, not the request; a slow sign-up can
// create the account after the UI reports network.
import 'supabase_auth_remote_data_source_imports.dart';

class SupabaseAuthRemoteDataSource {
  SupabaseAuthRemoteDataSource({
    GoTrueClient? authClient,
    SupabaseClient? supabaseClient,
    SupabaseClientProvider? clientProvider,
    this.requestTimeout = const Duration(seconds: 15),
  }) : _authClient = authClient ?? supabaseClient?.auth,
       _clientProvider = clientProvider ?? const SupabaseClientProvider();

  final GoTrueClient? _authClient;
  final SupabaseClientProvider _clientProvider;
  final Duration requestTimeout;

  GoTrueClient get _auth => _authClient ?? _clientProvider.client.auth;

  User? get currentUser => _auth.currentUser;

  Session? get currentSession => _auth.currentSession;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _auth
        .signInWithPassword(email: email, password: password)
        .timeout(requestTimeout);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> data,
    String? emailRedirectTo,
  }) {
    return _auth
        .signUp(
          email: email,
          password: password,
          data: data,
          emailRedirectTo: emailRedirectTo,
        )
        .timeout(requestTimeout);
  }

  Future<void> resetPasswordForEmail({
    required String email,
    String? redirectTo,
  }) {
    return _auth
        .resetPasswordForEmail(email, redirectTo: redirectTo)
        .timeout(requestTimeout);
  }

  Future<void> signOut({SignOutScope scope = SignOutScope.local}) {
    return _auth.signOut(scope: scope).timeout(requestTimeout);
  }
}
