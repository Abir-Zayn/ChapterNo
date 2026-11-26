// Schema-versioned cache envelopes and bounded LRU metadata accounting.
// Separates index eviction tracking from disk/memory store implementations.
import 'resource_imports.dart';

class CurriculumCacheEnvelope {
  const CurriculumCacheEnvelope({
    required this.schemaVersion,
    required this.cachedAt,
    required this.lastAccessedAt,
    required this.rawItems,
    required this.byteLength,
  });

  final int schemaVersion;
  final DateTime cachedAt;
  final DateTime lastAccessedAt;
  final List<Map<String, dynamic>> rawItems;
  final int byteLength;

  static String encode({
    required int schemaVersion,
    required DateTime timestampUtc,
    required List<Map<String, dynamic>> items,
    DateTime? lastAccessedAtUtc,
  }) {
    return jsonEncode(<String, dynamic>{
      'schemaVersion': schemaVersion,
      'cachedAt': timestampUtc.toIso8601String(),
      'lastAccessedAt': (lastAccessedAtUtc ?? timestampUtc).toIso8601String(),
      'items': items,
    });
  }

  static CurriculumCacheEnvelope? tryDecode({
    required String raw,
    required int expectedSchemaVersion,
  }) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      if (decoded['schemaVersion'] != expectedSchemaVersion) return null;
      final cachedAtRaw = decoded['cachedAt'];
      final itemsRaw = decoded['items'];
      if (cachedAtRaw is! String || itemsRaw is! List<dynamic>) return null;
      final maps = <Map<String, dynamic>>[];
      for (final item in itemsRaw) {
        if (item is! Map<String, dynamic>) return null;
        maps.add(item);
      }
      final cachedAt = DateTime.parse(cachedAtRaw).toUtc();
      final lastRaw = decoded['lastAccessedAt'];
      final lastAccessedAt = lastRaw is String
          ? DateTime.parse(lastRaw).toUtc()
          : cachedAt;
      return CurriculumCacheEnvelope(
        schemaVersion: expectedSchemaVersion,
        cachedAt: cachedAt,
        lastAccessedAt: lastAccessedAt,
        rawItems: maps,
        byteLength: utf8.encode(raw).length,
      );
    } catch (_) {
      return null;
    }
  }

  CacheRecord toHydratedRecord({
    required String key,
    required CacheCategory category,
  }) {
    return CacheRecord(
      key: key,
      category: category,
      itemCount: rawItems.length,
      byteLength: byteLength,
      cachedAt: cachedAt,
      lastAccessedAt: lastAccessedAt,
      accessOrder: 0,
    );
  }
}

enum CacheCategory { boards, subjects, chapters, topics }

class CacheRecord {
  CacheRecord({
    required this.key,
    required this.category,
    required this.itemCount,
    required this.byteLength,
    required this.cachedAt,
    required this.lastAccessedAt,
    required this.accessOrder,
    this.items,
  });

  final String key;
  final CacheCategory category;
  final int itemCount;
  final int byteLength;
  final DateTime cachedAt;
  DateTime lastAccessedAt;
  int accessOrder;
  List<Object>? items;
}

class BoundedCacheIndex {
  final Map<String, CacheRecord> records = <String, CacheRecord>{};
  bool hydrated = false;
  int _accessCounter = 0;

  int nextAccessOrder() => ++_accessCounter;

  void touch(CacheRecord record, DateTime nowUtc) {
    record.lastAccessedAt = nowUtc;
    record.accessOrder = ++_accessCounter;
  }

  void clearMemoryItems() {
    for (final record in records.values) {
      record.items = null;
    }
  }

  void clearAll() {
    records.clear();
    hydrated = true;
  }

  void addHydrated(List<CacheRecord> hydratedRecords) {
    hydratedRecords.sort((a, b) {
      final byAccess = a.lastAccessedAt.compareTo(b.lastAccessedAt);
      if (byAccess != 0) return byAccess;
      final byCached = a.cachedAt.compareTo(b.cachedAt);
      return byCached != 0 ? byCached : a.key.compareTo(b.key);
    });
    for (final record in hydratedRecords) {
      record.accessOrder = nextAccessOrder();
      records[record.key] = record;
    }
    hydrated = true;
  }

  static CacheCategory? categoryForKey(String key) {
    if (key == 'boards') return CacheCategory.boards;
    if (key.startsWith('subjects_')) return CacheCategory.subjects;
    if (key.startsWith('chapters_')) return CacheCategory.chapters;
    if (key.startsWith('topics_')) return CacheCategory.topics;
    return null;
  }

  int get totalBytes =>
      records.values.fold<int>(0, (sum, record) => sum + record.byteLength);

  CacheRecord? oldestRecord({
    CacheCategory? category,
    required String protectedKey,
  }) {
    final candidates = records.values
        .where(
          (r) =>
              r.key != protectedKey &&
              (category == null || r.category == category),
        )
        .toList();
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) {
      final byAccess = a.lastAccessedAt.compareTo(b.lastAccessedAt);
      return byAccess != 0 ? byAccess : a.accessOrder.compareTo(b.accessOrder);
    });
    return candidates.first;
  }

  String? nextEvictionKey({
    required Map<CacheCategory, (int, int)> limits,
    required int maxTotalBytes,
    required String protectedKey,
  }) {
    for (final entry in limits.entries) {
      final (maxBuckets, maxItems) = entry.value;
      final group = records.values.where((r) => r.category == entry.key);
      final items = group.fold<int>(0, (sum, r) => sum + r.itemCount);
      if (group.length > maxBuckets || items > maxItems) {
        final victim = oldestRecord(
          category: entry.key,
          protectedKey: protectedKey,
        );
        if (victim != null) return victim.key;
      }
    }
    if (totalBytes > maxTotalBytes) {
      return oldestRecord(protectedKey: protectedKey)?.key;
    }
    return null;
  }
}
