# chapter_no — Agent Instructions

Shared instructions for Claude Code, Codex, Gemini CLI, OpenCode,
Antigravity, Warp, and other AI coding tools.

`AGENTS.md` is the canonical instruction file.
`CLAUDE.md` and `GEMINI.md` import this file — edit shared rules here only.
Configure other tools to read this file using their supported mechanism.

## 1. Understand the Project First

Before making changes:

- Read `CHAPTERNO_PROJECT_GUIDE.md` for business context and product rules.
- Read `DESIGN.md` before implementing or changing UI.
- Inspect the current architecture, relevant code, dependencies, and git status.
- Load relevant project skills.
- Understand the requested behavior before selecting an implementation.
- Preserve existing approved behavior and unrelated uncommitted work.

The confirmed stack below supersedes older guidance describing the backend
as undecided or suggesting Bloc/Cubit/GetIt.

Do not silently change architecture, business rules, pricing, quotas,
entitlements, or release scope.

## 2. Confirmed Stack

- Flutter stable / Dart 3, targeting Android and iOS.
- Package ID: `ai.actionboard.chapter_no`.
- Backend: Supabase through `supabase_flutter`:
  Auth, Postgres + RLS, Storage, Realtime, and Edge Functions.
- State management and DI: Riverpod 3.x using Notifier / AsyncNotifier.
- No `get_it`, Bloc/Cubit, or legacy `StateNotifierProvider` for new code.
- Distribution: Google Play through signed AAB and Play App Signing.

Use the versions pinned in the repository.
Do not upgrade dependencies or replace working infrastructure incidentally.

## 3. Project Skills

Installed in `.agents/skills/` for Codex, Gemini CLI, and OpenCode,
and linked into `.claude/skills/` for Claude Code.

Load the matching skill before starting a task:

| Task | Skill(s) |
|---|---|
| Architecture, feature layout, scaling the codebase | `flutter-apply-architecture-best-practices`, `app-startup-and-bootstrap` |
| State management | `state-management-riverpod` |
| Performance: jank, rebuilds, lists, images, startup | `flutter-performance`, `app-startup-and-bootstrap` |
| Unit tests | `dart-add-unit-test`, `dart-generate-test-mocks`, `dart-collect-coverage` |
| Widget tests | `flutter-add-widget-test` |
| Integration / E2E tests | `flutter-add-integration-test` |
| Supabase: auth, RLS, storage, realtime, Edge Functions | `supabase` |
| SQL schema, migrations, RLS policies, indexes | `supabase-postgres-best-practices` |
| Google Play release, signing, R8, AAB | `playstore-flutter`, `release-and-store-shipping` |
| CI gates | `ci-pipeline-and-gates`, `dart-run-static-analysis` |
| Layout / responsive / routing / l10n / JSON | `flutter-fix-layout-issues`, `flutter-build-responsive-layout`, `flutter-setup-declarative-routing`, `flutter-setup-localization`, `flutter-implement-json-serialization` |
| Dependency conflicts, runtime errors | `dart-resolve-package-conflicts`, `dart-fix-runtime-errors` |

Skill management:

- List: `npx skills list`
- Update: `npx skills update -p -y`
- Restore on a new machine: `npx skills experimental_install`

If a required skill is unavailable, report it.
Do not claim to have loaded or followed a missing skill.

## 4. Reusable Components First

- Search existing components before creating new ones.
- Reuse buttons, inputs, cards, dialogs, loaders, and feedback states.
- Extend existing components when the change fits their responsibility.
- Extract repeated UI and logic into focused reusable components.
- Keep feature-specific widgets inside their feature.
- Put genuinely cross-feature components in `shared/`.
- Avoid duplicate components and speculative abstraction frameworks.

## 5. File Purpose Headers

Every manually maintained code file must begin with a concise 2–3 line
comment explaining its purpose and responsibility.

Example:

```dart
// Displays the student's Home screen and learning progress.
// Composes reusable widgets and renders state from Home providers.
// Business rules and data access remain outside this file.
```

Keep headers accurate when behavior changes.
Do not add change logs or obvious line-by-line explanations.

Generated files remain generator-controlled.

## 6. Feature-Based Clean Architecture

Follow this structure:

