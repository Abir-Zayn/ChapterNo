# Wave 4 Integration Map — Pending Step 1 Contracts

This document maps every pre-merge harness shell and contract double in `test/e2e/` to the exact production symbols unlocked after Wave 4 Integration (`M1.1`–`M1.5` + fixing the 32 pre-existing `context.primary*` analyzer errors in `lib/`).

## 1. Root Harness Swap (`test/e2e/support/e2e_harness.dart`)
- **Current pre-merge state**: `E2eTestApp` wraps `MaterialApp.router` + `GoRouter` + `AppTheme.light()` / `AppTheme.dark()` + `WidgetsBindingObserver`, wiring real `SplashPage`, `WelcomePage`, `LoginPage`, `SignUpPage`, `ForgotPasswordPage`, `LegalDocumentPage`, and `LearningAnalyticsPage` alongside shell routes for `/onboarding`, `/home`, `/profile`, `/settings` (driven by real `ProfileCubit` & `SettingsCubit`).
- **Wave 4 swap**:
  - Replace `E2eTestApp` with `ChapterNoApp` (`lib/app.dart`) constructed from `AppDependencies` (`lib/bootstrap.dart`), keeping `FakeAuthRepository`, `FakeProfileRepository`, and `InMemoryCurriculumRepository` (or mocked `CurriculumRemoteDataSource`) injected cleanly.
  - Exercise real `bootstrap()` (`AppCrashLogger`, `FlutterError.onError`, `PlatformDispatcher.instance.onError` returning `true`, `Env.validate()`) and real `SessionResetCoordinator` (`lib/core/lifecycle/session_reset_coordinator.dart`).

## 2. Pending Step 1 Production Contracts by Acceptance Criterion

| AC | Pending Production Symbols (Pre-Wave 4) | E2E Files Unlocked / Updated in Wave 4 |
|---|---|---|
| **AC-1** | `lib/bootstrap.dart` (`bootstrap()`, `AppDependencies`), `lib/core/error/app_crash_logger.dart`, `ChapterNoApp` `WidgetsBindingObserver` + `initialDarkMode` | `support/e2e_harness.dart`, `tiers/tier1_ac1_ac2.dart`, `tiers/tier2_ac1_ac2.dart` |
| **AC-2** | `SignUpOutcome` (`authenticated` / `verificationRequired`), expanded `AuthFailure` (`emailNotConfirmed`, `rateLimited`, `weakPassword`), `SignUpPage` verification notice, `SupabaseAuthRepository` UTC ISO DOB & `redirectTo` | `support/e2e_fakes.dart`, `tiers/tier1_ac1_ac2.dart`, `tiers/tier2_ac1_ac2.dart`, `tiers/tier3_part2.dart`, `tiers/tier4_journeys_b.dart` |
| **AC-3** | `AppRoutes.onboarding`, `SplashStatus` (`checking`, `signedOut`, `needsOnboarding`, `ready`, offline error/retry), `SplashPage` Retry + Sign Out, `LoginPage` onboarding status gate | `support/e2e_harness.dart`, `tiers/tier1_ac3.dart`, `tiers/tier2_ac3.dart`, `tiers/tier4_journeys_a.dart`, `tiers/tier4_journeys_b.dart` |
| **AC-4** | `OnboardingPage`, `OnboardingCubit`, `OnboardingDraft`, `ProfileRepository.completeOnboarding`, `CurriculumRepository.getEducationBoards` | `support/e2e_onboarding_home_shells.dart` -> real `OnboardingPage`, `tiers/tier1_ac4.dart`, `tiers/tier2_ac4.dart`, `tiers/tier3_part1.dart`, `tiers/tier3_part2.dart` |
| **AC-5** | `SupabaseProfileRepository` (`'Free'`, `0` stats), `ProfilePage` `'Unranked'` when `leaderboardRank <= 0`, `LearningAnalyticsPage` `AppStateView` empty state + Practice CTA when `totalSolvedVolume == 0`, `SettingsPage` | `support/e2e_profile_settings_shells.dart` -> real `ProfilePage`/`SettingsPage`, `tiers/tier1_ac5.dart` (`T1-AC5-02` empty state CTA), `tiers/tier2_ac5.dart` |
| **AC-6** | `SessionResetCoordinator` (`registerUserCacheReset`, `handleAuthStateChange`, `resetForSignOut`), `ProfileRepository.clearCachedUserData()` | `support/e2e_harness.dart`, `tiers/tier1_ac6.dart`, `tiers/tier2_ac6.dart`, `tiers/tier3_part2.dart`, `tiers/tier4_journeys_a.dart` |
| **AC-7** | `lib/feature/curriculum/` (`AcademicGroup`, `EducationBoard`, `Subject`, `Chapter`, `Topic`, `CurriculumRepository`, `SupabaseCurriculumRepository`, `InMemoryCurriculumRepository`) | `support/e2e_curriculum_fake.dart` & `e2e_curriculum_models.dart` -> real `CurriculumRepository` + `InMemoryCurriculumRepository`, `tiers/tier1_ac7.dart`, `tiers/tier2_ac7.dart` |

