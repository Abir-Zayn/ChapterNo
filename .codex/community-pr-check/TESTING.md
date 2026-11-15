# ChapterNo — Flutter Testing Guide

Updated: 2026-11-12. Applies to Flutter Android/iOS, Bloc/Cubit, Supabase, and every coding agent working on ChapterNo.

Read alongside `AGENTS.md` and `DESIGN.md`. This guide defines testing practice; it does not authorize changes to business rules or imply that the application has passed any tests.

## 1. Testing Principles

- Test observable behavior, business outcomes, and recovery from failure.
- Use Arrange → Act → Assert. Name tests by scenario and expected outcome.
- For reproducible bugs, add a regression test that fails before the fix where practical.
- Keep tests independent and deterministic: isolate state, inject dependencies, control time, and use synthetic data.
- Mock external boundaries, not the business logic being tested.
- Use many focused unit/widget tests and selected integration tests for critical journeys. Do not duplicate every assertion at every level.
- Never replace assertions with console output, screenshots alone, or “it compiled.”
- Do not weaken assertions, suppress errors, skip failing tests, or regenerate goldens merely to make CI green.- Read TESTING.md before writing tests or debugging application behavior.
- For low-impact copy/style changes, use focused visual verification when new automated tests would add little value.
- Follow repository naming, 2–3 line purpose headers, separate dependency files, and code-size rules. Split test files by behavior before 300 lines; do not pad short files.

## 2. Choose the Right Evidence

| Method | What it verifies | ChapterNo examples |
|---|---|---|
| Unit test | Isolated rules and transformations | Scoring, validation, quota calculations, serialization |
| Bloc/Cubit test | State sequences and dependency interactions | Loading practice, retry, duplicate submission protection |
| Widget test | Rendered states and interactions | Answer selection, form errors, disabled submit, retry button |
| Integration test | Connected application flow | Sign-in → practice → result → saved history |
| Backend/policy test | Actual server enforcement | RLS ownership, atomic coin debit, duplicate webhook handling |
| Manual device check | Native/system behavior and usability | Camera permission, keyboard, background/resume, purchase sheet |
| Profile measurement | Frame timing and resource behavior | Scrolling, image uploads, repeated navigation |
| Debug logging | Diagnostic clues for a hypothesis | Request duplication, stale responses, lifecycle order |

## 3. Dependencies and Organization

Use repository-compatible versions from `pubspec.yaml` and the lockfile. Add missing tools to `dev_dependencies`; do not upgrade the application stack solely to write tests.

```yaml
# Merge into the existing dev_dependencies section.
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  # Add compatible bloc_test and mocktail constraints via pub.
```

If absent, add the two packages with `flutter pub add --dev bloc_test mocktail`, inspect the dependency diff, and commit the lockfile under the repository's normal policy. Mocktail requires no generated mocks or build_runner step.

| Location | Purpose |
|---|---|
| `test/feature/<feature>/domain/` | Use case and domain rule tests |
| `test/feature/<feature>/data/` | Repository, mapping, and data-source tests |
| `test/feature/<feature>/screens/cubits/` | Cubit behavior tests |
| `test/feature/<feature>/screens/blocs/` | Bloc event/state tests |
| `test/feature/<feature>/screens/widgets/` | Page and extracted-widget tests |
| `test/shared/` | Shared component tests |
| `test/support/` | Small mocks, fixtures, and test harnesses |
| `integration_test/` | Critical application journeys |

Keep dependency barrels narrow. Use real test data models where possible; do not create production abstractions merely to support a test helper.

## 4. Debugging with debugPrint

`debugPrint` can write in release mode. Guard development diagnostics with `kDebugMode`. Console output helps explain execution; assertions establish whether the behavior is correct.

Example snippet; expose `flutter/foundation.dart` through the file's dependency barrel:

```dart
// Reports a small, sanitized diagnostic for a practice-loading operation.
// Never receives student content, credentials, or raw API responses.
void tracePracticeLoad({required String stage, int? itemCount}) {
  if (!kDebugMode) return;
  debugPrint('[Practice.load] stage=$stage count=${itemCount ?? "unknown"}');
}
```

Use a small allowlist of diagnostic fields: operation, stage, safe error code, result count, elapsed time, and a non-identifying request correlation value when needed.

