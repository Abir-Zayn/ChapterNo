// Verifies OnboardingCubit: board loading, field tracking, submit guards,
// duplicate-submit prevention, and recoverable network failure handling.
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:chapter_no/feature/profile/domain/entities/onboarding_draft.dart';
import 'package:chapter_no/feature/profile/domain/entities/profile_failure.dart';
import 'package:chapter_no/feature/profile/domain/repositories/profile_repository.dart';
import 'package:chapter_no/feature/profile/screens/cubits/onboarding_cubit.dart';
import 'package:chapter_no/feature/profile/screens/cubits/onboarding_state.dart';
import 'package:dartz/dartz.dart' show Either, Left, Right, Unit, unit;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

const _boards = [
  OnboardingBoard(id: 1, name: 'Dhaka Board'),
  OnboardingBoard(id: 2, name: 'Chittagong Board'),
];

const _board = OnboardingBoard(id: 1, name: 'Dhaka Board');

void main() {
  late _MockProfileRepository repository;

  setUpAll(() {
    registerFallbackValue(
      const OnboardingDraft(
        displayName: 'x',
        batchYear: 2027,
        board: _board,
        academicGroup: 'science',
      ),
    );
  });

  setUp(() {
    repository = _MockProfileRepository();
    when(
      () => repository.getOnboardingBoards(),
    ).thenAnswer((_) async => const Right(_boards));
  });

  group('OnboardingCubit', () {
    blocTest<OnboardingCubit, OnboardingState>(
      'loads education boards',
      build: () => OnboardingCubit(profileRepository: repository),
      act: (cubit) => cubit.loadBoards(),
      expect: () => const [
        OnboardingState(isLoadingBoards: true),
        OnboardingState(boards: _boards),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'ignores repeated board loads while boards are available',
      build: () => OnboardingCubit(profileRepository: repository),
      act: (cubit) async {
        await cubit.loadBoards();
        await cubit.loadBoards();
      },
      expect: () => const [
        OnboardingState(isLoadingBoards: true),
        OnboardingState(boards: _boards),
      ],
      verify: (_) => verify(() => repository.getOnboardingBoards()).called(1),
    );

    test('reports a boards failure and recovers on retry', () async {
      when(
        () => repository.getOnboardingBoards(),
      ).thenAnswer((_) async => const Left(ProfileFailure('offline')));
      final cubit = OnboardingCubit(profileRepository: repository);
      final states = <OnboardingState>[];
      cubit.stream.listen(states.add);
      await cubit.loadBoards();

      when(
        () => repository.getOnboardingBoards(),
      ).thenAnswer((_) async => const Right(_boards));
      await cubit.loadBoards();
      await Future<void>.delayed(Duration.zero);

      expect(states, const [
        OnboardingState(isLoadingBoards: true),
        OnboardingState(boardsError: 'Could not load education boards.'),
        OnboardingState(isLoadingBoards: true),
        OnboardingState(boards: _boards),
      ]);
      await cubit.close();
    });

    blocTest<OnboardingCubit, OnboardingState>(
      'tracks each field update and clears stale action errors',
      build: () => OnboardingCubit(profileRepository: repository),
      act: (cubit) {
        cubit.updateDisplayName('Ta');
        cubit.selectBatchYear(2027);
        cubit.selectBoard(_board);
        cubit.selectAcademicGroup('science');
        cubit.selectLearningPace('intensive');
        cubit.updateDisplayName('Tanvir Ahmed');
      },
      expect: () => const [
        OnboardingState(displayName: 'Ta'),
        OnboardingState(displayName: 'Ta', batchYear: 2027),
        OnboardingState(displayName: 'Ta', batchYear: 2027, board: _board),
        OnboardingState(
          displayName: 'Ta',
          batchYear: 2027,
          board: _board,
          academicGroup: 'science',
        ),
        OnboardingState(
          displayName: 'Ta',
          batchYear: 2027,
          board: _board,
          academicGroup: 'science',
          learningPace: 'intensive',
        ),
        OnboardingState(
          displayName: 'Tanvir Ahmed',
          batchYear: 2027,
          board: _board,
          academicGroup: 'science',
          learningPace: 'intensive',
        ),
      ],
    );

    test('canSubmit stays false until every field is chosen', () {
      final cubit = OnboardingCubit(profileRepository: repository);
      expect(cubit.state.canSubmit, isFalse);
      cubit.updateDisplayName('Tanvir');
      expect(cubit.state.canSubmit, isFalse);
      cubit.selectBatchYear(2027);
      expect(cubit.state.canSubmit, isFalse);
      cubit.selectBoard(_board);
      expect(cubit.state.canSubmit, isFalse);
      cubit.selectAcademicGroup('science');
      expect(cubit.state.canSubmit, isTrue);
    });

    blocTest<OnboardingCubit, OnboardingState>(
      'ignores submit while the form is incomplete',
      build: () => OnboardingCubit(profileRepository: repository),
      act: (cubit) {
        cubit.updateDisplayName('Tanvir');
        cubit.submit();
      },
      expect: () => const [OnboardingState(displayName: 'Tanvir')],
      verify: (_) => verifyNever(() => repository.completeOnboarding(any())),
    );

    test('ignores a duplicate submit while one is in flight', () async {
      final gate = Completer<Either<ProfileFailure, Unit>>();
      when(
        () => repository.completeOnboarding(any()),
      ).thenAnswer((_) => gate.future);
      final cubit = OnboardingCubit(profileRepository: repository);
      cubit
        ..updateDisplayName('Tanvir')
        ..selectBatchYear(2027)
        ..selectBoard(_board)
        ..selectAcademicGroup('science');

      final first = cubit.submit();
      expect(cubit.state.isSubmitting, isTrue);
      await cubit.submit();
      expect(cubit.state.isSubmitting, isTrue);

      gate.complete(const Right(unit));
      await first;
      expect(cubit.state.completed, isTrue);
      verify(() => repository.completeOnboarding(any())).called(1);
      await cubit.close();
    });

    test('keeps entries and explains a save failure', () async {
      when(
        () => repository.completeOnboarding(any()),
      ).thenAnswer((_) async => const Left(ProfileFailure('offline')));
      final cubit = OnboardingCubit(profileRepository: repository);
      cubit
        ..updateDisplayName('Tanvir')
        ..selectBatchYear(2027)
        ..selectBoard(_board)
        ..selectAcademicGroup('science');
      await cubit.submit();

      final failed = cubit.state;
      expect(failed.displayName, 'Tanvir');
      expect(failed.batchYear, 2027);
      expect(failed.board, _board);
      expect(failed.academicGroup, 'science');
      expect(failed.isSubmitting, isFalse);
      expect(failed.completed, isFalse);
      expect(
        failed.actionError,
        'Could not save your profile. Check your connection and try again.',
      );
      await cubit.close();
    });

    test('submits the trimmed draft and completes', () async {
      when(
        () => repository.completeOnboarding(any()),
      ).thenAnswer((_) async => const Right(unit));
      final cubit = OnboardingCubit(profileRepository: repository);
      cubit
        ..updateDisplayName(' Tanvir ')
        ..selectBatchYear(2027)
        ..selectBoard(_board)
        ..selectAcademicGroup('science');
      await cubit.submit();

      expect(cubit.state.completed, isTrue);
      final draft =
          verify(
                () => repository.completeOnboarding(captureAny()),
              ).captured.single
              as OnboardingDraft;
      expect(draft.displayName, 'Tanvir');
      expect(draft.batchYear, 2027);
      expect(draft.board, _board);
      expect(draft.academicGroup, 'science');
      expect(draft.learningPace, 'standard');
      await cubit.close();
    });

    test('drops late responses after close', () async {
      final gate = Completer<Either<ProfileFailure, Unit>>();
      when(
        () => repository.completeOnboarding(any()),
      ).thenAnswer((_) => gate.future);
      final cubit = OnboardingCubit(profileRepository: repository);
      cubit
        ..updateDisplayName('Tanvir')
        ..selectBatchYear(2027)
        ..selectBoard(_board)
        ..selectAcademicGroup('science');
      final submit = cubit.submit();
      await cubit.close();

      gate.complete(const Right(unit));
      await submit;
    });
  });
}
