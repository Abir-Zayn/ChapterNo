// Isolates disk hydration, safe IO, access updates, and LRU eviction helpers.
// Ensures corrupt or non-UTF8 files are purged without breaking cache startup.
import 'curriculum_cache_disk_helper_imports.dart';

class CurriculumCacheDiskHelper {
  const CurriculumCacheDiskHelper({
    required this.store,
    required this.schemaVersion,
    required this.maxTotalBytes,
  });

  final CurriculumCacheStore store;
  final int schemaVersion;
  final int maxTotalBytes;

  /// Hydrates valid cache metadata across all stored keys, purging any corrupt
  /// or unreadable entries so one bad file never blocks startup.
  Future<List<CacheRecord>> hydrateAll() async {
    final hydrated = <CacheRecord>[];
    for (final key in await store.listKeys()) {
      final category = BoundedCacheIndex.categoryForKey(key);
      if (category == null) continue;
      final String? raw;
      try {
        raw = await store.read(key);
      } catch (_) {
        await safeDelete(key);
        continue;
      }
      if (raw == null) continue;
      final env = CurriculumCacheEnvelope.tryDecode(
        raw: raw,
        expectedSchemaVersion: schemaVersion,
      );
      if (env == null) {
        await safeDelete(key);
        continue;
      }
      hydrated.add(env.toHydratedRecord(key: key, category: category));
    }
    return hydrated;
  }

  /// Reads [key] from [store], deleting it and returning `null` if disk IO or
  /// UTF-8 decoding throws.
  Future<String?> safeRead(String key) async {
    try {
      return await store.read(key);
    } catch (_) {
      await safeDelete(key);
      return null;
    }
  }

  /// Deletes [key] from [store] best-effort without throwing on IO errors.
  Future<void> safeDelete(String key) async {
    try {
      await store.delete(key);
    } catch (_) {
      // Best-effort cleanup: ignore disk delete failures during recovery.
    }
  }

  /// Updates the persisted `lastAccessedAt` timestamp for a disk read hit.
  Future<int> persistDiskAccess({
    required String key,
    required CurriculumCacheEnvelope env,
    required DateTime accessedAtUtc,
  }) async {
    final encoded = CurriculumCacheEnvelope.encode(
      schemaVersion: schemaVersion,
      timestampUtc: env.cachedAt,
      lastAccessedAtUtc: accessedAtUtc,
      items: env.rawItems,
    );
    final byteLength = utf8.encode(encoded).length;
    if (byteLength > maxTotalBytes) return env.byteLength;
    try {
      await store.write(key, encoded);
      return byteLength;
    } catch (_) {
      return env.byteLength;
    }
  }

  /// Evicts least-recently-used entries until category and byte budgets hold.
  Future<void> evictIfNeeded({
    required BoundedCacheIndex index,
    required Map<CacheCategory, (int, int)> limits,
    required String protectedKey,
  }) async {
    while (true) {
      final victimKey = index.nextEvictionKey(
        limits: limits,
        maxTotalBytes: maxTotalBytes,
        protectedKey: protectedKey,
      );
      if (victimKey == null) break;
      index.records.remove(victimKey);
      await safeDelete(victimKey);
    }
  }
}