```text
lib/
  config/
  core/
  feature/
    auth/
      screens/
        widgets/
        providers/
      data/
        models/
        resource/
        repo/
        utils/
      domain/
        entities/
        usecase/
        repositories/
  shared/
```

Use `providers/` for Riverpod providers, Notifiers, AsyncNotifiers,
and presentation state instead of `cubits/`.

### Responsibilities

- `config/`: app configuration, routing, and environment setup.
- `core/`: foundational infrastructure, networking, errors, and utilities.
- `shared/`: reusable cross-feature components and capabilities.
- `screens/`: pages and presentation composition.
- `screens/widgets/`: feature-specific widgets.
- `screens/providers/`: presentation state and dependency wiring.
- `data/models/`: serialization and external data representations.
- `data/resource/`: local and remote data sources.
- `data/repo/`: implementations of domain repository contracts.
- `data/utils/`: feature-specific data helpers.
- `domain/entities/`: business entities.
- `domain/usecase/`: business operations.
- `domain/repositories/`: repository interfaces.

### Dependency Rules

- Domain must not depend on Flutter, Riverpod, or Supabase.
- Data implements domain repository contracts.
- Presentation accesses business operations through injected dependencies.
- Use Riverpod for dependency injection.
- Widgets must not execute Supabase queries or call AI/payment providers.
- Keep business rules out of widgets and serialization models.
- Avoid coupling one feature to another feature's internal implementation.
- Do not create empty layers or unnecessary pass-through classes.
- Avoid unrelated architectural migrations during small tasks.

## 7. Separate Implementation and Dependency Files

Keep implementation code separate from its dependency declarations.

For Dart, use a narrowly scoped export barrel:

```dart
// home_page_imports.dart

// Exposes dependencies used by the Home page.
// Keeps dependency declarations separate from page composition.
export 'package:flutter/material.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';

export 'providers/home_provider.dart';
export 'widgets/home_content.dart';
```

```dart
// home_page.dart

// Displays the student's Home screen.
// Composes Home widgets and renders provider state.
import 'home_page_imports.dart';

// Actual implementation.
```

Rules:

- Use `export` in the dependency file: Dart imports are not transitive.
- The implementation still needs its single barrel import.
- Export only dependencies needed by the paired implementation.
- Do not create one global barrel exporting the entire application.
- Avoid circular dependencies.
- Do not export the paired implementation from its own dependency file.
- Use `show` / `hide` where appropriate.
- Use direct imports when prefixes, deferred loading, or other Dart
  semantics require them.
- Do not use `part` solely to share imports.
- Follow generator requirements for generated part files.

## 8. Code File Size

For manually maintained code files:

- Prefer 150–220 physical lines or fewer.
- Never exceed 300 physical lines, including comments and blank lines.
- Smaller focused files are encouraged.
- Split by responsibility before reaching the limit.
- Extract widgets, providers, models, use cases, or helpers as appropriate.
- Do not compress formatting or remove useful comments to bypass the limit.
- Do not split cohesive logic arbitrarily.

Generated files are exempt and must not be manually edited.

## 9. Design Rules

Before developing any screen:

1. Read the existing `DESIGN.md`.
2. Inspect approved screens and reusable components.
3. Follow established tokens, typography, spacing, colors, and navigation.

If a dedicated screen design is missing:

- Derive the screen from `DESIGN.md` and approved product patterns.
- Do not create an unrelated generic design.
- Ask only when missing information materially changes the user flow.

Use the actual filename if the repository uses `DESIGN.MD`.
Do not create a duplicate differing only by letter case.

### Prohibited Effects

- No glassmorphism.
- No backdrop blur.
- No decorative blur effects.
- No frosted translucent panels.

Use solid surfaces, clear borders, and the approved elevation system.

### UI Quality

- Preserve previously approved screens.
- Support Bangla readability and correct Unicode rendering.
- Support narrow screens, text scaling, safe areas, and keyboard insets.
- Include relevant loading, empty, error, retry, offline, and success states.
- Use accessible touch targets and semantic labels.
- Do not represent demo data or incomplete integrations as production behavior.

## 10. Riverpod Lifecycle and State

