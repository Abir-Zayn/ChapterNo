// Unit tests for HomeCubit verifying state transitions during dashboard load,
// refresh, and goal progress advancement.
import 'package:bloc_test/bloc_test.dart';
import 'package:chapter_no/feature/home/data/repo/in_memory_home_repository.dart';
import 'package:chapter_no/feature/home/domain/repositories/home_repository.dart';
import 'package:chapter_no/feature/home/screens/cubits/home_cubit.dart';
import 'package:chapter_no/feature/home/screens/cubits/home_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  group('HomeCubit', () {
    late HomeRepository realRepository;

    setUp(() {
      realRepository = InMemoryHomeRepository();
    });

    test('initial state is HomeInitial', () {
      final cubit = HomeCubit(homeRepository: realRepository);
      expect(cubit.state, equals(const HomeInitial()));
      cubit.close();
    });

    blocTest<HomeCubit, HomeState>(
      'loadDashboard emits [HomeLoading, HomeLoaded] on success',
      build: () => HomeCubit(homeRepository: realRepository),
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const HomeLoading(),
        isA<HomeLoaded>().having(
          (s) => s.dashboard.studentName,
          'studentName',
          'Siam',
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'loadDashboard emits [HomeLoading, HomeError] when repository fails',
      build: () {
        final mockRepo = MockHomeRepository();
        when(
          () => mockRepo.getDashboard(),
        ).thenAnswer((_) async => const Left('Failed to fetch dashboard data'));
        return HomeCubit(homeRepository: mockRepo);
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        const HomeLoading(),
        const HomeError(message: 'Failed to fetch dashboard data'),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'refreshDashboard emits HomeLoaded directly without HomeLoading',
      build: () => HomeCubit(homeRepository: realRepository),
      act: (cubit) => cubit.refreshDashboard(),
      expect: () => [isA<HomeLoaded>()],
    );

    blocTest<HomeCubit, HomeState>(
      'advanceDailyGoal increments completed questions in daily target',
      build: () => HomeCubit(homeRepository: realRepository),
      act: (cubit) async {
        await cubit.loadDashboard();
        await cubit.advanceDailyGoal();
      },
      skip: 2,
      expect: () => [
        isA<HomeLoaded>().having(
          (s) => s.dashboard.dailyGoal.completedQuestions,
          'completedQuestions',
          16,
        ),
      ],
    );
  });
}
