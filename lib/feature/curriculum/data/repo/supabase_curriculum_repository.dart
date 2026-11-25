// CurriculumRepository implementation backed by remote PostgREST and local cache.
// Serves fresh 24h TTL snapshots and falls back to stale cache when offline.
import 'repo_imports.dart';

class SupabaseCurriculumRepository implements CurriculumRepository {
  SupabaseCurriculumRepository({
    required this.remoteDataSource,
    required this.localCacheDataSource,
  });

  final CurriculumRemoteDataSource remoteDataSource;
  final CurriculumLocalCacheDataSource localCacheDataSource;

  bool _lastReadUsedStaleCache = false;

  /// Indicates whether the most recent repository read returned an expired
  /// cached snapshot while the device was offline.
  bool get lastReadUsedStaleCache => _lastReadUsedStaleCache;

  /// Clears in-memory cache entries without deleting the persisted public disk
  /// catalogue cache (never invoke on student sign-out).
  void clearMemoryCache() => localCacheDataSource.clearMemoryCache();

  @override
  Future<Either<CurriculumFailure, List<EducationBoard>>> getEducationBoards({
    bool forceRefresh = false,
  }) {
    return _fetchWithCache<EducationBoard>(
      forceRefresh: forceRefresh,
      readCache: localCacheDataSource.getEducationBoards,
      writeCache: localCacheDataSource.saveEducationBoards,
      fetchRemote: remoteDataSource.fetchEducationBoards,
    );
  }

  @override
  Future<Either<CurriculumFailure, List<Subject>>> getSubjectsForGroup(
    AcademicGroup group, {
    bool forceRefresh = false,
  }) {
    return _fetchWithCache<Subject>(
      forceRefresh: forceRefresh,
      readCache: () => localCacheDataSource.getSubjectsForGroup(group),
      writeCache: (items) =>
          localCacheDataSource.saveSubjectsForGroup(group, items),
      fetchRemote: () => remoteDataSource.fetchSubjectsForGroup(group),
    );
  }

  @override
  Future<Either<CurriculumFailure, List<Chapter>>> getChaptersForSubject(
    int subjectId, {
    bool forceRefresh = false,
  }) {
    return _fetchWithCache<Chapter>(
      forceRefresh: forceRefresh,
      readCache: () => localCacheDataSource.getChaptersForSubject(subjectId),
      writeCache: (items) =>
          localCacheDataSource.saveChaptersForSubject(subjectId, items),
      fetchRemote: () => remoteDataSource.fetchChaptersForSubject(subjectId),
    );
  }

  @override
  Future<Either<CurriculumFailure, List<Topic>>> getTopicsForChapter(
    int chapterId, {
    bool forceRefresh = false,
  }) {
    return _fetchWithCache<Topic>(
      forceRefresh: forceRefresh,
      readCache: () => localCacheDataSource.getTopicsForChapter(chapterId),
      writeCache: (items) =>
          localCacheDataSource.saveTopicsForChapter(chapterId, items),
      fetchRemote: () => remoteDataSource.fetchTopicsForChapter(chapterId),
    );
  }

  Future<Either<CurriculumFailure, List<T>>> _fetchWithCache<T>({
    required bool forceRefresh,
    required Future<CacheLookupResult<T>?> Function() readCache,
    required Future<void> Function(List<T> items) writeCache,
    required Future<List<T>> Function() fetchRemote,
  }) async {
    _lastReadUsedStaleCache = false;
    final cached = await readCache();
    if (!forceRefresh && cached != null && !cached.isExpired) {
      return Right<CurriculumFailure, List<T>>(cached.items);
    }

    try {
      final remote = await fetchRemote();
      await writeCache(remote);
      return Right<CurriculumFailure, List<T>>(remote);
    } on CurriculumRemoteException catch (error) {
      if (error.kind == CurriculumRemoteErrorKind.offline && cached != null) {
        _lastReadUsedStaleCache = true;
        return Right<CurriculumFailure, List<T>>(cached.items);
      }
      return Left<CurriculumFailure, List<T>>(_mapRemoteFailure(error.kind));
    } catch (_) {
      return Left<CurriculumFailure, List<T>>(CurriculumFailure.unknown);
    }
  }

  CurriculumFailure _mapRemoteFailure(CurriculumRemoteErrorKind kind) {
    return switch (kind) {
      CurriculumRemoteErrorKind.offline => CurriculumFailure.offline,
      CurriculumRemoteErrorKind.unauthorized => CurriculumFailure.unauthorized,
      CurriculumRemoteErrorKind.notFound => CurriculumFailure.notFound,
      CurriculumRemoteErrorKind.serverError => CurriculumFailure.serverError,
      CurriculumRemoteErrorKind.unknown => CurriculumFailure.unknown,
    };
  }
}
