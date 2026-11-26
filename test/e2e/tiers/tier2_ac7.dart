// Tier 2 boundary & negative contract tests for AC-7 (Offline Empty Miss,
// Stale-While-Offline, Expired Refresh, Schema Invalidation, Bounded Eviction).
import 'tier2_ac7_imports.dart';

void registerTier2Ac7Tests() {
  group('Tier 2 — AC-7: Curriculum Catalogue & Cache Boundaries', () {
    test(
      'T2-AC7-01 offline with empty cache returns CurriculumFailure.offline',
      () async {
        final catalogue = FakeCurriculumCatalogue()..isOffline = true;
        final boards = await catalogue.getEducationBoards();
        final subjects = await catalogue.getSubjectsForGroup(
          E2eAcademicGroup.science,
        );
        final chapters = await catalogue.getChaptersForSubject(10);
        final topics = await catalogue.getTopicsForChapter(1);

        boards.fold(
          (f) => expect(f, E2eCurriculumFailure.offline),
          (_) => fail('expected offline failure'),
        );
        subjects.fold(
          (f) => expect(f, E2eCurriculumFailure.offline),
          (_) => fail('expected offline failure'),
        );
        chapters.fold(
          (f) => expect(f, E2eCurriculumFailure.offline),
          (_) => fail('expected offline failure'),
        );
        topics.fold(
          (f) => expect(f, E2eCurriculumFailure.offline),
          (_) => fail('expected offline failure'),
        );
      },
    );

    test(
      'T2-AC7-02 expired TTL (>24h) + offline serves stale cache safely',
      () async {
        var now = DateTime.utc(2026, 11, 25, 8);
        final catalogue = FakeCurriculumCatalogue(clock: () => now);
        await catalogue.getSubjectsForGroup(E2eAcademicGroup.science);

        now = now.add(const Duration(hours: 25));
        catalogue
          ..clearMemoryOnly()
          ..isOffline = true;
        final stale = await catalogue.getSubjectsForGroup(
          E2eAcademicGroup.science,
        );
        stale.fold(
          (_) => fail('expected stale fallback'),
          (items) => expect(items.any((s) => s.titleEn == 'Physics'), isTrue),
        );
      },
    );

    test(
      'T2-AC7-03 expired TTL (>24h) + online refreshes from remote',
      () async {
        var now = DateTime.utc(2026, 11, 25, 8);
        final catalogue = FakeCurriculumCatalogue(clock: () => now);
        await catalogue.getEducationBoards();
        expect(catalogue.remoteCalls, 1);

        now = now.add(const Duration(hours: 25));
        await catalogue.getEducationBoards();
        expect(catalogue.remoteCalls, 2);
      },
    );

    test(
      'T2-AC7-04 outdated schemaVersion or corrupt JSON invalidates cleanly',
      () async {
        final catalogue = FakeCurriculumCatalogue();
        catalogue.seedRawDiskEntry(
          'boards',
          jsonEncode({
            'schemaVersion': 0,
            'kind': 'board',
            'fetchedAt': DateTime.utc(2026, 11, 25).toIso8601String(),
            'items': const <Object>[],
          }),
        );
        final res1 = await catalogue.getEducationBoards();
        expect(res1.isRight(), isTrue);
        expect(catalogue.remoteCalls, 1);

        catalogue.seedRawDiskEntry('boards', '{broken-json');
        catalogue.isOffline = true;
        final res2 = await catalogue.getEducationBoards();
        res2.fold(
          (f) => expect(f, E2eCurriculumFailure.offline),
          (_) => fail('expected corrupt entry eviction + offline failure'),
        );
      },
    );

    test('T2-AC7-05 bounded eviction caps cached subjects at maxSubjects', () {
      final catalogue = FakeCurriculumCatalogue(maxSubjects: 30);
      for (var batch = 0; batch < 5; batch++) {
        final items = List.generate(
          8,
          (i) => E2eSubject(
            id: batch * 10 + i,
            titleEn: 'Subj $batch-$i',
            titleBn: 'বিষয়',
            groupTag: 'science',
            sortOrder: i,
          ),
        );
        catalogue.putBoundedSubjectsSnapshot('subjects:batch:$batch', items);
      }
      expect(catalogue.totalCachedSubjects, lessThanOrEqualTo(30));
      expect(catalogue.diskEntryCount, lessThanOrEqualTo(3));
    });

    test(
      'T2-AC7-06 timeout returns timeout on miss or falls back to stale cache',
      () async {
        final catalogue = FakeCurriculumCatalogue()..simulateTimeout = true;
        final miss = await catalogue.getEducationBoards();
        miss.fold(
          (f) => expect(f, E2eCurriculumFailure.timeout),
          (_) => fail('expected timeout'),
        );

        catalogue.simulateTimeout = false;
        await catalogue.getEducationBoards();
        catalogue
          ..clearMemoryOnly()
          ..simulateTimeout = true;
        final fallback = await catalogue.getEducationBoards();
        expect(fallback.isRight(), isTrue);
      },
    );
  });
}
