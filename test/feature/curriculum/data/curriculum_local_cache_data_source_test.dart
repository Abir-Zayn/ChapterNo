// Verifies TTL expiry, schema invalidation, bounded LRU eviction, and disk IO.
// Uses an injectable clock and an in-memory or temporary directory store.
import 'curriculum_local_cache_data_source_test_imports.dart';

Chapter _chapter(int id, {int subjectId = 1, String title = 'Motion'}) =>
    Chapter(
      id: id,
      subjectId: subjectId,
      chapterNumber: id,
      titleEn: '$title $id',
      titleBn: 'অধ্যায় $id',
      sortOrder: id,
    );

Topic _topic(int id, {int chapterId = 1}) => Topic(
  id: id,
  chapterId: chapterId,
  topicNumber: id,
  titleEn: 'Topic $id',
  titleBn: 'টপিক $id',
  sortOrder: id,
);

const String _validBoardsEnvelopeJson =
    '{"schemaVersion":1,"cachedAt":"2026-11-25T10:00:00.000Z",'
    '"lastAccessedAt":"2026-11-25T10:00:00.000Z","items":['
    '{"id":1,"code":"dhaka","name_en":"Dhaka Board",'
    '"name_bn":"ঢাকা বোর্ড","sort_order":1,"is_active":true}]}';

