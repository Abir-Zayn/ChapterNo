// Audits the Step 1 Supabase migration, config, and RLS verification matrix.
// Verifies schema tables, FK indexes, trigger hardening, grants, and policies.
import 'supabase_migration_rls_audit_test_imports.dart';

String _stripSqlCommentsAndNormalize(String raw) {
  final withoutLineComments = raw.replaceAll(
    RegExp(r'--.*$', multiLine: true),
    '',
  );
  return withoutLineComments
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();
}

List<String> _extractPolicies(String normalizedSql) {
  final matches = RegExp(r'create policy [^;]+;').allMatches(normalizedSql);
  return matches.map((m) => m.group(0)!).toList();
}

void main() {
  const migrationPath =
      'supabase/migrations/20261125000001_step1_student_profiles_and_curriculum.sql';
  const configPath = 'supabase/config.toml';
  const matrixPath = 'supabase/verification/rls_matrix.sql';

  late String rawMigration;
  late String sql;
  late List<String> policies;

  setUpAll(() {
    rawMigration = File(migrationPath).readAsStringSync();
    sql = _stripSqlCommentsAndNormalize(rawMigration);
    policies = _extractPolicies(sql);
  });

  test(
    'migration defines non-exposed private schema and hardened functions',
    () {
      expect(sql, contains('create schema if not exists private;'));
      expect(
        sql,
        contains(
          'revoke all on schema private from public, anon, authenticated;',
        ),
      );

      final setUpdatedAt = RegExp(
        r'create or replace function private\.set_updated_at\(\).*?\$\$;',
      ).stringMatch(sql);
      expect(setUpdatedAt, isNotNull);
      expect(setUpdatedAt, contains('security invoker'));
      expect(setUpdatedAt, contains("set search_path = ''"));

      final handleNewUser = RegExp(
        r'create or replace function private\.handle_new_auth_user\(\).*?\$\$;',
      ).stringMatch(sql);
      expect(handleNewUser, isNotNull);
      expect(handleNewUser, contains('security definer'));
      expect(handleNewUser, contains("set search_path = ''"));
      expect(
        handleNewUser,
        contains('exception when others then v_dob := null;'),
      );
      expect(handleNewUser, contains("date '1990-01-01'"));
      expect(handleNewUser, contains('current_date'));
      expect(handleNewUser, contains('on conflict (user_id) do nothing'));
      expect(handleNewUser, contains('public.student_profiles'));
      expect(handleNewUser, contains('public.student_settings'));
      expect(
        sql,
        contains(
          'revoke execute on function private.handle_new_auth_user() '
          'from public, anon, authenticated, service_role;',
        ),
      );
    },
  );

  test('migration creates all 6 tables, FK indexes, checks, and triggers', () {
    const tables = [
      'public.education_boards',
      'public.subjects',
      'public.chapters',
      'public.topics',
      'public.student_profiles',
      'public.student_settings',
    ];
    for (final table in tables) {
      expect(sql, contains('create table $table ('));
      expect(sql, contains('alter table $table enable row level security;'));
    }

    expect(
      sql,
      contains(
        'create index chapters_subject_id_idx on public.chapters (subject_id);',
      ),
    );
    expect(
      sql,
      contains(
        'create index topics_chapter_id_idx on public.topics (chapter_id);',
      ),
    );
    expect(
      sql,
      contains(
        'create index student_profiles_board_id_idx '
        'on public.student_profiles (board_id);',
      ),
    );
    expect(sql, contains('constraint onboarding_fields_complete_chk check'));
    expect(sql, contains('create trigger student_profiles_set_updated_at'));
    expect(sql, contains('create trigger student_settings_set_updated_at'));
    expect(sql, contains('create trigger on_auth_user_created'));
  });

  test(
    'migration enforces least-privilege grants with zero forbidden grants',
    () {
      expect(
        sql,
        contains(
          'revoke all on public.education_boards, public.subjects, '
          'public.chapters, public.topics from public, anon, authenticated;',
        ),
      );
      expect(
        sql,
        contains(
          'grant select on public.education_boards, public.subjects, '
          'public.chapters, public.topics to authenticated;',
        ),
      );
      expect(
        sql,
        contains(
          'revoke all on public.student_profiles, public.student_settings '
          'from public, anon, authenticated;',
        ),
      );
      expect(
        sql,
        contains(
          'grant select, insert, update on public.student_profiles, '
          'public.student_settings to authenticated;',
        ),
      );

      expect(RegExp(r'\bgrant\b[^;]*\bto\s+public\b').hasMatch(sql), isFalse);
      expect(RegExp(r'\bgrant\b[^;]*\bto\s+anon\b').hasMatch(sql), isFalse);
      expect(RegExp(r'\bgrant\b[^;]*\bservice_role\b').hasMatch(sql), isFalse);
      expect(RegExp(r'\bgrant\b[^;]*\bdelete\b').hasMatch(sql), isFalse);
    },
  );

  test(
    'all RLS policies enforce role targeting, InitPlan uid, and filters',
    () {
      expect(policies.length, 10);

      for (final policy in policies) {
        expect(policy, contains(' to authenticated '));
        expect(policy, isNot(contains(' to public ')));
        expect(policy, isNot(contains(' to anon ')));
        expect(policy, isNot(contains('auth.role(')));
        expect(policy, isNot(contains('user_metadata')));
        expect(policy, isNot(contains('raw_user_meta_data')));
      }

      final curriculumPolicies = policies.where(
        (p) =>
            p.contains(' on public.education_boards ') ||
            p.contains(' on public.subjects ') ||
            p.contains(' on public.chapters ') ||
            p.contains(' on public.topics '),
      );
      expect(curriculumPolicies.length, 4);
      for (final policy in curriculumPolicies) {
        expect(policy, contains(' for select to authenticated '));
        expect(policy, contains('is_active = true'));
      }

      final subjectsPolicy = policies.singleWhere(
        (p) => p.contains(' on public.subjects '),
      );
      expect(subjectsPolicy, contains("rights_status = 'cleared'"));

      final chaptersPolicy = policies.singleWhere(
        (p) => p.contains(' on public.chapters '),
      );
      expect(
        chaptersPolicy,
        contains('exists ( select 1 from public.subjects'),
      );

      final topicsPolicy = policies.singleWhere(
        (p) => p.contains(' on public.topics '),
      );
      expect(topicsPolicy, contains("rights_status = 'cleared'"));
      expect(topicsPolicy, contains('exists ( select 1 from public.chapters'));

      final studentPolicies = policies.where(
        (p) =>
            p.contains(' on public.student_profiles ') ||
            p.contains(' on public.student_settings '),
      );
      expect(studentPolicies.length, 6);
      for (final policy in studentPolicies) {
        expect(policy, contains('(select auth.uid()) = user_id'));
        final stripped = policy.replaceAll('(select auth.uid())', '');
        expect(stripped, isNot(contains('auth.uid()')));
        if (policy.contains(' for update ')) {
          expect(policy, contains(' using ((select auth.uid()) = user_id)'));
          expect(
            policy,
            contains(' with check ((select auth.uid()) = user_id)'),
          );
        }
      }
    },
  );

  test('config.toml and rls_matrix.sql satisfy pilot and S-1..S-9 specs', () {
    final config = File(configPath).readAsStringSync();
    expect(config, contains('enable_confirmations = false'));
    expect(config, contains('ai.actionboard.chapterno://auth-callback'));
    expect(config, contains('schemas = ["public"]'));

    final matrix = File(matrixPath).readAsStringSync();
    expect(matrix.toLowerCase(), contains('begin;'));
    expect(matrix.toLowerCase(), contains('rollback;'));
    for (var i = 1; i <= 9; i++) {
      expect(matrix, contains('S-$i'));
    }
  });
}
