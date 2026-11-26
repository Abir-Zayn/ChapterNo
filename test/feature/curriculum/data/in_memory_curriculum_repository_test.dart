// Verifies InMemoryCurriculumRepository default fixtures, filtering, sorting,
// and configurable overrides for empty, error, and delayed loading states.
import 'in_memory_curriculum_repository_test_imports.dart';

EducationBoard _b(int id, String c, int o, {bool on = true}) => EducationBoard(
  id: id,
  code: c,
  nameEn: '$c Board',
  nameBn: '$c বোর্ড',
  sortOrder: o,
  isActive: on,
);

Subject _s(
  int id,
  String c,
  String g,
  int o, {
  String r = 'cleared',
  bool on = true,
}) => Subject(
  id: id,
  code: c,
  academicGroupCode: g,
  titleEn: c,
  titleBn: c,
  syllabusVersion: 'NCTB-SSC-2026',
  rightsStatus: r,
  sortOrder: o,
  isActive: on,
);

Chapter _c(int id, int sid, int n, int o, {bool on = true}) => Chapter(
  id: id,
  subjectId: sid,
  chapterNumber: n,
  titleEn: 'C$n',
  titleBn: 'অ$n',
  sortOrder: o,
  isActive: on,
);

Topic _t(
  int id,
  int cid,
  int n,
  int o, {
  String r = 'cleared',
  bool on = true,
}) => Topic(
  id: id,
  chapterId: cid,
  topicNumber: n,
  titleEn: 'T$n',
  titleBn: 'ট$n',
  rightsStatus: r,
  sortOrder: o,
  isActive: on,
);

T _right<T>(Either<CurriculumFailure, T> either) =>
    either.getOrElse(() => throw StateError('Expected Right, got $either'));