- Use Notifier / AsyncNotifier according to the existing project conventions.
- Keep state transitions explicit and handle loading/error states.
- Use focused subscriptions and `select` where it meaningfully reduces rebuilds.
- Do not introduce unnecessary global providers.
- Use automatic disposal where appropriate.
- Register cleanup with `ref.onDispose` for resources owned by providers.
- Cancel stale work and prevent outdated responses from replacing newer state.
- Invalidate user-specific state appropriately on sign-out/account changes.
- Do not dispose shared resources owned by another lifecycle.

## 11. Memory and Performance

Check affected flows for memory leaks, frame drops, excessive rebuilds,
and unnecessary resource consumption.

### Resource Management

- Dispose owned controllers, FocusNodes, and animation resources.
- Cancel owned timers, subscriptions, listeners, and pending work.
- Release feature-owned Realtime channels.
- Avoid retained contexts and references to disposed screens.
- Prevent asynchronous updates after disposal.

### Rendering and Data

- Keep expensive computation and blocking work off the UI thread.
- Use lazy lists and pagination.
- Resize images appropriately and bound cache growth.
- Avoid duplicate requests, uncontrolled polling, and unbounded retries.
- Debounce high-frequency input where needed.
- Avoid expensive decorative animations and unnecessary layout work.

### Measurement and Fixes

- Measure performance in `--profile` mode on a real device, never debug.
- Use DevTools to investigate frame timing, rebuilds, and retained memory.
- Check repeated navigation and resource-heavy flows when relevant.
- Fix identified issues within scope and verify the affected flow again.
- Report any unresolved issue and unavailable device/profile checks.

Compilation and static analysis do not prove the absence of leaks or jank.
Never claim performance was measured unless it actually was.

## 12. Supabase and Security

- Never commit secrets, including service-role keys, `key.properties`,
  `*.jks`, or `.env`.
- Only the Supabase anon/publishable key may ship in the app.
- Client-visible keys are not an authorization boundary.
- Enable RLS on every application table and define explicit policies.
- Verify ownership and access boundaries for every relevant operation.
- Apply appropriate Storage policies and private object access.
- Protect privileged Edge Functions with authentication and authorization.
- Never expose service-role credentials to the client.
- Store schema changes in versioned migrations.
- Test policies with both authorized and unauthorized users.
- Do not trust the client for coins, entitlements, marks, or leaderboard results.
- Validate external input and verify purchase events server-side.
- Use atomic operations and idempotency for financial and quota changes.
- Do not log tokens, private student content, or sensitive uploads.

## 13. Validation Gates

Before finishing a change:

```bash
dart format .
flutter analyze
flutter test
```

Required outcome:

- Formatting applied without unrelated churn.
- Static analysis reports zero issues.
- Tests pass.

Inspect formatting changes and preserve unrelated work.

Add meaningful tests for changed business rules, authorization,
entitlements, coins, quotas, and lifecycle-sensitive behavior.
Use relevant widget/integration tests for affected flows.

When a check cannot run or an existing failure blocks it, report the exact
limitation. Do not hide failures, weaken checks, or claim a passing result.

## 14. Collaboration and Completion

- Preserve other contributors' work.
- Do not reset or discard unrelated changes.
- Coordinate overlapping edits between agents.
- Update relevant documentation when approved behavior changes.
- Leave a concise handoff for unfinished or multi-session tasks.
- Do not deploy, publish, purchase, or perform destructive operations
  without authorization.

At completion, briefly report:

1. What changed and why.
2. Components reused or extracted, where relevant.
3. Checks performed and their results.
4. Remaining limitations or decisions.

Proceed with authorized, reversible work without repeatedly asking
for confirmation.

## 15. Widget Extraction and Code Splitting

Keep pages focused on screen composition, navigation, and rendering state.

- Extract meaningful UI sections into separate widget files.
- Split widgets by responsibility, reuse, independent state, or rebuild behavior.
- Do not wait until a file reaches 300 lines before splitting it.
- Prefer small widget classes over large `_buildSection()` methods.
- Do not extract every Padding, Text, or Row into a separate component.
- Avoid deeply nested widget trees that are difficult to read or maintain.
- Keep extracted widgets subject to the same file headers, import separation,
  and file-size rules.

