// Unit tests for InMemoryPracticeRepository verifying practice data delivery,
// quiz session progress resumption, and mode availability.
import 'package:chapter_no/feature/practice/data/repo/in_memory_practice_repository.dart';
import 'package:chapter_no/feature/practice/domain/entities/practice_mode_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryPracticeRepository', () {
    late InMemoryPracticeRepository repository;

    setUp(() {
      repository = InMemoryPracticeRepository();
    });

    test(
      'getPracticeDashboard returns standard SSC practice data and Stitch modes',
      () async {
        final result = await repository.getPracticeDashboard();
        expect(result.isRight(), isTrue);

        final data = result.getOrElse(() => throw 'Unexpected left');
        expect(data.overview.mcqsSolved, equals(120));
        expect(data.overview.accuracyPercentage, equals(82));
        expect(data.overview.accuracyDelta, equals('+4%'));
        expect(data.overview.quizzesCompleted, equals(8));
        expect(data.recentActivities.length, equals(2));
        expect(
          data.recentActivities.first.fullTitle,
          equals('Physics — Motion'),
        );
        expect(data.practiceModes.length, equals(4));
        expect(
          data.practiceModes.any(
            (m) => m.modeType == PracticeModeType.topicMcq,
          ),
          isTrue,
        );
        expect(
          data.practiceModes.any(
            (m) => m.modeType == PracticeModeType.rankedQuiz,
          ),
          isTrue,
        );
        expect(data.milestone.remainingMcqs, equals(15));
      },
    );

    test('resumeQuiz updates in-progress quiz progress label', () async {
      final result = await repository.resumeQuiz('quiz-bio-cell');
      expect(result.isRight(), isTrue);

      final updated = result.getOrElse(() => throw 'err');
      final bioQuiz = updated.recentActivities.firstWhere(
        (a) => a.id == 'quiz-bio-cell',
      );
      expect(bioQuiz.progressLabel, equals('Question 7 of 20'));
    });
  });
}
