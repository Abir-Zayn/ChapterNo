# Review: feat/home-page-ui-added (PR #2)

Phase: UI + mock data. Backend not ready, so in-memory repositories and
placeholder snackbars are accepted. Findings below are follow-up fixes.

Gates at review time (commit `fa004f8`, based on `origin/main` `60e136f`):
`flutter analyze` 0 issues, `flutter test` 71 passed, `dart format` 0 changed.
No device/profile-mode testing and no Bangla render check on Home were done.

## Must fix

- [ ] **Barrels export their own implementation** (AGENTS.md §7).
  Remove self-exports; export only siblings a file needs
  (e.g. `home_cubit.dart` needs `home_state.dart`). Auth barrels do not do this.
  - `lib/feature/home/screens/home_page_imports.dart:23` exports `home_page.dart`
  - `lib/feature/home/data/repo/repo_imports.dart:11` exports `in_memory_home_repository.dart`
  - `lib/feature/home/screens/cubits/cubits_imports.dart:8-9`
  - `lib/feature/home/domain/repositories/repositories_imports.dart:6`
  - `lib/feature/home/domain/entities/entities_imports.dart:5-9`
  - `lib/feature/home/screens/widgets/home_widgets_imports.dart:17-23`
- [ ] **Bottom nav selects tabs whose content never shows.**
  `home_page.dart:121` calls `setState(() => _currentTab = tab)` for every tab.
  Practice/Community stay highlighted while Home is shown; Profile stays
  highlighted after the sheet closes. Only update `_currentTab` for
  implemented tabs. Add a widget test (current test checks only the snackbar).
- [ ] **Caption contrast fails DESIGN.md §6** (needs 4.5:1; `textDisabled`
  #A1A1AA is about 2.6:1). Use `AppColors.textSecondary` (#71717A, about 4.8:1):
  - `lib/feature/home/screens/widgets/continue_learning_card.dart:62`
  - `lib/feature/home/screens/widgets/recent_activity_section.dart:106`

## Should fix

- [ ] Remove dead `HomeHeader.onProfileTap` (`home_header.dart:13,21`) and its
  wiring `home_page.dart:60` (currently points at sign-out), or wire it to the
  profile sheet.
- [ ] Delete orphaned `lib/feature/home/screens/home_placeholder_page.dart` and
  `home_placeholder_page_imports.dart`.
- [ ] Vacuous test: `test/app_flow_test.dart:57` asserts `'You are signed in'`
  is absent, but that text exists only in the orphaned placeholder. Assert
  against something `HomePage` renders, or `find.byType(HomePage)`.
- [ ] Fix inaccurate file headers (AGENTS.md §5):
  - `in_memory_home_repository.dart` says it "simulates network latency"; it does not.
  - `home_page.dart`: uses `BlocBuilder` only; most actions are snackbar placeholders.
  - `home_header.dart`: no profile control is rendered.
  - `quick_actions_grid.dart`, `home_bottom_nav.dart`: no navigation is wired.
  - `study_activity_item.dart`: no date/score value, only display strings.
  - `subject_progress.dart`: stores `weakTopicsCount` only.
  - `home_state.dart`: file declares states; the cubit emits them.
- [ ] `home_page.dart:156` hardcodes `'Signed in as Siam (SSC 2026 Batch)'` while
  the header reads from state. Use `dashboard.studentName` / `cohortTitle`
  (update `home_page_test.dart:100`).
- [ ] Overlapping cubit calls (AGENTS.md §10): `loadDashboard`,
  `refreshDashboard`, `advanceDailyGoal` can complete out of order. Add a
  request token / sequence counter and ignore stale results, with a test.

## Tests to add

- [ ] HomePage loading, error, and "Try Again" widget tests.
- [ ] Narrow-layout test at 320dp x 2.0x text (existing: 360dp x 1.5x only).
- [ ] Semantics and 48dp tap-target checks on bottom nav and quick actions.
- [ ] Bangla string case in a Home layout test.
- [ ] Cubit tests: retry recovery, close while pending, overlapping loads.
  Replace `skip: 2` and unawaited `close()` in `home_cubit_test.dart`
  (use `addTearDown`).

## Verify (not confirmed)

- `quick_actions_grid.dart` fixed `childAspectRatio: 1.2` may overflow at 320dp
  with large text (about 70% confidence).
- `home_header.dart` badge row is not flexible; large coin counts plus text
  scale may squeeze the student name.

## Deferred to backend phase

Tracked here so they are not lost; not blocking now.

- `InMemoryHomeRepository` is the silent default (`app_router.dart:11`);
  make `homeRepository` required and build it in `main.dart` once a real one exists.
- "Continue Practice" increments progress client-side
  (`in_memory_home_repository.dart:99-121`); progress must be server-derived.
- `app_router.dart:82-85` navigates to `/welcome` even if `signOut()` returns `Left`.
- Repository state outlives sign-out (single instance per router).
- Typed `HomeFailure` instead of `Either<String, ...>`; try/catch in `HomeCubit`;
  keep loaded data when refresh/advance fails.
- Entity invariants: `DailyGoal.isCompleted` is true when `totalQuestions == 0`;
  `StudentDashboard` lists are mutable; display strings (`timeAgo`, `scoreText`,
  `lastStudiedText`) live in domain entities.

## Done well

Clean layer separation with no Flutter/Supabase in domain; `BlocProvider(create:)`
owns the cubit and `isClosed` is checked after every await; sealed Equatable
states with an exhaustive switch; reuse of shared widgets; solid surfaces with
theme tokens and no blur; `SafeArea` and ellipsis handling; all files under
300 lines with 2-3 line headers.
