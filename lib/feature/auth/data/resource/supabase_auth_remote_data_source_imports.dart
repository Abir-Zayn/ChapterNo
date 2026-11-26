// Exposes dependencies used by SupabaseAuthRemoteDataSource.
// Keeps Supabase SDK imports separate from the auth data-source boundary.
export 'package:supabase_flutter/supabase_flutter.dart'
    show
        AuthResponse,
        GoTrueClient,
        Session,
        SignOutScope,
        SupabaseClient,
        User;

export '../../../../core/supabase/supabase_client_provider.dart';
