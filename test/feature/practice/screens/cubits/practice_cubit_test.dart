// Unit tests for PracticeCubit verifying dashboard state transitions,
// quiz session resumption, and review actions.
import 'package:bloc_test/bloc_test.dart';
import 'package:chapter_no/feature/practice/data/repo/in_memory_practice_repository.dart';
import 'package:chapter_no/feature/practice/domain/repositories/practice_repository.dart';
import 'package:chapter_no/feature/practice/screens/cubits/practice_cubit.dart';
import 'package:chapter_no/feature/practice/screens/cubits/practice_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPracticeRepository extends Mock implements PracticeRepository {}

void main() {
  group('PracticeCubit', () {
    late PracticeRepository repository;

    setUp(() {
      repository = InMemoryPracticeRepository();
    });

    test('initial state is PracticeInitial', () {
      final cubit = PracticeCubit(practiceRepository: repository);
      expect(cubit.state, equals(const PracticeInitial()));
      cubit.close();
    });

    blocTest<PracticeCubit, PracticeState>(
      'loadDashboard emits [PracticeLoading, PracticeLoaded] on success',
      build: () => PracticeCubit(practiceRepository: repository),
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const PracticeLoading(),
        isA<PracticeLoaded>().having(
          (s) => s.data.overview.mcqsSolved,
          'overview.mcqsSolved',
          120,
        ),
      ],
    );

    blocTest<PracticeCubit, PracticeState>(
      'loadDashboard emits [PracticeLoading, PracticeError] on failure',
      build: () {
        final mockRepo = MockPracticeRepository();
        when(
          () => mockRepo.getPracticeDashboard(),
        ).thenAnswer((_) async => const Left('Failed to load practice data'));
        return PracticeCubit(practiceRepository: mockRepo);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const PracticeLoading(),
        const PracticeError(message: 'Failed to load practice data'),
      ],
    );

    blocTest<PracticeCubit, PracticeState>(
      'resumeQuiz updates quiz session progress',
      build: () => PracticeCubit(practiceRepository: repository),
      act: (cubit) async {
        await cubit.loadDashboard();
        await cubit.resumeQuiz('quiz-bio-cell');
      },
      skip: 2,
      expect: () => [
        isA<PracticeLoaded>().having(
          (s) => s.data.recentActivities
              .firstWhere((a) => a.id == 'quiz-bio-cell')
              .progressLabel,
          'progressLabel',
          'Question 7 of 20',
        ),
      ],
    );
  });
}
