-- Live Supabase RLS & Security Verification Matrix (S-1 through S-9)
-- Refs: docs/step-1-foundation/05_ACCEPTANCE_CRITERIA_AND_VERIFICATION.md §2
-- Run via: supabase db query < supabase/verification/rls_matrix.sql (or psql)
-- Wrapped in BEGIN ... ROLLBACK so synthetic test fixtures never persist.

begin;

-- ============================================================================
-- Fixture Setup (runs as migration/superuser before switching to anon / users)
-- ============================================================================
do $$
declare
  v_student_a uuid := '11111111-1111-4111-8111-111111111111';
  v_student_b uuid := '22222222-2222-4222-8222-222222222222';
  v_student_oob_dob uuid := '33333333-3333-4333-8333-333333333333';
  v_board_id bigint;
  v_cleared_subject_id bigint;
  v_draft_subject_id bigint;
  v_inactive_subject_id bigint;
  v_cleared_chapter_id bigint;
  v_draft_parent_chapter_id bigint;
  v_dob_stored date;
begin
  -- Create synthetic auth.users rows (triggers private.handle_new_auth_user)
  insert into auth.users (
    id, instance_id, aud, role, email, encrypted_password,
    email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at
  ) values
  (
    v_student_a, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
    'rls_student_a@example.test', 'hash', now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"date_of_birth":"2010-05-15"}'::jsonb,
    now(), now()
  ),
  (
    v_student_b, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
    'rls_student_b@example.test', 'hash', now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"date_of_birth":"2010-06-20"}'::jsonb,
    now(), now()
  ),
  (
    v_student_oob_dob, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
    'rls_student_oob_dob@example.test', 'hash', now(),
    '{"provider":"email","providers":["email"]}'::jsonb,
    '{"date_of_birth":"1800-01-01"}'::jsonb,
    now(), now()
  );

  -- Verify trigger provisioned profiles & clamped out-of-range DOB to null (no 23514)
  select date_of_birth into v_dob_stored
  from public.student_profiles
  where user_id = v_student_oob_dob;

  if not found or v_dob_stored is not null then
    raise exception 'Trigger DOB clamp check failed for out-of-range metadata DOB';
  end if;

  update public.student_profiles
  set display_name = 'Student A'
  where user_id = v_student_a;

  update public.student_profiles
  set display_name = 'Student B Original'
  where user_id = v_student_b;

  -- Deterministic curriculum fixtures (cleared vs inactive vs internal_draft)
  insert into public.education_boards (code, name_en, name_bn, sort_order, is_active)
  values ('rls_test_board', 'RLS Test Board', 'টেস্ট বোর্ড', 99, true)
  returning id into v_board_id;

  insert into public.subjects (
    code, academic_group, title_en, title_bn, syllabus_version,
    rights_status, sort_order, is_active
  ) values (
    'rls_cleared_subj', 'science', 'RLS Cleared Physics', 'পদার্থবিজ্ঞান',
    'NCTB-SSC-2026', 'cleared', 1, true
  ) returning id into v_cleared_subject_id;

  insert into public.subjects (
    code, academic_group, title_en, title_bn, syllabus_version,
    rights_status, sort_order, is_active
  ) values (
    'rls_draft_subj', 'science', 'RLS Draft Subject', 'খসড়া বিষয়',
    'NCTB-SSC-2026', 'internal_draft', 2, true
  ) returning id into v_draft_subject_id;

  insert into public.subjects (
    code, academic_group, title_en, title_bn, syllabus_version,
    rights_status, sort_order, is_active
  ) values (
    'rls_inactive_subj', 'science', 'RLS Inactive Subject', 'নিষ্ক্রিয় বিষয়',
    'NCTB-SSC-2026', 'cleared', 3, false
  ) returning id into v_inactive_subject_id;

  insert into public.chapters (subject_id, chapter_number, title_en, title_bn, is_active)
  values (v_cleared_subject_id, 1, 'Cleared Chapter', 'অধ্যায় ১', true)
  returning id into v_cleared_chapter_id;

  insert into public.chapters (subject_id, chapter_number, title_en, title_bn, is_active)
  values (v_draft_subject_id, 1, 'Draft Parent Chapter', 'খসড়া অধ্যায়', true)
  returning id into v_draft_parent_chapter_id;

  insert into public.topics (
    chapter_id, topic_number, title_en, title_bn, rights_status, is_active
  ) values
  (v_cleared_chapter_id, 1, 'Cleared Topic', 'টপিক ১', 'cleared', true),
  (v_cleared_chapter_id, 2, 'Draft Topic', 'খসড়া টপিক', 'internal_draft', true),
  (v_cleared_chapter_id, 3, 'Inactive Topic', 'নিষ্ক্রিয় টপিক', 'cleared', false),
  (v_draft_parent_chapter_id, 1, 'Child of Draft Subject', 'অপ্রকাশিত টপিক', 'cleared', true);
