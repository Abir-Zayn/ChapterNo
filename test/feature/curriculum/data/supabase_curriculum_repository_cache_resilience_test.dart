// Verifies best-effort cache persistence in SupabaseCurriculumRepository.
// Ensures disk IO failures never discard valid remote curriculum snapshots.
import 'supabase_curriculum_repository_cache_resilience_test_imports.dart';

class _MockCurriculumRemoteClient extends Mock
    implements CurriculumRemoteClient {}

class _FailingIoCacheStore extends InMemoryCurriculumCacheStore {
  _FailingIoCacheStore({this.failRead = false, this.failWrite = false});

  final bool failRead;
  final bool failWrite;

  @override
  Future<String?> read(String key) async {
    if (failRead) {
      throw const FileSystemException('Simulated cache read IO error');
    }
    return super.read(key);
  }

  @override
  Future<void> write(String key, String value) async {
    if (failWrite) {
      throw const FileSystemException('Simulated disk full write error');
    }
    return super.write(key, value);
  }
}

Map<String, dynamic> _boardRow(int id, String code, int sortOrder) =>
    <String, dynamic>{
      'id': id,
      'code': code,
      'name_en': '$code Board',
      'name_bn': '$code বোর্ড',
      'sort_order': sortOrder,
      'is_active': true,
    };

Map<String, dynamic> _subjectRow(int id, String group, int sortOrder) =>
    <String, dynamic>{
      'id': id,
      'code': 'sub_$id',
      'education_level': 'ssc',
      'academic_group': group,
      'title_en': 'Subject $id',
      'title_bn': 'বিষয় $id',
      'syllabus_version': 'NCTB-SSC-2026',
      'provenance_source': 'nctb_syllabus',
      'rights_status': 'cleared',
      'sort_order': sortOrder,
      'is_active': true,
    };

void main() {
  late _MockCurriculumRemoteClient remoteClient;

  setUp(() {
    remoteClient = _MockCurriculumRemoteClient();
  });

  test(
    'returns remote Right when disk cache write throws FileSystemException',
    () async {
      final repo = SupabaseCurriculumRepository(
        remoteDataSource: CurriculumRemoteDataSource(client: remoteClient),
        localCacheDataSource: CurriculumLocalCacheDataSource(
          store: _FailingIoCacheStore(failWrite: true),
          now: () => DateTime.utc(2026, 11, 25, 12, 0),
        ),
      );
      when(
        () => remoteClient.fetchEducationBoards(
          columns: CurriculumRemoteDataSource.boardColumns,
        ),
      ).thenAnswer(
        (_) async => <Map<String, dynamic>>[_boardRow(1, 'dhaka', 1)],
      );

      final result = await repo.getEducationBoards();

      expect(result, isA<Right<CurriculumFailure, Object?>>());
      final boards = result.getOrElse(
        () => throw StateError('expected remote boards'),
      );
      expect(boards.single.code, 'dhaka');
      expect(repo.lastReadUsedStaleCache, isFalse);
    },
  );

  test(
    'returns remote Right when both cache read and write throw IO errors',
    () async {
      final repo = SupabaseCurriculumRepository(
        remoteDataSource: CurriculumRemoteDataSource(client: remoteClient),
        localCacheDataSource: CurriculumLocalCacheDataSource(
          store: _FailingIoCacheStore(failRead: true, failWrite: true),
          now: () => DateTime.utc(2026, 11, 25, 12, 0),
        ),
      );
      when(
        () => remoteClient.fetchSubjectsForGroups(
          columns: CurriculumRemoteDataSource.subjectColumns,
          academicGroups: <String>['common', 'science'],
        ),
      ).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          _subjectRow(2, 'science', 2),
          _subjectRow(1, 'common', 1),
        ],
      );

      final result = await repo.getSubjectsForGroup(AcademicGroup.science);

      expect(result, isA<Right<CurriculumFailure, Object?>>());
      final subjects = result.getOrElse(
        () => throw StateError('expected remote subjects'),
      );
      expect(subjects.map((s) => s.id), <int>[1, 2]);
      expect(repo.lastReadUsedStaleCache, isFalse);
    },
  );
}
