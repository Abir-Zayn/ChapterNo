// Thin remote client for student_profiles, student_settings, and
// education_boards. The abstract seam keeps Postgrest chains out of tests.
// shortcut: SupabaseProfileRemoteClient has no unit mocks; verify it against
// a local Supabase test project before release.
import 'profile_remote_data_source_imports.dart';

abstract class ProfileRemoteClient {
  String? get currentUserId;
  String? get currentUserEmail;

  Future<Map<String, dynamic>?> fetchStudentProfile(String userId);
  Future<void> updateStudentProfile(String userId, Map<String, Object> values);
  Future<Map<String, dynamic>?> fetchStudentSettings(String userId);
  Future<void> upsertStudentSettings(Map<String, Object> values);
  Future<List<Map<String, dynamic>>> fetchEducationBoards();
}

class SupabaseProfileRemoteClient implements ProfileRemoteClient {
  SupabaseProfileRemoteClient({this._supabaseClient});

  static const Duration _requestTimeout = Duration(seconds: 15);

  final SupabaseClient? _supabaseClient;

  SupabaseClient get _client {
    final client = _supabaseClient;
    if (client == null) {
      throw StateError('Supabase client is not available.');
    }
    return client;
  }

  @override
  String? get currentUserId => _supabaseClient?.auth.currentUser?.id;

  @override
  String? get currentUserEmail => _supabaseClient?.auth.currentUser?.email;

  @override
  Future<Map<String, dynamic>?> fetchStudentProfile(String userId) {
    return _client
        .from('student_profiles')
        .select(
          'display_name, ssc_batch_year, board_id, academic_group, '
          'learning_pace, onboarding_completed_at',
        )
        .eq('user_id', userId)
        .maybeSingle()
        .timeout(_requestTimeout);
  }

  @override
  Future<void> updateStudentProfile(
    String userId,
    Map<String, Object> values,
  ) async {
    await _client
        .from('student_profiles')
        .update(values)
        .eq('user_id', userId)
        .timeout(_requestTimeout);
  }

  @override
  Future<Map<String, dynamic>?> fetchStudentSettings(String userId) {
    return _client
        .from('student_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle()
        .timeout(_requestTimeout);
  }

  @override
  Future<void> upsertStudentSettings(Map<String, Object> values) async {
    await _client
        .from('student_settings')
        .upsert(values)
        .timeout(_requestTimeout);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchEducationBoards() async {
    final rows = await _client
        .from('education_boards')
        .select('id, name_en')
        .eq('is_active', true)
        .order('sort_order')
        .timeout(_requestTimeout);
    return rows.cast<Map<String, dynamic>>();
  }
}
