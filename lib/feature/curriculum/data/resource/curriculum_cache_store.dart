// Persistence contract and cache store implementations for curriculum data.
// Provides an in-memory store and a path-safe file-system JSON store.
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
