-- Step 1 (Foundation): Student Profiles, Settings, Controlled SSC Curriculum & Strict RLS
-- Refs: docs/step-1-foundation/02_DATABASE_SCHEMA_AND_RLS.md

-- 1. Non-exposed private helper schema & updated_at trigger function
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create or replace function private.set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- 2. Controlled Curriculum Catalogue Tables
create table public.education_boards (
  id bigint generated always as identity primary key,
  code text not null unique check (code ~ '^[a-z0-9_]+$'),
  name_en text not null,
  name_bn text not null,
  sort_order smallint not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.subjects (
  id bigint generated always as identity primary key,
  code text not null unique check (code ~ '^[a-z0-9_]+$'),
  education_level text not null default 'ssc' check (education_level in ('ssc')),
  academic_group text not null check (
    academic_group in ('common', 'science', 'business_studies', 'humanities')
  ),
  subject_code text,
  paper_code text check (paper_code in ('1st', '2nd')),
  title_en text not null,
  title_bn text not null,
  syllabus_version text not null,
  provenance_source text not null default 'nctb_syllabus',
  rights_status text not null default 'cleared' check (
    rights_status in ('cleared', 'internal_draft')
  ),
  sort_order smallint not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.chapters (
  id bigint generated always as identity primary key,
  subject_id bigint not null references public.subjects(id) on delete restrict,
  chapter_number smallint not null check (chapter_number > 0),
  title_en text not null,
  title_bn text not null,
  summary_en text,
  summary_bn text,
  sort_order smallint not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (subject_id, chapter_number)
);

create index chapters_subject_id_idx on public.chapters (subject_id);

create table public.topics (
  id bigint generated always as identity primary key,
  chapter_id bigint not null references public.chapters(id) on delete restrict,
  topic_number smallint not null check (topic_number > 0),
  title_en text not null,
  title_bn text not null,
  provenance_source text not null default 'nctb_syllabus' check (
    provenance_source in ('nctb_syllabus', 'curated_editorial')
  ),
  rights_status text not null default 'cleared' check (
    rights_status in ('cleared', 'internal_draft')
  ),
  sort_order smallint not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (chapter_id, topic_number)
);

create index topics_chapter_id_idx on public.topics (chapter_id);

-- 3. Private Student Profile & Settings Tables
create table public.student_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '' check (char_length(display_name) <= 60),
  username text unique check (
    username is null or username ~ '^[a-z0-9_]{3,24}$'
  ),
  date_of_birth date check (
    date_of_birth is null or (
      date_of_birth <= current_date and date_of_birth >= date '1990-01-01'
    )
  ),
  ssc_batch_year smallint check (
    ssc_batch_year is null or ssc_batch_year between 2025 and 2032
  ),
  board_id bigint references public.education_boards(id) on delete restrict,
  academic_group text check (
    academic_group is null or academic_group in ('science', 'business_studies', 'humanities')
  ),
  learning_pace text not null default 'standard' check (
    learning_pace in ('casual', 'standard', 'intensive')
  ),
  onboarding_completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint onboarding_fields_complete_chk check (
    onboarding_completed_at is null or (
      char_length(btrim(display_name)) >= 2
      and ssc_batch_year is not null
      and board_id is not null
      and academic_group is not null
    )
  )
);

create index student_profiles_board_id_idx on public.student_profiles (board_id);

create table public.student_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  notifications_enabled boolean not null default true,
  sound_effects_enabled boolean not null default true,
  haptics_enabled boolean not null default false,
  learning_track text not null default 'standard_ssc' check (
    learning_track in ('standard_ssc', 'accelerated_revision', 'exam_sprint')
  ),
  app_language text not null default 'en' check (app_language in ('en', 'bn')),
  dark_mode_enabled boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger student_profiles_set_updated_at
  before update on public.student_profiles
  for each row execute function private.set_updated_at();

create trigger student_settings_set_updated_at
  before update on public.student_settings
  for each row execute function private.set_updated_at();

-- 4. Automatic Row Provisioning on auth.users Sign-Up
create or replace function private.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_dob date;
begin
  -- Safely parse optional ISO date_of_birth passed at sign-up; ignore malformed input.
  begin
    if new.raw_user_meta_data ? 'date_of_birth' then
      v_dob := (new.raw_user_meta_data ->> 'date_of_birth')::date;
    end if;
  exception when others then
    v_dob := null;
  end;

  -- Clamp out-of-range metadata DOB to null so auth.users insert never aborts with 23514.
  if v_dob is not null and (v_dob < date '1990-01-01' or v_dob > current_date) then
    v_dob := null;
  end if;

  insert into public.student_profiles (user_id, date_of_birth)
  values (new.id, v_dob)
  on conflict (user_id) do nothing;

  insert into public.student_settings (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

revoke execute on function private.handle_new_auth_user()
  from public, anon, authenticated, service_role;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_auth_user();

-- 5. Enable Row-Level Security (RLS) on Every Public Table
alter table public.education_boards enable row level security;
alter table public.subjects enable row level security;
alter table public.chapters enable row level security;
alter table public.topics enable row level security;
alter table public.student_profiles enable row level security;
alter table public.student_settings enable row level security;

-- 6. Explicit Least-Privilege Data API Grants
revoke all on public.education_boards, public.subjects, public.chapters, public.topics
  from public, anon, authenticated;
grant select on public.education_boards, public.subjects, public.chapters, public.topics
  to authenticated;

revoke all on public.student_profiles, public.student_settings
  from public, anon, authenticated;
grant select, insert, update on public.student_profiles, public.student_settings
  to authenticated;

-- 7. Curriculum Catalogue Policies (authenticated read of active, cleared rows only)
create policy education_boards_select_active on public.education_boards
  for select to authenticated
  using (is_active = true);

create policy subjects_select_cleared on public.subjects
  for select to authenticated
  using (is_active = true and rights_status = 'cleared');

create policy chapters_select_active on public.chapters
  for select to authenticated
  using (
    is_active = true
    and exists (
      select 1 from public.subjects s
      where s.id = chapters.subject_id
        and s.is_active = true
        and s.rights_status = 'cleared'
    )
  );

create policy topics_select_cleared on public.topics
  for select to authenticated
  using (
    is_active = true
    and rights_status = 'cleared'
    and exists (
      select 1 from public.chapters c
      join public.subjects s on s.id = c.subject_id
      where c.id = topics.chapter_id
        and c.is_active = true
        and s.is_active = true
        and s.rights_status = 'cleared'
    )
  );

-- 8. Student Profile Policies (strict owner-only isolation)
create policy student_profiles_select_own on public.student_profiles
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy student_profiles_insert_own on public.student_profiles
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy student_profiles_update_own on public.student_profiles
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- 9. Student Settings Policies (strict owner-only isolation)
create policy student_settings_select_own on public.student_settings
  for select to authenticated
  using ((select auth.uid()) = user_id);

create policy student_settings_insert_own on public.student_settings
  for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy student_settings_update_own on public.student_settings
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
