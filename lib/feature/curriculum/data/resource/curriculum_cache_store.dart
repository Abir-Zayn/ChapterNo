// Persistence contract, cache stores, and schema-versioned JSON envelopes.
// Provides an in-memory store, file store, and LRU index accounting.
import 'resource_imports.dart';

class CacheLookupResult<T> {
  const CacheLookupResult({
    required this.items,
    required this.isExpired,
    required this.cachedAt,
  });

  final List<T> items;
  final bool isExpired;
  final DateTime cachedAt;
}

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
  }) {
    return jsonEncode(<String, dynamic>{
      'schemaVersion': schemaVersion,
      'cachedAt': timestampUtc.toIso8601String(),
      'lastAccessedAt': timestampUtc.toIso8601String(),
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
}

abstract interface class CurriculumCacheStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<List<String>> listKeys();
  Future<void> clear();
}

/// Deterministic in-memory [CurriculumCacheStore] for unit and widget tests.
class InMemoryCurriculumCacheStore implements CurriculumCacheStore {
  final Map<String, String> _entries = <String, String>{};
  int writeCount = 0;
  int readCount = 0;
  int deleteCount = 0;

  @override
  Future<String?> read(String key) async {
    readCount += 1;
    return _entries[key];
  }

  @override
  Future<void> write(String key, String value) async {
    writeCount += 1;
    _entries[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    deleteCount += 1;
    _entries.remove(key);
  }

  @override
  Future<List<String>> listKeys() async =>
      _entries.keys.toList(growable: false);

  @override
  Future<void> clear() async => _entries.clear();
}

/// File-system backed [CurriculumCacheStore] storing one JSON file per key.
class FileCurriculumCacheStore implements CurriculumCacheStore {
  FileCurriculumCacheStore(this.directory);

  final Directory directory;
  static final RegExp _safeKeyPattern = RegExp(r'^[a-zA-Z0-9_-]+$');

  File _fileForKey(String key) {
    if (!_safeKeyPattern.hasMatch(key)) {
      throw ArgumentError.value(key, 'key', 'Unsupported cache key format');
    }
    return File('${directory.path}${Platform.pathSeparator}$key.json');
  }

  @override
  Future<String?> read(String key) async {
    final file = _fileForKey(key);
    return await file.exists() ? file.readAsString() : null;
  }

  @override
  Future<void> write(String key, String value) async {
    if (!await directory.exists()) await directory.create(recursive: true);
    await _fileForKey(key).writeAsString(value, flush: true);
  }

  @override
  Future<void> delete(String key) async {
    final file = _fileForKey(key);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<List<String>> listKeys() async {
    if (!await directory.exists()) return const <String>[];
    final keys = <String>[];
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is File && entity.path.endsWith('.json')) {
        final name = entity.uri.pathSegments.last;
        final key = name.substring(0, name.length - 5);
        if (_safeKeyPattern.hasMatch(key)) keys.add(key);
      }
    }
    return keys;
  }

  @override
  Future<void> clear() async {
    if (!await directory.exists()) return;
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is File && entity.path.endsWith('.json')) {
        await entity.delete();
      }
    }
  }
}
