// Bounded two-tier 24h TTL curriculum cache double modeling Step 1 Doc 04.
// Supports offline stale-cache fallback, schemaVersion checks, and eviction.
import 'e2e_curriculum_fake_imports.dart';

class FakeCurriculumCatalogue {
  FakeCurriculumCatalogue({
    DateTime Function()? clock,
    this.maxSubjects = 30,
    this.maxChapters = 300,
    this.ttl = const Duration(hours: 24),
  }) : _clock = clock ?? DateTime.now;

  static const int currentSchemaVersion = 1;
  final DateTime Function() _clock;
  final int maxSubjects;
  final int maxChapters;
  final Duration ttl;

  bool isOffline = false;
  bool simulateTimeout = false;
  int remoteCalls = 0;

  final Map<String, E2eCacheEntry<Object>> _memory = {};
  final LinkedHashMap<String, String> _disk = LinkedHashMap();

  void seedRawDiskEntry(String key, String rawJson) {
    _memory.remove(key);
    _disk[key] = rawJson;
  }

  void clearMemoryOnly() => _memory.clear();

  int get diskEntryCount => _disk.length;

  int get totalCachedSubjects {
    var count = 0;
    for (final raw in _disk.values) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      if (decoded['kind'] == 'subject') {
        count += (decoded['items'] as List<dynamic>).length;
      }
    }
    return count;
  }

  Future<Either<E2eCurriculumFailure, List<E2eBoard>>> getEducationBoards({
    bool forceRefresh = false,
  }) {
    return _readCached(
      key: 'boards',
      kind: 'board',
      forceRefresh: forceRefresh,
      decode: (m) => E2eBoard(
        id: m['id'] as String,
        nameEn: m['nameEn'] as String,
        nameBn: m['nameBn'] as String,
        sortOrder: m['sortOrder'] as int,
      ),
      encode: (b) => {
        'id': b.id,
        'nameEn': b.nameEn,
        'nameBn': b.nameBn,
        'sortOrder': b.sortOrder,
      },
      fetchRemote: () =>
          E2eCurriculumSeeds.boards.where((b) => b.isActive).toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
    );
  }

  Future<Either<E2eCurriculumFailure, List<E2eSubject>>> getSubjectsForGroup(
    E2eAcademicGroup group, {
    bool forceRefresh = false,
  }) {
    final tag = switch (group) {
      E2eAcademicGroup.science => 'science',
      E2eAcademicGroup.businessStudies => 'business_studies',
      E2eAcademicGroup.humanities => 'humanities',
    };
    return _readCached(
      key: 'subjects:$tag',
      kind: 'subject',
      forceRefresh: forceRefresh,
      decode: (m) => E2eSubject(
        id: m['id'] as int,
        titleEn: m['titleEn'] as String,
        titleBn: m['titleBn'] as String,
        groupTag: m['groupTag'] as String,
        sortOrder: m['sortOrder'] as int,
      ),
      encode: (s) => {
        'id': s.id,
        'titleEn': s.titleEn,
        'titleBn': s.titleBn,
        'groupTag': s.groupTag,
        'sortOrder': s.sortOrder,
      },
      fetchRemote: () {
        final filtered = E2eCurriculumSeeds.subjects
            .where(
              (s) =>
                  s.isActive &&
                  s.rightsStatus == 'cleared' &&
                  (s.groupTag == 'common' || s.groupTag == tag),
            )
            .toList();
        filtered.sort((a, b) {
          final order = a.sortOrder.compareTo(b.sortOrder);
          return order != 0 ? order : a.id.compareTo(b.id);
        });
        return filtered;
      },
    );
  }

  Future<Either<E2eCurriculumFailure, List<E2eChapter>>> getChaptersForSubject(
    int subjectId, {
    bool forceRefresh = false,
  }) {
    return _readCached(
      key: 'chapters:$subjectId',
      kind: 'chapter',
      forceRefresh: forceRefresh,
      decode: (m) => E2eChapter(
        id: m['id'] as int,
        subjectId: m['subjectId'] as int,
        titleEn: m['titleEn'] as String,
        titleBn: m['titleBn'] as String,
        sortOrder: m['sortOrder'] as int,
      ),
      encode: (c) => {
        'id': c.id,
        'subjectId': c.subjectId,
        'titleEn': c.titleEn,
        'titleBn': c.titleBn,
        'sortOrder': c.sortOrder,
      },
      fetchRemote: () => [
        E2eChapter(
          id: subjectId * 10 + 1,
          subjectId: subjectId,
          titleEn: 'Chapter 1: Physical Quantities',
          titleBn: 'অধ্যায় ১: ভৌত রাশি',
          sortOrder: 1,
        ),
      ],
    );
  }

  Future<Either<E2eCurriculumFailure, List<E2eTopic>>> getTopicsForChapter(
    int chapterId, {
    bool forceRefresh = false,
  }) {
    return _readCached(
      key: 'topics:$chapterId',
      kind: 'topic',
      forceRefresh: forceRefresh,
      decode: (m) => E2eTopic(
        id: m['id'] as int,
        titleEn: m['titleEn'] as String,
        titleBn: m['titleBn'] as String,
        provenanceSource: m['provenanceSource'] as String,
        rightsStatus: m['rightsStatus'] as String,
        sortOrder: m['sortOrder'] as int,
      ),
      encode: (t) => {
        'id': t.id,
        'titleEn': t.titleEn,
        'titleBn': t.titleBn,
        'provenanceSource': t.provenanceSource,
        'rightsStatus': t.rightsStatus,
        'sortOrder': t.sortOrder,
      },
      fetchRemote: () => [
        E2eTopic(
          id: chapterId * 10 + 1,
          titleEn: 'Physical Quantities',
          titleBn: 'ভৌত রাশি ও পরিমাপ',
          provenanceSource: 'NCTB SSC Physics Ch.1',
          rightsStatus: 'cleared',
          sortOrder: 1,
        ),
      ],
    );
  }

  void putBoundedSubjectsSnapshot(String key, List<E2eSubject> items) {
    final now = _clock();
    _disk[key] = jsonEncode({
      'schemaVersion': currentSchemaVersion,
      'kind': 'subject',
      'fetchedAt': now.toIso8601String(),
      'items': items
          .map(
            (s) => {
              'id': s.id,
              'titleEn': s.titleEn,
              'titleBn': s.titleBn,
              'groupTag': s.groupTag,
              'sortOrder': s.sortOrder,
            },
          )
          .toList(),
    });
    while (totalCachedSubjects > maxSubjects && _disk.isNotEmpty) {
      _disk.remove(_disk.keys.first);
    }
  }

  Future<Either<E2eCurriculumFailure, List<T>>> _readCached<T>({
    required String key,
    required String kind,
    required bool forceRefresh,
    required T Function(Map<String, dynamic>) decode,
    required Map<String, dynamic> Function(T) encode,
    required List<T> Function() fetchRemote,
  }) async {
    final now = _clock();
    final mem = _memory[key];
    if (!forceRefresh && mem != null && now.difference(mem.fetchedAt) <= ttl) {
      return Right(mem.items.cast<T>());
    }

    final diskEntry = _decodeDisk<T>(key, decode);
    if (!forceRefresh &&
        diskEntry != null &&
        now.difference(diskEntry.fetchedAt) <= ttl) {
      _memory[key] = E2eCacheEntry<Object>(
        items: diskEntry.items.cast<Object>(),
        fetchedAt: diskEntry.fetchedAt,
      );
      return Right(diskEntry.items);
    }

    if (simulateTimeout) {
      if (diskEntry != null) return Right(diskEntry.items);
      return const Left(E2eCurriculumFailure.timeout);
    }
    if (isOffline) {
      if (diskEntry != null) return Right(diskEntry.items);
      return const Left(E2eCurriculumFailure.offline);
    }

    remoteCalls++;
    final fresh = fetchRemote();
    _memory[key] = E2eCacheEntry<Object>(
      items: fresh.cast<Object>(),
      fetchedAt: now,
    );
    _disk[key] = jsonEncode({
      'schemaVersion': currentSchemaVersion,
      'kind': kind,
      'fetchedAt': now.toIso8601String(),
      'items': fresh.map(encode).toList(),
    });
    return Right(fresh);
  }

  E2eCacheEntry<T>? _decodeDisk<T>(
    String key,
    T Function(Map<String, dynamic>) decode,
  ) {
    final raw = _disk[key];
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['schemaVersion'] != currentSchemaVersion) {
        _disk.remove(key);
        return null;
      }
      final fetchedAt = DateTime.parse(map['fetchedAt'] as String);
      final items = (map['items'] as List<dynamic>)
          .map((e) => decode(e as Map<String, dynamic>))
          .toList();
      return E2eCacheEntry<T>(items: items, fetchedAt: fetchedAt);
    } catch (_) {
      _disk.remove(key);
      return null;
    }
  }
}
