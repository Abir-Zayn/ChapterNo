// Tier 1 isolated happy-path contract tests covering AC-7 (Curriculum
// Catalogue Filtering, Bilingual Metadata, and 24h TTL Two-Tier Cache).
import 'tier1_ac7_imports.dart';

void registerTier1Ac7Tests() {
  group('Tier 1 — AC-7: Curriculum Catalogue Filtering & 24h TTL Cache', () {
    test(
      'T1-AC7-01 Science group merges common + science and filters drafts',
      () async {
        final catalogue = FakeCurriculumCatalogue();
        final res = await catalogue.getSubjectsForGroup(
          E2eAcademicGroup.science,
        );
        res.fold((_) => fail('expected subjects'), (subjects) {
          final titles = subjects.map((s) => s.titleEn).toList();
          expect(
            titles,
            containsAll(['Bangla', 'English', 'Physics', 'Chemistry']),
          );
          expect(titles, isNot(contains('Accounting')));
          expect(titles, isNot(contains('History of Bangladesh')));
          expect(titles, isNot(contains('Draft Science Subject')));
          expect(titles, isNot(contains('Inactive Subject')));
          for (var i = 1; i < subjects.length; i++) {
            expect(subjects[i].sortOrder >= subjects[i - 1].sortOrder, isTrue);
          }
        });
      },
    );

    test(
      'T1-AC7-02 topics include Bangla titles and provenance metadata',
      () async {
        final catalogue = FakeCurriculumCatalogue();
        final res = await catalogue.getTopicsForChapter(1);
        res.fold((_) => fail('expected topics'), (topics) {
          expect(topics.length, 1);
          expect(topics.first.titleBn, 'ভৌত রাশি ও পরিমাপ');
          expect(topics.first.provenanceSource, 'NCTB SSC Physics Ch.1');
          expect(topics.first.rightsStatus, 'cleared');
        });
      },
    );

    test(
      'T1-AC7-03 memory cache hit avoids duplicate remote call within 24h',
      () async {
        var now = DateTime.utc(2026, 11, 25, 10);
        final catalogue = FakeCurriculumCatalogue(clock: () => now);
        await catalogue.getEducationBoards();
        now = now.add(const Duration(hours: 23));
        await catalogue.getEducationBoards();
        expect(catalogue.remoteCalls, 1);
      },
    );

    test(
      'T1-AC7-04 disk cache hit survives cleared memory within 24h TTL',
      () async {
        var now = DateTime.utc(2026, 11, 25, 10);
        final catalogue = FakeCurriculumCatalogue(clock: () => now);
        await catalogue.getSubjectsForGroup(E2eAcademicGroup.science);
        catalogue.clearMemoryOnly();
        now = now.add(const Duration(hours: 12));
        final res = await catalogue.getSubjectsForGroup(
          E2eAcademicGroup.science,
        );
        expect(res.isRight(), isTrue);
        expect(catalogue.remoteCalls, 1);
      },
    );

    test(
      'T1-AC7-05 forceRefresh bypasses fresh cache and refreshes remote',
      () async {
        final catalogue = FakeCurriculumCatalogue();
        await catalogue.getEducationBoards();
        await catalogue.getEducationBoards(forceRefresh: true);
        expect(catalogue.remoteCalls, 2);
      },
    );
  });
}