Never log passwords, tokens, authorization headers, service keys, emails, phone numbers, signed URLs, payment details, student answers, chat messages, image bytes, or complete request/response bodies. Avoid raw `state.toString()` and `error.toString()`; they can contain sensitive content. Debug mode is not permission to expose private data.

### Diagnostic Workflow

1. Reproduce the issue and record the exact interaction and expected result.
2. State a hypothesis, such as “reopening the page starts two requests.”
3. Add narrow guarded logs at request start/completion and relevant lifecycle boundaries.
4. Reproduce once and compare the observed sequence with the hypothesis.
5. Use debugger breakpoints and the call stack when logs are insufficient.
6. Fix the cause, add an appropriate regression assertion, then reproduce again.
7. Remove temporary prints or retain only useful, sanitized, guarded diagnostics.

Do not print on every animation frame or every widget build as permanent instrumentation. Excessive logs obscure ordering and can disturb performance. A Stopwatch around a request measures that operation's elapsed time, not frame rendering or memory leakage. The default debug printer is throttled; do not infer precise timing from when messages appear.

### BlocObserver Diagnostics

Use a temporary debug observer to inspect transitions/lifecycle without dumping payloads. Example snippet; dependencies are `flutter/foundation.dart` and `bloc/bloc.dart` (or the repository's compatible re-export):

```dart
// Observes state types and lifecycle boundaries during local debugging.
// Omits state values, event payloads, and raw exception messages.
class DebugBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      debugPrint('[${bloc.runtimeType}] '
          '${change.currentState.runtimeType} -> '
          '${change.nextState.runtimeType}');
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (kDebugMode) {
      debugPrint('[${bloc.runtimeType}] errorType=${error.runtimeType}');
    }
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    if (kDebugMode) debugPrint('[${bloc.runtimeType}] closed');
  }
}
```

Install only during debug bootstrap. Preserve any existing observer/error reporting instead of silently replacing it. Type-only logs are deliberately limited; use a safe explicit status field when states share a type. A close log is not proof that all resources were released.

If a test replaces global `debugPrint`, `Bloc.observer`, or error handlers, save and restore the original in teardown. Never swallow Flutter errors to hide test failures. Production error reporting needs a separate approved, sanitized reporting path.

## 5. Proper bloc_test Usage

- Test a real Cubit/Bloc with mocked or fake dependencies.
- `build` creates a fresh instance; `act` invokes a method or adds an event; `expect` checks emitted states in order; `verify` checks relevant interactions.
- `blocTest` closes the instance it creates. Close manually created instances in ordinary tests yourself.
- Assert the initial state separately. Initial/seeded states are not automatically part of the expected emission sequence.
- Use immutable state equality or precise matchers that check meaningful fields, not just types.
- Use `seed` only for a valid scenario; do not construct an impossible state to bypass behavior.
- Avoid `skip` unless the ignored emissions are intentionally outside the test's scope.
- Use `errors` for reported/thrown errors. A caught failure emitted as application state belongs in `expect`.
- Reserve `wait` for known time-dependent behavior such as debounce, not unexplained test failures.

### Example: Cubit and Repository Boundary

The following four files form an isolated teaching example, not existing ChapterNo implementation. Place them together in a scratch test folder if trying them. They demonstrate state sequencing and Mocktail without relying on undocumented project classes. For production, test the real domain use case/repository contracts and real failure mapping.

`practice_fixture_imports.dart`:

```dart
// Exposes only the dependencies needed by the practice fixture.
// This barrel belongs to the isolated example, not production architecture.
export 'package:flutter_bloc/flutter_bloc.dart';
```

`practice_fixture.dart`:

```dart
// Models a minimal asynchronous load operation for testing examples.
// The integer response represents a count; it is not a product quota.
import 'practice_fixture_imports.dart';

abstract class PracticeRepository {
  Future<int> loadCount({required String chapterId});
}

enum PracticeStatus { idle, loading, ready, failed }

class PracticeCubit extends Cubit<PracticeStatus> {
  PracticeCubit(this.repository) : super(PracticeStatus.idle);
  final PracticeRepository repository;

  Future<void> load(String chapterId) async {
    if (isClosed || state == PracticeStatus.loading) return;
    emit(PracticeStatus.loading);
    try {
      await repository.loadCount(chapterId: chapterId);
      if (!isClosed) emit(PracticeStatus.ready);
    } catch (_) {
      if (!isClosed) emit(PracticeStatus.failed);
    }
  }
}
```

`practice_cubit_test_imports.dart`:

```dart
// Provides the fixture, test APIs, and controlled async primitives.
// Keeps test dependencies explicit and local to this example.
export 'dart:async';
export 'package:bloc_test/bloc_test.dart';
export 'package:flutter_test/flutter_test.dart';
export 'package:mocktail/mocktail.dart';
export 'practice_fixture.dart';
```

`practice_cubit_test.dart`:

```dart
// Verifies loading, failure recovery, and duplicate-request protection.
// External responses are controlled through a fresh Mocktail repository.
import 'practice_cubit_test_imports.dart';

class MockPracticeRepository extends Mock implements PracticeRepository {}

void main() {
  late MockPracticeRepository repository;
  setUp(() => repository = MockPracticeRepository());

  test('starts idle', () async {
    final cubit = PracticeCubit(repository);
    addTearDown(cubit.close);
    expect(cubit.state, PracticeStatus.idle);
    verifyZeroInteractions(repository);
  });

  blocTest<PracticeCubit, PracticeStatus>(
    'emits loading then ready for a successful load',
    setUp: () {
      when(() => repository.loadCount(chapterId: 'physics-1'))
          .thenAnswer((_) async => 10);
    },
    build: () => PracticeCubit(repository),
    act: (cubit) => cubit.load('physics-1'),
    expect: () => [PracticeStatus.loading, PracticeStatus.ready],
    verify: (_) {
      verify(() => repository.loadCount(chapterId: 'physics-1')).called(1);
    },
  );

  blocTest<PracticeCubit, PracticeStatus>(
    'emits failure then recovers when retried',
    build: () => PracticeCubit(repository),
    act: (cubit) async {
      when(() => repository.loadCount(chapterId: 'physics-1'))
          .thenAnswer((_) async => throw StateError('test failure'));
      await cubit.load('physics-1');
      when(() => repository.loadCount(chapterId: 'physics-1'))
          .thenAnswer((_) async => 10);
      await cubit.load('physics-1');
    },
    expect: () => [
      PracticeStatus.loading, PracticeStatus.failed,
      PracticeStatus.loading, PracticeStatus.ready,
    ],
    verify: (_) {
      verify(() => repository.loadCount(chapterId: 'physics-1')).called(2);
    },
  );

  test('ignores a duplicate request while loading', () async {
    final pending = Completer<int>();
    when(() => repository.loadCount(chapterId: 'physics-1'))
        .thenAnswer((_) => pending.future);
    final cubit = PracticeCubit(repository);
    addTearDown(cubit.close);
    final first = cubit.load('physics-1');
    try {
      expect(cubit.state, PracticeStatus.loading);
      await cubit.load('physics-1');
      verify(() => repository.loadCount(chapterId: 'physics-1')).called(1);
    } finally {
      pending.complete(10);
      await first;
    }
    expect(cubit.state, PracticeStatus.ready);
  });
}
```

For event-driven Bloc, dispatch events in `act`. `add()` does not await processing: subscribe before dispatch and await an observable completion state when sequencing multiple events. Test concurrent, restartable, sequential, or droppable behavior according to the feature contract. Cancelling a state handler does not necessarily cancel the underlying network request.

## 6. Proper Mocktail Usage

- Declare mocks with `class MockX extends Mock implements X {}`. Create fresh instances in `setUp`.
- Stub synchronous results with `thenReturn`; async results with `thenAnswer((_) async => value)`.
- Stub `Future<void>` with `thenAnswer((_) async {})`; unstubbed non-nullable async methods can fail unexpectedly.
- Use exact arguments when significant. For named matchers, include the name: `any(named: 'chapterId')`.
- Register a fallback once per custom argument type in `setUpAll` before using `any<T>()` or `captureAny<T>()`.
- Verify relevant calls/counts and inspect captured arguments. Already verified calls are excluded from later verification counts.
- `reset(mock)` clears stubs and interactions; fresh mocks are usually clearer.
- Mocktail does not replace static/extension behavior. Wrap external behavior behind an injected instance boundary when needed.

Custom-type example fragment (requires the real project types):

```dart
// Register once before matching a custom argument type.
setUpAll(() => registerFallbackValue(const SubmitAnswer(
  questionId: 'fixture-question', selectedOption: 'A',
)));

when(() => repository.submit(any<SubmitAnswer>()))
    .thenAnswer((_) async {});

// Exercise the real use case/Cubit before verification.
final captured = verify(
  () => repository.submit(captureAny<SubmitAnswer>()),
).captured.single as SubmitAnswer;
expect(captured.questionId, 'expected-question');
```

Use an actual harmless value or a `Fake implements Type` when appropriate. A fallback satisfies matching; it is not the response stub. Prefer an in-memory fake when realistic stateful behavior is easier to express than many mocks. Do not mock the Cubit while claiming to test its logic.

## 7. Widget Tests and Mock Cubits

- Test extracted widgets independently with typed data/callbacks, then test the page wiring.
- Cover initial/loading/data/empty/error states and user actions that matter.
- Verify validation, disabled actions, repeated taps, retry, navigation, and listener-triggered feedback.
- Prefer stable keys, text, and semantics to brittle widget-tree positions.
- Use a real Cubit with fake dependencies for behavior coverage; use `MockCubit`/`whenListen` to isolate rendering.
- `whenListen` keeps the mock's current state aligned with its stream; set an initial state explicitly.
- Stub any methods called by the widget, including async actions. A canned state stream does not implement those methods.
- `BlocProvider.value` does not close the supplied instance; the test owns cleanup. `BlocProvider(create: ...)` owns instances it creates.

Example pattern, using the fixture types above and the application's actual widget:

```dart
class MockPracticeCubit extends MockCubit<PracticeStatus>
    implements PracticeCubit {}

// Inside testWidgets; expose flutter/material.dart and flutter_bloc via barrel.
final cubit = MockPracticeCubit();
final states = StreamController<PracticeStatus>();
addTearDown(() async {
  await states.close();
  await cubit.close();
});
whenListen(cubit, states.stream, initialState: PracticeStatus.idle);
when(() => cubit.load(any())).thenAnswer((_) async {});

// Pump your real widget inside MaterialApp and BlocProvider.value(value: cubit).
// Tap its action; verify load(...) was called with the expected chapter.
states.add(PracticeStatus.loading);
await tester.pump();
// Assert the loading UI and disabled action using the widget's real finders.
states.add(PracticeStatus.failed);
await tester.pump();
// Assert the error and retry UI. Unmount the widget before test cleanup.
```

This is a wiring pattern, not a complete widget test: replace comments with the actual widget, actions, and assertions. Without those assertions it provides no UI coverage.

Use `pump()` to advance frames and `pump(duration)` for intentional animation/timer progression. Avoid indiscriminate `pumpAndSettle()` when infinite progress animations are active. Do not hide timeout failures with larger delays. Restore viewport/text-scale overrides after each test.

Test small and large phone widths, supported tablets/landscape, keyboard insets, long questions, and enlarged text. Check overflow errors and semantics. Goldens may guard visual consistency but must not freeze known Stitch design defects or replace interaction/accessibility checks.

## 8. Async, Lifecycle, and Resource Tests

- Use Completers or controlled streams to exercise slow responses, cancellation, and ordering.
- Subscribe before triggering events; use bounded state-based waits with a useful timeout.
- Inject a clock for daily quota/streak boundaries; avoid depending on today's date.
- Test sign-out/account switching while work is pending so the old user's data cannot reappear.
- Test close/navigation while requests are pending; reject late emissions and cancel work when supported.
- Verify owned stream subscriptions, timers, and Realtime channels are released. Shared resources must remain under their original owner's control.
- Exercise retry after failure, double taps, pagination overlap, and obsolete search responses when relevant.
- Ensure all tests clean up containers, subscriptions, controllers, and manually owned Blocs/Cubits even after assertion failures.

## 9. ChapterNo Integration and Backend Checks

Use isolated local/staging services and synthetic accounts, with deterministic setup/cleanup. Do not run destructive tests on production or charge real students.

| Flow | Important scenarios |
|---|---|
| Authentication | Success/failure, expired session, sign-out, account switch, private cache clearing |
| Practice | Select/submit, correct score, review, save/resume, duplicate submission |
| Timed/ranked | Configured attempt limit, deadline, interruption, no premature answer disclosure |
| CQ upload/AI | Permission denial, invalid/large upload, network loss, pending/failure/retry, estimated marks |
| Coins/quotas | Exhaustion, concurrent requests, duplicate jobs, failed-job reservation/refund behavior |
| Purchases | Sandbox success/cancel/pending, duplicate receipt/webhook, verified fulfilment, restore where supported |
| Community | Private/public boundaries, upload failure, report/block behavior when implemented |

Mocked Flutter tests do not validate RLS, Storage policies, SQL transactions, or webhook verification. Test server enforcement with unauthenticated access, user A, and user B across permitted/denied operations. Do not use a service-role client to prove ordinary-user access policies. Verify idempotency and concurrent debit/credit on the backend itself.

Native permission dialogs, purchase UI, and some system interactions need suitable native automation or explicit manual device checks; ordinary widget tests cannot establish them. Report which integrations used fakes and which reached real test services.

## 10. Device Performance and Memory Checks

Profile performance on a representative physical Android device and supported iOS hardware. Use profile mode for measurements; use debug mode for diagnosis and release builds for relevant shipping smoke checks.

1. Record device, OS, build, scenario, dataset, and refresh rate.
2. Warm up the relevant flow; separately record cold-start behavior when relevant.
3. Inspect UI/raster frame timings in DevTools during scrolling, navigation, image work, and transitions.
4. Compare against the device's frame budget (approximately 16.7ms at 60Hz or 8.3ms at 120Hz), using slow-frame counts/timing distributions rather than a claimed universal FPS.
5. Investigate excessive rebuilds, synchronous computation, oversized image decoding, or expensive paint work; verify the fix under comparable conditions.
6. For memory, repeat enter/use/exit cycles, compare heap snapshots after collection, and inspect retaining paths for objects expected to be released.
7. Distinguish bounded cache growth and normal GC variation from sustained retained-object growth. Also consider native/image memory beyond the Dart heap.

Unit tests, close logs, and a single flat memory sample cannot prove leak freedom. Report the scenarios actually measured and remaining concerns. Keep temporary diagnostic logging out of benchmark comparisons.

## 11. Commands and Completion Gates

From the repository root, following existing flavor/environment scripts:

```bash
# Required local gates from AGENTS.md.
dart format .
flutter analyze
flutter test

# Targeted tests and coverage when useful.
flutter test test/feature/practice/
flutter test --coverage

# Requires a configured test target and connected test device.
flutter test integration_test/app_test.dart -d <device-id>

# Device diagnostics; supply the project's flavor/entrypoint flags if required.
flutter run --profile -d <device-id>
flutter logs -d <device-id>
```

Paths and device IDs above are examples; use existing repository paths. CI should check formatting without mutation (`dart format --output=none --set-exit-if-changed .`), analysis, and the automated suite. Keep backend and device gates explicit so a unit-only run is not mistaken for full validation.

Inspect coverage for untested important branches; do not invent an arbitrary percentage target or add meaningless assertions. A flaky test needs an identified cause, not automatic reruns until green.

Before completing a task, state: behavior changed, tests added/updated, exact checks/results, device/build details if measured, and untested integrations/blockers. Never claim “all tests passed” when a required command failed or was not run.

## 12. References and Example Status

API details checked against primary documentation on 2026-11-12:

- [bloc_test](https://pub.dev/packages/bloc_test)
- [Mocktail](https://pub.dev/packages/mocktail)
- [Flutter debugPrint](https://api.flutter.dev/flutter/foundation/debugPrint.html)
- [Flutter testing overview](https://docs.flutter.dev/testing/overview)
- [Flutter DevTools performance](https://docs.flutter.dev/tools/devtools/performance)

The snippets are instructional examples, not tests executed against ChapterNo. No app repository or Flutter/Dart executable was available while preparing this guide. Validate the examples against the project's pinned SDK/packages before adopting them. Keep this file named `TESTING.md` and reference it from `AGENTS.md` for testing tasks.