void main() {
  group('InMemoryCurriculumRepository defaults', () {
    late InMemoryCurriculumRepository repo;
    setUp(() => repo = InMemoryCurriculumRepository());

    test('implements CurriculumRepository with 11 active boards', () async {
      expect(repo, isA<CurriculumRepository>());
      final boards = _right(await repo.getEducationBoards());

      expect(boards, hasLength(11));
      expect(boards.first.code, 'dhaka');
      expect(boards[1].code, 'chittagong');
      expect(boards[2].code, 'rajshahi');
      expect(boards.last.code, 'technical');
      expect(boards.every((b) => b.isActive && b.nameBn.isNotEmpty), isTrue);
    });

    test(
      'returns common + cleared group subjects sorted by sortOrder',
      () async {
        final sci = _right(
          await repo.getSubjectsForGroup(AcademicGroup.science),
        );
        expect(sci.map((s) => s.code), <String>[
          'ssc_bangla_1st_101',
          'ssc_bangla_2nd_102',
          'ssc_english_1st_107',
          'ssc_english_2nd_108',
          'ssc_mathematics_109',
          'ssc_ict_154',
          'ssc_physics_136',
          'ssc_chemistry_137',
          'ssc_biology_138',
          'ssc_higher_math_126',
          'ssc_bgs_150',
        ]);

        final bus = _right(
          await repo.getSubjectsForGroup(AcademicGroup.businessStudies),
        );
        expect(bus.map((s) => s.code), contains('ssc_accounting_146'));
        expect(
          bus.map((s) => s.code),
          isNot(contains('ssc_finance_banking_152')),
        );

        final hum = _right(
          await repo.getSubjectsForGroup(AcademicGroup.humanities),
        );
        expect(hum.map((s) => s.code), contains('ssc_history_153'));
        expect(hum.map((s) => s.code), isNot(contains('ssc_geography_110')));
      },
    );

    test('returns chapters and only cleared active topics', () async {
      final chapters = _right(await repo.getChaptersForSubject(136));
      expect(chapters.map((c) => c.chapterNumber), <int>[1, 2, 3]);
      expect(
        chapters.every((c) => c.titleEn.isNotEmpty && c.titleBn.isNotEmpty),
        isTrue,
      );

      final topics = _right(await repo.getTopicsForChapter(1362));
      expect(topics.map((t) => t.topicNumber), <int>[1, 2, 3]);
      expect(topics.every((t) => t.isCleared), isTrue);
      expect(_right(await repo.getTopicsForChapter(1542)), isEmpty);
    });
  });

  group('InMemoryCurriculumRepository overrides', () {
    test(
      'filters inactive/draft records and sorts deterministically',
      () async {
        final repo = InMemoryCurriculumRepository(
          boards: [
            _b(9, 'late', 2),
            _b(3, 'off', 1, on: false),
            _b(5, 'b', 1),
            _b(2, 'a', 1),
          ],
          subjects: [
            _s(4, 'sci_2', 'science', 20),
            _s(1, 'common_1', 'common', 10),
            _s(2, 'draft', 'science', 1, r: 'internal_draft'),
            _s(3, 'off', 'common', 1, on: false),
          ],
          chaptersBySubjectId: {
            4: [
              _c(12, 4, 2, 1),
              _c(11, 4, 1, 1),
              _c(13, 4, 3, 0, on: false),
              _c(14, 99, 1, 0),
            ],
          },
          topicsByChapterId: {
            11: [
              _t(22, 11, 2, 1),
              _t(21, 11, 1, 1),
              _t(23, 11, 3, 0, r: 'internal_draft'),
              _t(24, 11, 4, 0, on: false),
              _t(25, 999, 1, 0),
            ],
          },
        );

        expect(_right(await repo.getEducationBoards()).map((b) => b.code), [
          'a',
          'b',
          'late',
        ]);
        expect(
          _right(
            await repo.getSubjectsForGroup(AcademicGroup.science),
          ).map((s) => s.code),
          ['common_1', 'sci_2'],
        );
        expect(
          _right(
            await repo.getChaptersForSubject(4),
          ).map((c) => c.chapterNumber),
          [1, 2],
        );

        final topics = _right(await repo.getTopicsForChapter(11));
        expect(topics.map((t) => t.topicNumber), [1, 2]);
        expect(() => topics.add(topics.first), throwsUnsupportedError);
      },
    );

    test('supports empty overrides across all catalogue queries', () async {
      final repo = InMemoryCurriculumRepository(
        boards: const [],
        subjects: const [],
        chaptersBySubjectId: const {},
        topicsByChapterId: const {},
      );

      expect(_right(await repo.getEducationBoards()), isEmpty);
      expect(
        _right(await repo.getSubjectsForGroup(AcademicGroup.science)),
        isEmpty,
      );
      expect(_right(await repo.getChaptersForSubject(136)), isEmpty);
      expect(_right(await repo.getTopicsForChapter(1361)), isEmpty);
    });

    test('returns forcedFailure and recovers when cleared', () async {
      final repo = InMemoryCurriculumRepository(
        forcedFailure: CurriculumFailure.offline,
      );
      const expected = Left<CurriculumFailure, void>(CurriculumFailure.offline);

      expect(await repo.getEducationBoards(), expected);
      expect(await repo.getSubjectsForGroup(AcademicGroup.science), expected);
      expect(await repo.getChaptersForSubject(136), expected);
      expect(await repo.getTopicsForChapter(1361), expected);

      repo.forcedFailure = null;
      expect(
        (await repo.getEducationBoards(forceRefresh: true)).isRight(),
        isTrue,
      );
    });

    test(
      'applies simulatedDelay before resolving success or failure',
      () async {
        final repo = InMemoryCurriculumRepository(
          simulatedDelay: const Duration(milliseconds: 40),
          forcedFailure: CurriculumFailure.serverError,
        );

        var completed = false;
        final future = repo.getEducationBoards().then((v) {
          completed = true;
          return v;
        });

        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(completed, isFalse);

        final result = await future;
        expect(completed, isTrue);
        expect(
          result,
          const Left<CurriculumFailure, void>(CurriculumFailure.serverError),
        );
      },
    );
  });
}
