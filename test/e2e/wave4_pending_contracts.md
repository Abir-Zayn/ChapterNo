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
| **AC-3** | `AppRoutes.onboarding`, `SplashStatus` (`checking`, `signedOut`, `needsOnboarding`, `ready`, offline error/retry), `SplashPage` Retry + Sign Out, `LoginPage` onboarding status gate | `support/e2e_harness.dart`, `tiers/tier1_ac3_ac4.dart`, `tiers/tier2_ac3.dart`, `tiers/tier4_journeys_a.dart`, `tiers/tier4_journeys_b.dart` |
| **AC-4** | `OnboardingPage`, `OnboardingCubit`, `OnboardingDraft`, `ProfileRepository.completeOnboarding`, `CurriculumRepository.getEducationBoards` | `support/e2e_onboarding_home_shells.dart` -> real `OnboardingPage`, `tiers/tier1_ac3_ac4.dart`, `tiers/tier2_ac4.dart`, `tiers/tier3_part1.dart`, `tiers/tier3_part2.dart` |
| **AC-5** | `SupabaseProfileRepository` (`'Free'`, `0` stats), `ProfilePage` `'Unranked'` when `leaderboardRank <= 0`, `LearningAnalyticsPage` `AppStateView` empty state + Practice CTA when `totalSolvedVolume == 0`, `SettingsPage` | `support/e2e_profile_settings_shells.dart` -> real `ProfilePage`/`SettingsPage`, `tiers/tier1_ac5.dart` (`T1-AC5-02` empty state CTA), `tiers/tier2_ac5.dart` |
| **AC-6** | `SessionResetCoordinator` (`registerUserCacheReset`, `handleAuthStateChange`, `resetForSignOut`), `ProfileRepository.clearCachedUserData()` | `support/e2e_harness.dart`, `tiers/tier1_ac6.dart`, `tiers/tier2_ac6.dart`, `tiers/tier3_part2.dart`, `tiers/tier4_journeys_a.dart` |
| **AC-7** | `lib/feature/curriculum/` (`AcademicGroup`, `EducationBoard`, `Subject`, `Chapter`, `Topic`, `CurriculumRepository`, `SupabaseCurriculumRepository`, `InMemoryCurriculumRepository`) | `support/e2e_curriculum_fake.dart` & `e2e_curriculum_models.dart` -> real `CurriculumRepository` + `InMemoryCurriculumRepository`, `tiers/tier1_ac7.dart`, `tiers/tier2_ac7.dart` |

## 3. Out-of-Scope for Flutter Widget E2E (Verified Separately)
- Live Supabase RLS & grants (`S-1`..`S-9`): `supabase start` + `supabase/verification/rls_matrix.sql` + `supabase db advisors`.
- Postgres `private.handle_new_auth_user()` trigger & `1990-01-01..current_date` DOB check constraint: live local Supabase signup + SQL check.
- OS PKCE deep-link dispatch (`ai.actionboard.chapterno://auth-callback`): Android emulator / iOS simulator intent test.
- Real-device cold-start frame budget & memory profiling: `flutter run --profile --dart-define-from-file=.env`.