## 3. 20-Feature Traceability Matrix (`PROJECT.md § Feature Inventory`)

| # | Feature (`PROJECT.md`) | Tier 1–4 E2E Coverage | Scope / Wave 4 Swap-In |
|---|---|---|---|
| 1 | `supabase_flutter` dependency & `.env` wiring | `T1-AC1-05`, `T2-AC1-01` | Client `Env.validate()` covered; PKCE `Supabase.initialize` runs in Wave 4 `bootstrap()` |
| 2 | Cold-launch error handlers & `bootstrap()` | `T1-AC1-01`, `T1-AC1-02`, `T1-AC1-03`, `T2-AC1-03`, `T2-AC1-04` | Frame-1 theme/splash & corrupt-prefs fallback covered; `AppCrashLogger` + `FlutterError`/`PlatformDispatcher` handlers swap in Wave 4 |
| 3 | `AppDependencies` & `SupabaseClientProvider` | Smoke + all widget E2E tests (`E2eTestApp`) | Constructor-injected dependencies exercised; Wave 4 swaps `E2eTestApp` -> `ChapterNoApp` + `AppDependencies` |
| 4 | Root `WidgetsBindingObserver` lifecycle flush | `T1-AC1-04`, `T2-AC1-02`, `T3-04`, `T4-05` | Covered (`inactive`/`paused` flush, `resumed` safe); Wave 4 swaps to `ChapterNoApp` observer |
| 5 | `SessionResetCoordinator` | `T1-AC6-01`..`05`, `T2-AC6-01`..`05`, `T3-05`, `T3-06`, `T4-03` | Sign-out, mid-flight `getProfile()` disposal, direct `A -> B` switch, curriculum retention covered; Wave 4 swaps `_onAuthChange` -> `SessionResetCoordinator` |
| 6 | Imperative Supabase migration & `private` helpers | N/A (Postgres schema) | **Out-of-widget scope (DB/CLI)**: verified via `supabase db reset` + `supabase db advisors` + `rls_matrix.sql` |
| 7 | Auto-provisioning auth trigger (`private.handle_new_auth_user`) | `T1-AC2-01`, `T1-AC2-02`, `T2-AC2-06`, `T1-AC3-02` | Client UTC ISO DOB & un-onboarded default covered; Postgres trigger & `1990-01-01..current_date` clamp are **DB/CLI out-of-widget scope** |
| 8 | Strict RLS & least-privilege grants (`S-1`..`S-9`) | N/A (Postgres RLS) | **Out-of-widget scope (DB/CLI)**: verified via `supabase/verification/rls_matrix.sql` + `supabase db advisors` |
| 9 | `SupabaseAuthRemoteDataSource` & `SupabaseAuthRepository` | `T1-AC2-01`..`05`, `T2-AC2-01`..`06`, `T1-AC6-01`..`04`, `T2-AC6-01`..`05`, `T4-04` | Full auth flows exercised via `FakeAuthRepository`; Wave 4 swaps `SupabaseAuthRepository` unit/contract coverage |
| 10 | Email-confirmation vs immediate-session sign-up | `T1-AC2-01`, `T3-07`, `T4-04` | Immediate & verification-gated sign-up covered; Wave 4 swaps `SignUpOutcome`, expanded `AuthFailure`, and `SignUpPage` verification notice |
| 11 | Post-auth onboarding route guard | `T1-AC3-01`..`05`, `T2-AC3-01`..`05`, `T3-01`, `T4-02`, `T4-06` | Signed-out, incomplete, completed, offline retry/sign-out covered; Wave 4 swaps `AppRoutes.onboarding` + `SplashCubit` |
| 12 | `OnboardingPage` & `OnboardingCubit` | `T1-AC4-01`..`05`, `T2-AC4-01`..`06`, `T3-02`, `T3-03`, `T3-08`, `T4-01`, `T4-03`..`05` | All groups, boards, pace, username, 360px/1.3x, Bangla, no Foundation/Standard covered; Wave 4 swaps `E2eOnboardingShellPage` -> `OnboardingPage` |
| 13 | `SupabaseProfileRepository` (honest zero-state + settings) | `T1-AC5-01`, `T1-AC5-03`..`05`, `T2-AC5-01`..`04`, `T2-AC5-06`, `T3-03`, `T3-04`, `T4-01`, `T4-05` | `'Free'`, `0` stats, `'Unranked'`, dark mode & language mirror, settings persistence covered; Wave 4 swaps `ProfilePage`/`SettingsPage` |
| 14 | Honest `LearningAnalyticsPage` empty state | `T1-AC5-02`, `T2-AC5-02`, `T2-AC5-05`, `T3-03`, `T4-01` | Real `LearningAnalyticsPage` empty/zero state & timeframe switches covered; Wave 4 updates `T1-AC5-02` for empty-state Practice CTA |
| 15 | `lib/feature/curriculum/` Clean Architecture | `T1-AC7-01`..`05`, `T2-AC7-01`..`06`, `T3-02`, `T4-01`, `T4-02` | Boards, group filtering, chapters, topics, bilingual metadata covered via `FakeCurriculumCatalogue`; Wave 4 swaps `CurriculumRepository` |
| 16 | Two-tier bounded 24h TTL cache + offline fallback | `T1-AC6-05`, `T1-AC7-03`..`05`, `T2-AC7-01`..`06`, `T3-06`, `T4-02` | Memory + disk TTL, stale-while-offline, `schemaVersion` & corrupt JSON, bounded eviction, sign-out survival covered; Wave 4 swaps `SupabaseCurriculumRepository` |
| 17 | `supabase/seed.sql` | `T1-AC4-04`, `T1-AC7-01`, `T1-AC7-02` (client filtering) | **Out-of-widget scope (DB/CLI)**: SQL seed idempotency & data verified via `supabase db reset` |
| 18 | `InMemoryCurriculumRepository` | `T1-AC4-04`, `T1-AC7-01`, `T1-AC7-02`, `T3-02`, `T4-01` | Deterministic in-memory curriculum double (`FakeCurriculumCatalogue`) exercised; Wave 4 swaps `InMemoryCurriculumRepository` |
| 19 | Android & iOS PKCE callback deep links | `T1-AC2-04`, `T4-04` (reset dispatch) | **Out-of-widget scope (Native OS)**: `ai.actionboard.chapterno://auth-callback` intent handling requires Android/iOS emulator or device |
| 20 | Static compliance & secret-safety audit | Standards gate on `test/e2e/**` | **Out-of-widget scope (Static policy test)**: `test/policy/step1_policy_audit_test.dart` (Wave 4) + E2E standards gate |

## 4. Out-of-Scope for Flutter Widget E2E (Verified Separately)
- Live Supabase RLS & grants (`S-1`..`S-9`): `supabase start` + `supabase/verification/rls_matrix.sql` + `supabase db advisors`.
- Postgres `private.handle_new_auth_user()` trigger & `1990-01-01..current_date` DOB check constraint: live local Supabase signup + SQL check.
- OS PKCE deep-link dispatch (`ai.actionboard.chapterno://auth-callback`): Android emulator / iOS simulator intent test.
- Real-device cold-start frame budget & memory profiling: `flutter run --profile --dart-define-from-file=.env`.
