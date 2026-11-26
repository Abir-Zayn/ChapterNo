// Reusable WidgetTester helpers for Step 1 E2E flows: 360x800 viewport,
// text-scaling overrides, form entry, date-picker selection, and overflow checks.
import 'e2e_test_helpers_imports.dart';

Future<void> pumpE2eApp(
  WidgetTester tester, {
  required FakeAuthRepository authRepository,
  required FakeProfileRepository profileRepository,
  FakeCurriculumCatalogue? curriculum,
  FakeAppPrefsStore? prefs,
  String initialLocation = '/',
  Duration splashMinDisplay = Duration.zero,
  DateTime? today,
  bool enforceOnboardingGate = true,
  Size size = const Size(360, 800),
  double textScale = 1.0,
  TargetPlatform? platform,
}) async {
  tester.platformDispatcher.clearDefaultRouteNameTestValue();
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  if (platform != null) {
    debugDefaultTargetPlatformOverride = platform;
  }
  addTearDown(() {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    tester.platformDispatcher.clearDefaultRouteNameTestValue();
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    debugDefaultTargetPlatformOverride = null;
  });

  await tester.pumpWidget(
    E2eTestApp(
      key: UniqueKey(),
      authRepository: authRepository,
      profileRepository: profileRepository,
      curriculum: curriculum,
      prefs: prefs,
      initialLocation: initialLocation,
      splashMinDisplay: splashMinDisplay,
      today: today,
      enforceOnboardingGate: enforceOnboardingGate,
    ),
  );
}

Future<void> enterAuthField(
  WidgetTester tester,
  String label,
  String text,
) async {
  final column = find
      .ancestor(of: find.text(label), matching: find.byType(Column))
      .first;
  final field = find.descendant(of: column, matching: find.byType(TextField));
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
}

Future<void> pickDefaultDob(WidgetTester tester) async {
  final dobColumn = find
      .ancestor(of: find.text('Date of birth'), matching: find.byType(Column))
      .first;
  final dobField = find.descendant(
    of: dobColumn,
    matching: find.byType(TextField),
  );
  await tester.ensureVisible(dobField);
  await tester.tap(dobField);
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> confirmLogoutDialog(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, 'Log Out'),
    ),
  );
  await tester.pumpAndSettle();
}

void expectNoRenderOverflow(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}
