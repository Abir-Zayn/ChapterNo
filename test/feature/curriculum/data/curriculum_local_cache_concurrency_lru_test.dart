// Verifies concurrent cold-start hydration and cross-restart disk LRU order.
// Uses a gated CurriculumCacheStore and deterministic injected clock.
import 'curriculum_local_cache_concurrency_lru_test_imports.dart';

Chapter _chapter(int id, {int subjectId = 1, String title = 'Motion'}) =>
    Chapter(
      id: id,
      subjectId: subjectId,
      chapterNumber: id,
      titleEn: '$title $id',
      titleBn: 'অধ্যায় $id',
      sortOrder: id,
    );

class _DelayedListKeysCacheStore implements CurriculumCacheStore {
  _DelayedListKeysCacheStore(this.inner, this.listKeysGate);

  final CurriculumCacheStore inner;
  final Completer<void> listKeysGate;
  final Completer<void> listKeysStarted = Completer<void>();
  int listKeysCalls = 0;

  @override
  Future<void> clear() => inner.clear();

  @override
  Future<void> delete(String key) => inner.delete(key);

  @override
  Future<List<String>> listKeys() async {
    listKeysCalls += 1;
    if (!listKeysStarted.isCompleted) listKeysStarted.complete();
    await listKeysGate.future;
    return inner.listKeys();
  }

  @override
  Future<String?> read(String key) => inner.read(key);

  @override
  Future<void> write(String key, String value) => inner.write(key, value);
}

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
    );
  });

  test(
    'concurrent cold-start hydration shares one listKeys pass and enforces bounds',
    () async {
      await cache.saveChaptersForSubject(1, <Chapter>[_chapter(1)]);
      clock = clock.add(const Duration(minutes: 1));
      await cache.saveChaptersForSubject(2, <Chapter>[_chapter(2)]);
      clock = clock.add(const Duration(minutes: 1));

      final gate = Completer<void>();
      final delayedStore = _DelayedListKeysCacheStore(store, gate);
      final coldCache = CurriculumLocalCacheDataSource(
        store: delayedStore,
        now: () => clock,
        maxChapterBuckets: 2,
        maxTotalChapters: 4,
      );

      final read1 = coldCache.getChaptersForSubject(1);
      await delayedStore.listKeysStarted.future;

      final write3 = coldCache.saveChaptersForSubject(3, <Chapter>[
        _chapter(3),
      ]);
      clock = clock.add(const Duration(minutes: 1));
      final write4 = coldCache.saveChaptersForSubject(4, <Chapter>[
        _chapter(4),
      ]);

      gate.complete();
      await Future.wait(<Future<Object?>>[read1, write3, write4]);

      expect(delayedStore.listKeysCalls, 1);
      expect(await store.read('chapters_1'), isNull);
      expect(await store.read('chapters_2'), isNull);
      expect((await store.listKeys()).length, 2);
      expect(await store.read('chapters_3'), isNotNull);
      expect(await store.read('chapters_4'), isNotNull);
    },
  );

  test(
    'concurrent cold-start read and write enforce total byte limit after hydration',
    () async {
      final writer = CurriculumLocalCacheDataSource(
        store: store,
        now: () => clock,
        maxTotalBytes: 700,
      );
      await writer.saveChaptersForSubject(1, <Chapter>[
        _chapter(1, title: 'Physics Chapter One'),
      ]);
      clock = clock.add(const Duration(minutes: 1));
      await writer.saveChaptersForSubject(2, <Chapter>[
        _chapter(2, title: 'Chemistry Chapter Two'),
      ]);
      clock = clock.add(const Duration(minutes: 1));

      final gate = Completer<void>();
      final delayedStore = _DelayedListKeysCacheStore(store, gate);
      final coldCache = CurriculumLocalCacheDataSource(
        store: delayedStore,
        now: () => clock,
        maxTotalBytes: 600,
      );

      final read1 = coldCache.getChaptersForSubject(1);
      await delayedStore.listKeysStarted.future;
      clock = clock.add(const Duration(minutes: 1));
      final write3 = coldCache.saveChaptersForSubject(3, <Chapter>[
        _chapter(3, title: 'Biology Chapter Three'),
      ]);

      gate.complete();
      await Future.wait(<Future<Object?>>[read1, write3]);

      expect(delayedStore.listKeysCalls, 1);
      expect(await store.read('chapters_2'), isNull);
      final raw1 = await store.read('chapters_1');
      final raw3 = await store.read('chapters_3');
      expect(raw1, isNotNull);
      expect(raw3, isNotNull);
      expect(
        utf8.encode(raw1!).length + utf8.encode(raw3!).length,
        lessThanOrEqualTo(600),
      );
    },
  );

  test(
    'preserves disk-read LRU order across restarts without extending TTL',
    () async {
      await cache.saveChaptersForSubject(1, <Chapter>[_chapter(1)]);
      clock = clock.add(const Duration(minutes: 1));
      await cache.saveChaptersForSubject(2, <Chapter>[_chapter(2)]);

      // Restart 1: read subject 1 from disk; updates lastAccessedAt only.
      clock = clock.add(const Duration(minutes: 5));
      final secondLaunch = CurriculumLocalCacheDataSource(
        store: store,
        now: () => clock,
        maxChapterBuckets: 2,
        maxTotalChapters: 4,
      );
      final diskHit = await secondLaunch.getChaptersForSubject(1);
      expect(diskHit?.items.single.id, 1);
      expect(diskHit?.cachedAt, DateTime.utc(2026, 11, 25, 10, 0));

      // Restart 2: writing subject 3 must evict subject 2 (LRU), keeping 1.
      clock = clock.add(const Duration(minutes: 5));
      final thirdLaunch = CurriculumLocalCacheDataSource(
        store: store,
        now: () => clock,
        maxChapterBuckets: 2,
        maxTotalChapters: 4,
      );
      await thirdLaunch.saveChaptersForSubject(3, <Chapter>[_chapter(3)]);

      expect(await store.read('chapters_2'), isNull);
      expect(await store.read('chapters_1'), isNotNull);
      expect(await store.read('chapters_3'), isNotNull);

      clock = DateTime.utc(2026, 11, 26, 10, 0);
      final after24h = await thirdLaunch.getChaptersForSubject(1);
      expect(after24h?.isExpired, isTrue);
    },
  );
}
