// Verifies the Onboarding page flow: full selection completion, entry
// preservation on save failure, and a disabled save button while submitting.
import 'dart:async';

import 'package:chapter_no/feature/profile/domain/entities/onboarding_draft.dart';
import 'package:chapter_no/feature/profile/domain/entities/profile_failure.dart';
import 'package:chapter_no/feature/profile/domain/repositories/profile_repository.dart';
import 'package:chapter_no/feature/profile/screens/cubits/onboarding_cubit.dart';
import 'package:chapter_no/feature/profile/screens/onboarding_page.dart';
import 'package:dartz/dartz.dart' show Either, Left, Right, Unit, unit;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

const _boards = [
  OnboardingBoard(id: 1, name: 'Dhaka Board'),
  OnboardingBoard(id: 2, name: 'Chittagong Board'),
];

Future<void> pumpOnboarding(
  WidgetTester tester, {
  required ProfileRepository repository,
  required VoidCallback onCompleted,
  double width = 400,
  double textScale = 1,
}) {
  return tester.pumpApp(
    BlocProvider(
      create: (_) =>
          OnboardingCubit(profileRepository: repository)..loadBoards(),
      child: OnboardingPage(onCompleted: onCompleted),
    ),
    width: width,
    textScale: textScale,
  );
}

void main() {
  late _MockProfileRepository repository;
  var completed = false;

  setUpAll(() {
    registerFallbackValue(
      const OnboardingDraft(
        displayName: 'x',
        batchYear: 2027,
        board: OnboardingBoard(id: 1, name: 'Dhaka Board'),
        academicGroup: 'science',
      ),
    );
  });

  setUp(() {
    repository = _MockProfileRepository();
    completed = false;
    when(
      () => repository.getOnboardingBoards(),
    ).thenAnswer((_) async => const Right(_boards));
    when(
      () => repository.completeOnboarding(any()),
    ).thenAnswer((_) async => const Right(unit));
  });

  Future<void> scrollToAndTap(WidgetTester tester, Finder finder) async {
    final list = find.byType(ListView);
    // ListView only builds a 250px cache ahead of the viewport, so a target
    // far down a tall form may not exist yet; coarse-drag first, then
    // dragUntilVisible brings it fully on screen for a reliable tap.
    for (var i = 0; i < 12 && finder.evaluate().isEmpty; i++) {
      await tester.drag(list, const Offset(0, -200));
      await tester.pumpAndSettle();
    }
    await tester.dragUntilVisible(finder, list, const Offset(0, -100));
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> fillEveryField(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField), 'Tanvir Ahmed');
    await tester.pump();
    await scrollToAndTap(tester, find.text('SSC 2027'));
    await scrollToAndTap(tester, find.text('Select your board'));
    await tester.tap(find.text('Dhaka Board'));
    await tester.pumpAndSettle();
    await scrollToAndTap(tester, find.text('Science'));
  }

  testWidgets('completes the flow at 360px and 1.3x text scale', (
    tester,
  ) async {
    await pumpOnboarding(
      tester,
      repository: repository,
      onCompleted: () => completed = true,
      width: 360,
      textScale: 1.3,
    );
    await tester.pumpAndSettle();

    expect(find.text('Set up your learning profile'), findsOneWidget);
    expect(find.text('SSC 2026'), findsOneWidget);

    await fillEveryField(tester);
    await scrollToAndTap(tester, find.text('Save and continue'));

    expect(find.text('Business Studies'), findsOneWidget);
    expect(find.text('Humanities'), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);

    expect(completed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps entries and explains a save failure', (tester) async {
    when(
      () => repository.completeOnboarding(any()),
    ).thenAnswer((_) async => const Left(ProfileFailure('offline')));
    await pumpOnboarding(
      tester,
      repository: repository,
      onCompleted: () => completed = true,
    );
    await tester.pumpAndSettle();

    await fillEveryField(tester);
    await tester.ensureVisible(find.text('Save and continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save and continue'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not save your profile'), findsOneWidget);
    // The failed save leaves the list scrolled to the bottom; scroll back up
    // so the entry fields are built again before asserting their values.
    await tester.dragUntilVisible(
      find.byType(TextFormField),
      find.byType(ListView),
      const Offset(0, 150),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tanvir Ahmed'), findsOneWidget);
    expect(find.text('Dhaka Board'), findsOneWidget);
    expect(find.text('SSC 2027'), findsOneWidget);
    expect(completed, isFalse);
  });

  testWidgets('blocks the save button while submitting', (tester) async {
    final gate = Completer<Either<ProfileFailure, Unit>>();
    when(
      () => repository.completeOnboarding(any()),
    ).thenAnswer((_) => gate.future);
    await pumpOnboarding(
      tester,
      repository: repository,
      onCompleted: () => completed = true,
    );
    await tester.pumpAndSettle();

    await fillEveryField(tester);
    await tester.ensureVisible(find.text('Save and continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save and continue'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(completed, isFalse);

    gate.complete(const Right(unit));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
  });
}