### Placement

- Screen-specific widgets: `feature/<name>/screens/widgets/`.
- Cross-feature reusable widgets: `shared/widgets/`.
- Business logic: domain use cases or appropriate application/state layer.
- Data access: data sources and repository implementations.

Example:

```text
feature/home/screens/
  home_page.dart
  home_page_imports.dart
  providers/
    home_provider.dart
  widgets/
    continue_learning_card.dart
    daily_goal_card.dart
    recent_activity_list.dart
```

### Widget Boundaries

- Give widgets clear, typed inputs and callbacks.
- Prefer passing the specific data needed instead of entire state objects.
- Keep presentational widgets independent of Supabase and business logic.
- Use ConsumerWidget only where provider access is needed.
- Subscribe to state near the smallest meaningful subtree that uses it.
- Use `const` constructors where possible.
- Use stable keys when list identity or reordering requires them.
- Keep local ephemeral state local; do not create providers for every UI detail.
- Widget extraction alone does not guarantee fewer rebuilds; verify behavior.

## 16. Testing Requirements

Testing must verify observable behavior, business rules, and failure handling.
Do not treat compilation, static analysis, or a rendered screen as proof
that a feature works.

### Unit Tests

Test changed logic where applicable:

- Domain use cases and business rules.
- Riverpod Notifier / AsyncNotifier state transitions.
- Repository behavior, serialization, and error mapping.
- Quota, entitlement, coin, scoring, and ranking calculations.
- Validation, retry limits, and stale-response handling.

Keep unit tests isolated from live services.
Use controlled clocks and deterministic fixtures for time-sensitive behavior.

### Riverpod Tests

- Create an isolated ProviderContainer for each test and dispose it afterward.
- Override external dependencies with fakes or mocks.
- Verify relevant loading, success, empty, and error transitions.
- Test invalidation and cleanup when lifecycle behavior changes.
- Ensure user-specific state does not leak between accounts.
- Avoid relying on shared global state or arbitrary delays.

### Widget Tests

For new or materially changed interactive widgets/screens, verify relevant:

- Content rendering and user interactions.
- Loading, empty, error, retry, and disabled states.
- Form validation and submission behavior.
- Navigation outcomes.
- Narrow layouts, text scaling, and overflow.
- Accessibility semantics for important controls.

Use focused tests rather than asserting every widget in the implementation.
Golden tests are optional and must not replace interaction tests.

### Integration Tests

Add or update integration coverage when a change affects a critical
end-to-end flow, including:

- Authentication and session handling.
- Practice submission, saved progress, and result review.
- Subscription or question-bank entitlement.
- Coin consumption and purchase fulfilment.
- Answer-sheet upload and AI-job completion.

Test important failures and recovery paths, not only successful completion.
Use a dedicated test environment; never mutate production student data.

### Supabase and Security Tests

When database access or policies change, verify:

- Unauthenticated access restrictions.
- Access to the user's own permitted records.
- Denial of access to another user's records.
- Relevant insert, select, update, and delete permissions.
- Storage access and privileged function authorization.
- Duplicate requests and concurrent operations for balances and quotas.

Mocked client tests do not prove that RLS or server-side enforcement works.
Verify those controls against a local or dedicated test Supabase environment.

### Regression Tests

- For a reproducible bug, add a test that exposes the failure when practical.
- Confirm the test passes after the fix.
- Do not change expected results merely to accommodate a regression.
- Do not delete, skip, or weaken failing tests without a justified explanation.
- Keep tests deterministic; use condition-based waits instead of arbitrary sleeps.

### Coverage and Scope

- Cover changed critical logic and meaningful edge cases.
- Do not chase coverage percentages with trivial assertions.
- Do not add tests that merely mirror implementation details.
- Minor copy or styling changes may use focused visual verification when
  automated tests would add little value.
- Test files follow the same size limits; split them by behavior when needed.

### Completion Gates

Follow the existing mandatory gates:

```bash
dart format .
flutter analyze
flutter test
```

Also run affected integration, database-policy, or device checks when required
by the change.

Report exactly what ran, what passed, what failed, and what remains unverified.
A passing unit-test suite does not establish real-device performance,
payment-provider behavior, or production readiness.