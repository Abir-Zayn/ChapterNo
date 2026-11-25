// Unit tests for InMemoryHomeRepository verifying dashboard data delivery
// and daily goal completion progression.
import 'package:chapter_no/feature/home/data/repo/in_memory_home_repository.dart';
import 'package:chapter_no/feature/home/domain/entities/daily_goal.dart';
import 'package:chapter_no/feature/home/domain/entities/student_dashboard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryHomeRepository', () {
    late InMemoryHomeRepository repository;

    setUp(() {
      repository = InMemoryHomeRepository();
    });

    test(
      'getDashboard returns default student data with streak and targets',
      () async {
        final result = await repository.getDashboard();
        expect(result.isRight(), isTrue);

        final dashboard = result.getOrElse(() => throw 'Unexpected left');
        expect(dashboard.studentName, equals('Siam'));
        expect(dashboard.currentStreakDays, equals(7));
        expect(dashboard.chapterCoins, equals(120));
        expect(dashboard.subjects.length, equals(4));
        expect(dashboard.recentActivities.length, equals(3));
        expect(dashboard.dailyGoal.completedQuestions, equals(15));
        expect(dashboard.dailyGoal.totalQuestions, equals(20));
      },
    );

    test(
      'incrementGoalProgress increases completed questions up to total',
      () async {
        final first = await repository.incrementGoalProgress();
        expect(first.isRight(), isTrue);
        expect(
          first.getOrElse(() => throw 'err').dailyGoal.completedQuestions,
          equals(16),
        );

        // Verify clamping when target reached
        final customRepo = InMemoryHomeRepository(
          initialData: StudentDashboard(
            studentName: 'Test',
            cohortTitle: 'SSC',
            currentStreakDays: 1,
            chapterCoins: 10,
            dailyGoal: const DailyGoal(
              id: 'g1',
              subjectName: 'Physics',
              chapterTitle: 'Ch 1',
              totalQuestions: 10,
              completedQuestions: 10,
              targetMinutes: 30,
              completedMinutes: 30,
            ),
            activeSession: (await repository.getDashboard())
                .getOrElse(() => throw 'err')
                .activeSession,
            subjects: const [],
            recentActivities: const [],
          ),
        );

        final clamped = await customRepo.incrementGoalProgress();
        expect(
          clamped.getOrElse(() => throw 'err').dailyGoal.completedQuestions,
          equals(10),
        );
      },
    );
  });
}