end $$;

-- ============================================================================
-- S-1: anon (unauthenticated) SELECT denied on all exposed tables
-- ============================================================================
set local role anon;

do $$
declare
  v_table text;
  v_tables text[] := array[
    'public.student_profiles',
    'public.student_settings',
    'public.education_boards',
    'public.subjects',
    'public.chapters',
    'public.topics'
  ];
  v_dummy int;
begin
  foreach v_table in array v_tables loop
    begin
      execute format('select 1 from %s limit 1', v_table) into v_dummy;
      raise exception 'S-1 FAILED: anon was allowed to SELECT from %', v_table;
    exception
      when insufficient_privilege then
        null; -- Expected 42501
    end;
  end loop;
  raise notice 'S-1 PASSED: anon SELECT denied on all 6 tables.';
end $$;

reset role;

-- ============================================================================
-- S-2, S-3, S-4, S-5, S-6, S-7: Student A (authenticated) isolation & grants
-- ============================================================================
set local role authenticated;
select set_config('request.jwt.claim.sub', '11111111-1111-4111-8111-111111111111', true);
select set_config(
  'request.jwt.claims',
  '{"sub":"11111111-1111-4111-8111-111111111111","role":"authenticated"}',
  true
);

do $$
declare
  v_student_a uuid := '11111111-1111-4111-8111-111111111111';
  v_student_b uuid := '22222222-2222-4222-8222-222222222222';
  v_profile_count int;
  v_settings_count int;
  v_other_count int;
  v_rows_affected int;
  v_hidden_count int;
  v_visible_count int;
