// Bounded two-tier (memory + disk JSON) cache for curriculum catalogue data.
// Enforces 24h TTL, schemaVersion envelopes, and deterministic LRU eviction.
import 'curriculum_cache_store.dart';
import 'resource_imports.dart';

class CurriculumLocalCacheDataSource {
  CurriculumLocalCacheDataSource({
    required this.store,
    DateTime Function()? now,
    this.ttl = const Duration(hours: 24),
    this.schemaVersion = currentSchemaVersion,
    this.maxTotalSubjects = 30,
    this.maxChapterBuckets = 30,
    this.maxTotalChapters = 300,
    this.maxTopicBuckets = 60,
    this.maxTotalTopics = 600,
    this.maxTotalBytes = 250 * 1024,
  }) : _now = now ?? DateTime.now;

  static const int currentSchemaVersion = 1;
  static const String _boardsKey = 'boards';

  final CurriculumCacheStore store;
  final DateTime Function() _now;
  final Duration ttl;
  final int schemaVersion;
  final int maxTotalSubjects;
  final int maxChapterBuckets;
  final int maxTotalChapters;
  final int maxTopicBuckets;
  final int maxTotalTopics;
  final int maxTotalBytes;
  final BoundedCacheIndex _index = BoundedCacheIndex();

  static String subjectsKey(AcademicGroup group) => 'subjects_${group.dbValue}';
  static String chaptersKey(int subjectId) => 'chapters_$subjectId';
  static String topicsKey(int chapterId) => 'topics_$chapterId';

  Future<CacheLookupResult<EducationBoard>?> getEducationBoards() => _read(
    _boardsKey,
    CacheCategory.boards,
    (j) => EducationBoardModel.fromJson(j).toEntity(),
  );

  Future<void> saveEducationBoards(List<EducationBoard> boards) => _write(
    _boardsKey,
    CacheCategory.boards,
    boards,
    (e) => EducationBoardModel.fromEntity(e).toJson(),
  );

  Future<CacheLookupResult<Subject>?> getSubjectsForGroup(AcademicGroup g) =>
      _read(
        subjectsKey(g),
        CacheCategory.subjects,
        (j) => SubjectModel.fromJson(j).toEntity(),
      );

  Future<void> saveSubjectsForGroup(AcademicGroup g, List<Subject> subjects) =>
      _write(
        subjectsKey(g),
        CacheCategory.subjects,
        subjects,
        (e) => SubjectModel.fromEntity(e).toJson(),
      );

  Future<CacheLookupResult<Chapter>?> getChaptersForSubject(int subjectId) =>
      _read(
        chaptersKey(subjectId),
        CacheCategory.chapters,
        (j) => ChapterModel.fromJson(j).toEntity(),
      );

  Future<void> saveChaptersForSubject(int subjectId, List<Chapter> chapters) =>
      _write(
        chaptersKey(subjectId),
        CacheCategory.chapters,
        chapters,
        (e) => ChapterModel.fromEntity(e).toJson(),
      );

  Future<CacheLookupResult<Topic>?> getTopicsForChapter(int chapterId) => _read(
    topicsKey(chapterId),
    CacheCategory.topics,
    (j) => TopicModel.fromJson(j).toEntity(),
  );

  Future<void> saveTopicsForChapter(int chapterId, List<Topic> topics) =>
      _write(
        topicsKey(chapterId),
        CacheCategory.topics,
        topics,
        (e) => TopicModel.fromEntity(e).toJson(),
      );

  void clearMemoryCache() => _index.clearMemoryItems();

  Future<void> clearAll() async {
    _index.clearAll();
    await store.clear();
  }

  Future<CacheLookupResult<T>?> _read<T extends Object>(
    String key,
    CacheCategory category,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    await _hydrateIndexIfNeeded();
    final existing = _index.records[key];
    final memItems = existing?.items;
    if (existing != null && memItems != null) {
      final typed = memItems.whereType<T>().toList(growable: false);
      if (typed.length == memItems.length) {
        _index.touch(existing, _now().toUtc());
        return _result(typed, existing.cachedAt);
      }
      await _invalidateKey(key);
    }

    final raw = await store.read(key);
    final env = raw == null
        ? null
        : CurriculumCacheEnvelope.tryDecode(
            raw: raw,
            expectedSchemaVersion: schemaVersion,
          );
    final items = env == null ? null : _decodeItems(env.rawItems, fromJson);
    if (env == null || items == null) {
      if (raw != null) await _invalidateKey(key);
      return null;
    }

    final nowUtc = _now().toUtc();
    final record = CacheRecord(
      key: key,
      category: category,
      itemCount: items.length,
      byteLength: env.byteLength,
      cachedAt: env.cachedAt,
      lastAccessedAt: nowUtc,
      accessOrder: _index.nextAccessOrder(),
      items: items,
    );
    _index.records[key] = record;
    return _result(items.cast<T>(), record.cachedAt);
  }