void main() {
  late InMemoryCurriculumCacheStore store;
  late DateTime clock;
  late CurriculumLocalCacheDataSource cache;

  setUp(() {
    store = InMemoryCurriculumCacheStore();
    clock = DateTime.utc(2026, 11, 25, 10, 0);
    cache = CurriculumLocalCacheDataSource(
      store: store,
      now: () => clock,
      maxChapterBuckets: 2,
      maxTotalChapters: 4,
      maxTopicBuckets: 2,
      maxTotalTopics: 4,
    );
  });

  test(
    'serves memory hit without extra store reads and reloads from disk',
    () async {
      await cache.saveChaptersForSubject(1, <Chapter>[_chapter(1)]);
      expect(store.writeCount, 1);

      final memHit = await cache.getChaptersForSubject(1);
      expect(memHit?.items.single.id, 1);
      expect(store.readCount, 0);

      cache.clearMemoryCache();
      final diskHit = await cache.getChaptersForSubject(1);
      expect(diskHit?.items.single.titleBn, 'অধ্যায় 1');
      expect(store.readCount, 1);
    },
  );

  test('marks entries expired at exactly 24 hours', () async {
    await cache.saveChaptersForSubject(1, <Chapter>[_chapter(1)]);

    clock = clock.add(const Duration(hours: 23, minutes: 59));
    final fresh = await cache.getChaptersForSubject(1);
    expect(fresh?.isExpired, isFalse);

    clock = clock.add(const Duration(minutes: 1));
    final expired = await cache.getChaptersForSubject(1);
    expect(expired?.isExpired, isTrue);
  });

  test('invalidates and deletes entry on schemaVersion mismatch', () async {
    await store.write(
      'chapters_1',
      '{"schemaVersion":99,"cachedAt":"2026-11-25T10:00:00Z","items":[]}',
    );

    final result = await cache.getChaptersForSubject(1);
    expect(result, isNull);
    expect(await store.read('chapters_1'), isNull);
  });

  test('invalidates corrupt JSON cleanly without throwing', () async {
    await store.write('topics_7', '{not-valid-json');

    final result = await cache.getTopicsForChapter(7);
    expect(result, isNull);
    expect(await store.read('topics_7'), isNull);
  });

  test(
    'evicts least-recently-used chapter bucket when bounds exceeded',
    () async {
      await cache.saveChaptersForSubject(1, <Chapter>[
        _chapter(1, subjectId: 1),
      ]);
      clock = clock.add(const Duration(minutes: 1));
      await cache.saveChaptersForSubject(2, <Chapter>[
        _chapter(2, subjectId: 2),
      ]);
      clock = clock.add(const Duration(minutes: 1));

      // Touch subject 1 so subject 2 becomes least recently used.
      await cache.getChaptersForSubject(1);
      clock = clock.add(const Duration(minutes: 1));
      await cache.saveChaptersForSubject(3, <Chapter>[
        _chapter(3, subjectId: 3),
      ]);

      expect(await cache.getChaptersForSubject(1), isNotNull);
      expect(await cache.getChaptersForSubject(3), isNotNull);
      expect(await store.read('chapters_2'), isNull);
    },
  );

  test(
    'evicts oldest topic buckets when total topic count exceeds limit',
    () async {
      await cache.saveTopicsForChapter(1, <Topic>[_topic(1), _topic(2)]);
      clock = clock.add(const Duration(minutes: 1));
      await cache.saveTopicsForChapter(2, <Topic>[_topic(3), _topic(4)]);
      clock = clock.add(const Duration(minutes: 1));
      await cache.saveTopicsForChapter(3, <Topic>[_topic(5)]);

      expect(await store.read('topics_1'), isNull);
      expect(await cache.getTopicsForChapter(2), isNotNull);
      expect(await cache.getTopicsForChapter(3), isNotNull);
    },
  );

  test('enforces total UTF-8 byte budget across cached entries', () async {
    final byteBounded = CurriculumLocalCacheDataSource(
      store: store,
      now: () => clock,
      maxTotalBytes: 400,
    );
    await byteBounded.saveChaptersForSubject(1, <Chapter>[
      _chapter(1, title: 'Physics Chapter One'),
    ]);
    clock = clock.add(const Duration(minutes: 1));
    await byteBounded.saveChaptersForSubject(2, <Chapter>[
      _chapter(2, title: 'Chemistry Chapter Two'),
    ]);

    expect(await store.read('chapters_1'), isNull);
    expect(await byteBounded.getChaptersForSubject(2), isNotNull);
  });

  test(
    'FileCurriculumCacheStore persists across instances and rejects unsafe keys',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'curriculum_cache_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) await tempDir.delete(recursive: true);
      });

      final fileStore = FileCurriculumCacheStore(tempDir);
      final writer = CurriculumLocalCacheDataSource(
        store: fileStore,
        now: () => clock,
      );
      await writer.saveChaptersForSubject(10, <Chapter>[
        _chapter(10, subjectId: 10),
      ]);

      final reader = CurriculumLocalCacheDataSource(
        store: FileCurriculumCacheStore(tempDir),
        now: () => clock,
      );
      final loaded = await reader.getChaptersForSubject(10);
      expect(loaded?.items.single.titleBn, 'অধ্যায় 10');

      expect(() => fileStore.read('../secret'), throwsArgumentError);
    },
  );

  test(
    'cold-start FileCurriculumCacheStore purges non-UTF8 file and preserves healthy boards',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'curriculum_corrupt_cold_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) await tempDir.delete(recursive: true);
      });

      final fileStore = FileCurriculumCacheStore(tempDir);
      await fileStore.write('boards', _validBoardsEnvelopeJson);
      final corruptFile = File(
        '${tempDir.path}${Platform.pathSeparator}chapters_99.json',
      );
      await corruptFile.writeAsBytes(<int>[
        0xFF,
        0xFE,
        0x00,
        0x80,
      ], flush: true);

      final coldCache = CurriculumLocalCacheDataSource(
        store: fileStore,
        now: () => clock,
      );
      final boards = await coldCache.getEducationBoards();

      expect(boards?.items.single.code, 'dhaka');
      expect(await corruptFile.exists(), isFalse);

      await coldCache.saveChaptersForSubject(1, <Chapter>[_chapter(1)]);
      final saved = await coldCache.getChaptersForSubject(1);
      expect(saved?.items.single.id, 1);
    },
  );

  test(
    'post-hydration corrupt non-UTF8 file returns null and deletes corrupt file',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'curriculum_corrupt_post_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) await tempDir.delete(recursive: true);
      });

      final fileStore = FileCurriculumCacheStore(tempDir);
      final diskCache = CurriculumLocalCacheDataSource(
        store: fileStore,
        now: () => clock,
      );
      await diskCache.saveChaptersForSubject(1, <Chapter>[_chapter(1)]);

      final chapterFile = File(
        '${tempDir.path}${Platform.pathSeparator}chapters_1.json',
      );
      await chapterFile.writeAsBytes(<int>[
        0xFF,
        0xFE,
        0x00,
        0x80,
      ], flush: true);
      diskCache.clearMemoryCache();

      final loaded = await diskCache.getChaptersForSubject(1);
      expect(loaded, isNull);
      expect(await chapterFile.exists(), isFalse);
    },
  );
}