begin
  -- S-2: Student A SELECT without WHERE returns only Student A's row (1 row, 0 from B)
  select count(*) into v_profile_count from public.student_profiles;
  select count(*) into v_other_count from public.student_profiles where user_id <> v_student_a;
  if v_profile_count <> 1 or v_other_count <> 0 then
    raise exception 'S-2 FAILED (student_profiles): count=%, other=%', v_profile_count, v_other_count;
  end if;

  select count(*) into v_settings_count from public.student_settings;
  select count(*) into v_other_count from public.student_settings where user_id <> v_student_a;
  if v_settings_count <> 1 or v_other_count <> 0 then
    raise exception 'S-2 FAILED (student_settings): count=%, other=%', v_settings_count, v_other_count;
  end if;
  raise notice 'S-2 PASSED: Student A sees strictly 1 own row and 0 Student B rows.';

  -- S-3: Cross-user UPDATE affects 0 rows (blocked by USING)
  update public.student_profiles
  set display_name = 'Hacked'
  where user_id = v_student_b;
  get diagnostics v_rows_affected = row_count;
  if v_rows_affected <> 0 then
    raise exception 'S-3 FAILED: cross-user UPDATE affected % rows', v_rows_affected;
  end if;
  raise notice 'S-3 PASSED: Student A cross-user UPDATE affected 0 rows.';

  -- S-4: Ownership tampering UPDATE rejected with 42501 (WITH CHECK)
  begin
    update public.student_profiles
    set user_id = v_student_b
    where user_id = v_student_a;
    raise exception 'S-4 FAILED: user_id reassignment was not rejected by WITH CHECK';
  exception
    when insufficient_privilege then
      null; -- Expected 42501
  end;
  raise notice 'S-4 PASSED: Student A ownership reassignment rejected (42501).';

  -- S-5: DELETE on student_profiles and student_settings denied
  begin
    delete from public.student_profiles where user_id = v_student_a;
    raise exception 'S-5 FAILED: DELETE on student_profiles was allowed';
  exception
    when insufficient_privilege then
      null;
  end;
  begin
    delete from public.student_settings where user_id = v_student_a;
    raise exception 'S-5 FAILED: DELETE on student_settings was allowed';
  exception
    when insufficient_privilege then
      null;
  end;
  raise notice 'S-5 PASSED: DELETE denied on student_profiles and student_settings.';

  -- S-6: Inactive / internal_draft curriculum items hidden by RLS
  select count(*) into v_hidden_count
  from public.subjects
  where is_active = false or rights_status = 'internal_draft';
  if v_hidden_count <> 0 then
    raise exception 'S-6 FAILED (subjects): % inactive/draft rows visible', v_hidden_count;
  end if;

  select count(*) into v_hidden_count
  from public.chapters
  where title_en = 'Draft Parent Chapter';
  if v_hidden_count <> 0 then
    raise exception 'S-6 FAILED (chapters): child chapter of draft subject visible';
  end if;

  select count(*) into v_hidden_count
  from public.topics
  where is_active = false
     or rights_status = 'internal_draft'
     or title_en = 'Child of Draft Subject';
  if v_hidden_count <> 0 then
    raise exception 'S-6 FAILED (topics): % draft/inactive/orphaned topics visible', v_hidden_count;
  end if;

  select count(*) into v_visible_count
  from public.topics
  where title_en = 'Cleared Topic';
  if v_visible_count <> 1 then
    raise exception 'S-6 FAILED: cleared active topic was not visible (count=%)', v_visible_count;
  end if;
  raise notice 'S-6 PASSED: Draft and inactive curriculum rows hidden; cleared active rows visible.';

  -- S-7: Curriculum writes (INSERT/UPDATE/DELETE) denied for authenticated
  begin
    insert into public.education_boards (code, name_en, name_bn)
    values ('rogue_board', 'Rogue', 'রোগ');
    raise exception 'S-7 FAILED: INSERT on education_boards allowed';
  exception when insufficient_privilege then null;
  end;
  begin
    update public.subjects set title_en = 'Tampered' where code = 'rls_cleared_subj';
    raise exception 'S-7 FAILED: UPDATE on subjects allowed';
  exception when insufficient_privilege then null;
  end;
  begin
    delete from public.chapters where title_en = 'Cleared Chapter';
    raise exception 'S-7 FAILED: DELETE on chapters allowed';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.topics (chapter_id, topic_number, title_en, title_bn)
    values (1, 99, 'Rogue Topic', 'রোগ');
    raise exception 'S-7 FAILED: INSERT on topics allowed';
  exception when insufficient_privilege then null;
  end;
  raise notice 'S-7 PASSED: All curriculum write operations denied for authenticated.';
end $$;

-- ============================================================================
-- S-8: private schema and private.handle_new_auth_user() denied to authenticated & anon
-- ============================================================================
do $$
begin
  begin
    perform private.handle_new_auth_user();
    raise exception 'S-8 FAILED: authenticated called private.handle_new_auth_user()';
  exception when insufficient_privilege then null;
  end;
end $$;

reset role;
set local role anon;

do $$
begin
  begin
    perform private.handle_new_auth_user();
    raise exception 'S-8 FAILED: anon called private.handle_new_auth_user()';
  exception when insufficient_privilege then null;
  end;
end $$;

reset role;