  Future<void> _write<T extends Object>(
    String key,
    CacheCategory category,
    List<T> items,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    await _hydrateIndexIfNeeded();
    final nowUtc = _now().toUtc();
    final encoded = CurriculumCacheEnvelope.encode(
      schemaVersion: schemaVersion,
      timestampUtc: nowUtc,
      items: items.map(toJson).toList(growable: false),
    );
    final byteLength = utf8.encode(encoded).length;
    if (byteLength > maxTotalBytes) return;

    await store.write(key, encoded);
    _index.records[key] = CacheRecord(
      key: key,
      category: category,
      itemCount: items.length,
      byteLength: byteLength,
      cachedAt: nowUtc,
      lastAccessedAt: nowUtc,
      accessOrder: _index.nextAccessOrder(),
      items: List<Object>.of(items),
    );
    await _evictIfNeeded(key);
  }

  List<Object>? _decodeItems<T extends Object>(
    List<Map<String, dynamic>> rawItems,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      return rawItems.map<Object>(fromJson).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _hydrateIndexIfNeeded() async {
    if (_index.hydrated) return;
    _index.hydrated = true;
    final hydrated = <CacheRecord>[];
    for (final key in await store.listKeys()) {
      final category = _categoryForKey(key);
      final raw = category == null ? null : await store.read(key);
      if (category == null || raw == null) continue;
      final env = CurriculumCacheEnvelope.tryDecode(
        raw: raw,
        expectedSchemaVersion: schemaVersion,
      );
      if (env == null) {
        await store.delete(key);
      } else {
        hydrated.add(
          CacheRecord(
            key: key,
            category: category,
            itemCount: env.rawItems.length,
            byteLength: env.byteLength,
            cachedAt: env.cachedAt,
            lastAccessedAt: env.lastAccessedAt,
            accessOrder: 0,
          ),
        );
      }
    }
    hydrated.sort((a, b) {
      final byAccess = a.lastAccessedAt.compareTo(b.lastAccessedAt);
      if (byAccess != 0) return byAccess;
      final byCached = a.cachedAt.compareTo(b.cachedAt);
      return byCached != 0 ? byCached : a.key.compareTo(b.key);
    });
    for (final record in hydrated) {
      record.accessOrder = _index.nextAccessOrder();
      _index.records[record.key] = record;
    }
  }

  Future<void> _evictIfNeeded(String protectedKey) async {
    final limits = <CacheCategory, (int, int)>{
      CacheCategory.subjects: (10, maxTotalSubjects),
      CacheCategory.chapters: (maxChapterBuckets, maxTotalChapters),
      CacheCategory.topics: (maxTopicBuckets, maxTotalTopics),
    };
    for (final entry in limits.entries) {
      final (maxBuckets, maxItems) = entry.value;
      while (true) {
        final group = _index.records.values.where(
          (r) => r.category == entry.key,
        );
        final items = group.fold<int>(0, (sum, r) => sum + r.itemCount);
        if (group.length <= maxBuckets && items <= maxItems) break;
        final victim = _index.oldestRecord(
          category: entry.key,
          protectedKey: protectedKey,
        );
        if (victim == null) break;
        await _invalidateKey(victim.key);
      }
    }
    while (_index.totalBytes > maxTotalBytes) {
      final victim = _index.oldestRecord(protectedKey: protectedKey);
      if (victim == null) break;
      await _invalidateKey(victim.key);
    }
  }

  CacheLookupResult<T> _result<T>(List<T> items, DateTime cachedAt) =>
      CacheLookupResult<T>(
        items: List<T>.unmodifiable(items),
        isExpired: _now().toUtc().difference(cachedAt) >= ttl,
        cachedAt: cachedAt,
      );

  Future<void> _invalidateKey(String key) async {
    _index.records.remove(key);
    await store.delete(key);
  }

  CacheCategory? _categoryForKey(String key) {
    if (key == _boardsKey) return CacheCategory.boards;
    if (key.startsWith('subjects_')) return CacheCategory.subjects;
    if (key.startsWith('chapters_')) return CacheCategory.chapters;
    if (key.startsWith('topics_')) return CacheCategory.topics;
    return null;
  }
}