do $$
begin
  if has_schema_privilege('anon', 'private', 'USAGE')
     or has_schema_privilege('authenticated', 'private', 'USAGE') then
    raise exception 'S-8 FAILED: private schema USAGE not revoked from anon/authenticated';
  end if;

  if has_function_privilege('anon', 'private.handle_new_auth_user()', 'EXECUTE')
     or has_function_privilege('authenticated', 'private.handle_new_auth_user()', 'EXECUTE')
     or has_function_privilege('service_role', 'private.handle_new_auth_user()', 'EXECUTE') then
    raise exception 'S-8 FAILED: EXECUTE on private.handle_new_auth_user() not revoked';
  end if;
  raise notice 'S-8 PASSED: private schema and handle_new_auth_user() denied for anon, authenticated, and service_role.';
end $$;

-- ============================================================================
-- S-3 follow-up check + S-9: Schema security & performance catalog audit
-- (Also run `supabase db advisors` via CLI for full Supabase advisor lints)
-- ============================================================================
do $$
declare
  v_b_name text;
  v_missing_rls int;
  v_unindexed_fks int;
  v_bad_funcs int;
  v_bad_policies int;
  v_anon_grants int;
  v_delete_grants int;
begin
  select display_name into v_b_name
  from public.student_profiles
  where user_id = '22222222-2222-4222-8222-222222222222';
  if v_b_name <> 'Student B Original' then
    raise exception 'S-3 integrity FAILED: Student B display_name mutated to %', v_b_name;
  end if;

  -- S-9a: Every table in public must have RLS enabled
  select count(*) into v_missing_rls
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public'
    and c.relkind = 'r'
    and not c.relrowsecurity;
  if v_missing_rls <> 0 then
    raise exception 'S-9 FAILED: % public table(s) missing RLS', v_missing_rls;
  end if;

  -- S-9b: Every FK in public must have a supporting index
  select count(*) into v_unindexed_fks
  from pg_constraint c
  join pg_namespace n on n.oid = c.connamespace
  join pg_attribute a on a.attrelid = c.conrelid and a.attnum = any(c.conkey)
  where n.nspname = 'public'
    and c.contype = 'f'
    and not exists (
      select 1 from pg_index i
      where i.indrelid = c.conrelid
        and i.indisvalid
        and a.attnum = any(i.indkey)
    );
  if v_unindexed_fks <> 0 then
    raise exception 'S-9 FAILED: % unindexed foreign key(s) in public', v_unindexed_fks;
  end if;

  -- S-9c: private functions must pin search_path = '' (empty); no security definer in public
  select count(*) into v_bad_funcs
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where (n.nspname = 'public' and p.prosecdef)
     or (n.nspname = 'private' and (p.proconfig is null or not ('search_path=' = any(p.proconfig))));
  if v_bad_funcs <> 0 then
    raise exception 'S-9 FAILED: % unsafe or mutable search_path function(s)', v_bad_funcs;
  end if;

  -- S-9d: No RLS policies referencing user_metadata or auth.role()
  select count(*) into v_bad_policies
  from pg_policies
  where schemaname = 'public'
    and (
      coalesce(qual, '') ~* '(user_metadata|raw_user_meta_data|auth\.role\s*\()'
      or coalesce(with_check, '') ~* '(user_metadata|raw_user_meta_data|auth\.role\s*\()'
    );
  if v_bad_policies <> 0 then
    raise exception 'S-9 FAILED: % policy(ies) use user_metadata or deprecated auth.role()', v_bad_policies;
  end if;

  -- S-9e: Zero anon grants and zero authenticated DELETE grants on Step 1 public tables
  select count(*) into v_anon_grants
  from information_schema.role_table_grants
  where table_schema = 'public'
    and grantee = 'anon';
  if v_anon_grants <> 0 then
    raise exception 'S-9 FAILED: % unexpected anon table grant(s)', v_anon_grants;
  end if;

  select count(*) into v_delete_grants
  from information_schema.role_table_grants
  where table_schema = 'public'
    and grantee = 'authenticated'
    and privilege_type = 'DELETE';
  if v_delete_grants <> 0 then
    raise exception 'S-9 FAILED: % unexpected authenticated DELETE grant(s)', v_delete_grants;
  end if;

  raise notice 'S-9 PASSED: All schema security and FK index catalog checks passed.';
end $$;

rollback;
