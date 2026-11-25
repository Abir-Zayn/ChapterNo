// Verifies SupabaseCurriculumRepository caching, filtering, and offline behavior.
// Controls remote PostgREST responses with Mocktail and deterministic time.
import 'supabase_curriculum_repository_test_imports.dart';

class MockCurriculumRemoteClient extends Mock
    implements CurriculumRemoteClient {}

Map<String, dynamic> _boardRow(
  int id,
  String code,
  int sortOrder, {
  bool active = true,
}) => <String, dynamic>{
  'id': id,
  'code': code,
  'name_en': '$code Board',
  'name_bn': '$code বোর্ড',
  'sort_order': sortOrder,
  'is_active': active,
};

Map<String, dynamic> _subjectRow({
  required int id,
  required String group,
  required int sortOrder,
  String rightsStatus = 'cleared',
  bool isActive = true,
}) => <String, dynamic>{
  'id': id,
  'code': 'sub_$id',
  'education_level': 'ssc',
  'academic_group': group,
  'title_en': 'Subject $id',
  'title_bn': 'বিষয় $id',
  'syllabus_version': 'NCTB-SSC-2026',
  'provenance_source': 'nctb_syllabus',
  'rights_status': rightsStatus,
  'sort_order': sortOrder,
  'is_active': isActive,
};

Map<String, dynamic> _chapterRow(
  int id,
  int subjectId,
  int order, {
  bool active = true,
}) => <String, dynamic>{
  'id': id,
  'subject_id': subjectId,
  'chapter_number': id,
  'title_en': 'Chapter $id',
  'title_bn': 'অধ্যায় $id',
  'sort_order': order,
  'is_active': active,
};

Map<String, dynamic> _topicRow(
  int id,
  int chapterId,
  int order, {
  String rights = 'cleared',
}) => <String, dynamic>{
  'id': id,
  'chapter_id': chapterId,
  'topic_number': id,
  'title_en': 'Topic $id',
  'title_bn': 'টপিক $id',
  'provenance_source': 'nctb_syllabus',
  'rights_status': rights,
  'sort_order': order,
  'is_active': true,
};

void main() {
  late MockCurriculumRemoteClient remoteClient;
  late InMemoryCurriculumCacheStore cacheStore;
  late DateTime clock;
  late CurriculumLocalCacheDataSource localCache;
  late SupabaseCurriculumRepository repository;

  setUp(() {
    remoteClient = MockCurriculumRemoteClient();
    cacheStore = InMemoryCurriculumCacheStore();
    clock = DateTime.utc(2026, 11, 25, 12, 0);
    localCache = CurriculumLocalCacheDataSource(
      store: cacheStore,
      now: () => clock,
    );
    repository = SupabaseCurriculumRepository(
      remoteDataSource: CurriculumRemoteDataSource(client: remoteClient),
      localCacheDataSource: localCache,
    );
  });

  test(
    'filters common + group subjects, excludes drafts, and sorts by sortOrder',
    () async {
      when(
        () => remoteClient.fetchSubjectsForGroups(
          columns: CurriculumRemoteDataSource.subjectColumns,
          academicGroups: <String>['common', 'science'],
        ),
      ).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          _subjectRow(id: 3, group: 'science', sortOrder: 20),
          _subjectRow(id: 1, group: 'common', sortOrder: 10),
          _subjectRow(id: 4, group: 'humanities', sortOrder: 1),
          _subjectRow(
            id: 5,
            group: 'science',
            sortOrder: 5,
            rightsStatus: 'internal_draft',
          ),
          _subjectRow(id: 6, group: 'common', sortOrder: 2, isActive: false),
        ],
      );

      final first = await repository.getSubjectsForGroup(AcademicGroup.science);
      final second = await repository.getSubjectsForGroup(
        AcademicGroup.science,
      );

      final subjects = first.getOrElse(
        () => throw StateError('expected subjects'),
      );
      expect(subjects.map((s) => s.id), <int>[1, 3]);
      expect(second.getOrElse(() => const []).map((s) => s.id), <int>[1, 3]);
      verify(
        () => remoteClient.fetchSubjectsForGroups(
          columns: CurriculumRemoteDataSource.subjectColumns,
          academicGroups: <String>['common', 'science'],
        ),
      ).called(1);
    },
  );

  test(
    'forceRefresh bypasses fresh cache and updates stored snapshot',
    () async {
      var callCount = 0;
      when(
        () => remoteClient.fetchEducationBoards(
          columns: CurriculumRemoteDataSource.boardColumns,
        ),
      ).thenAnswer((_) async {
        callCount += 1;
        return <Map<String, dynamic>>[
          _boardRow(2, 'chittagong', 2),
          _boardRow(1, 'dhaka', 1),
          if (callCount > 1) _boardRow(3, 'rajshahi', 3),
        ];
      });

      await repository.getEducationBoards();
      final refreshed = await repository.getEducationBoards(forceRefresh: true);
      final codes = refreshed.getOrElse(() => const []).map((b) => b.code);

      expect(codes, <String>['dhaka', 'chittagong', 'rajshahi']);
      expect(callCount, 2);
    },
  );

  test(
    'refreshes after 24h TTL expiry and falls back to stale cache when offline',
    () async {
      when(
        () => remoteClient.fetchChaptersForSubject(
          columns: CurriculumRemoteDataSource.chapterColumns,
          subjectId: 109,
        ),
      ).thenAnswer(
        (_) async => <Map<String, dynamic>>[
          _chapterRow(2, 109, 2),
          _chapterRow(1, 109, 1),
          _chapterRow(3, 109, 3, active: false),
        ],
      );

      final initial = await repository.getChaptersForSubject(109);
      expect(initial.getOrElse(() => const []).map((c) => c.id), <int>[1, 2]);
      expect(repository.lastReadUsedStaleCache, isFalse);

      clock = clock.add(const Duration(hours: 24, minutes: 1));
      when(
        () => remoteClient.fetchChaptersForSubject(
          columns: CurriculumRemoteDataSource.chapterColumns,
          subjectId: 109,
        ),
      ).thenThrow(const SocketException('No internet'));

      final stale = await repository.getChaptersForSubject(109);
      expect(stale.getOrElse(() => const []).map((c) => c.id), <int>[1, 2]);
      expect(repository.lastReadUsedStaleCache, isTrue);
    },
  );

  test(
    'returns CurriculumFailure.offline on cold cache miss when offline or timed out',
    () async {
      when(
        () => remoteClient.fetchTopicsForChapter(
          columns: CurriculumRemoteDataSource.topicColumns,
          chapterId: 501,
        ),
      ).thenThrow(TimeoutException('Request timed out'));

      final result = await repository.getTopicsForChapter(501);
      expect(
        result,
        const Left<CurriculumFailure, void>(CurriculumFailure.offline),
      );
    },
  );

  test('does not mask unauthorized errors with stale cache', () async {
    when(
      () => remoteClient.fetchTopicsForChapter(
        columns: CurriculumRemoteDataSource.topicColumns,
        chapterId: 501,
      ),
    ).thenAnswer(
      (_) async => <Map<String, dynamic>>[
        _topicRow(1, 501, 1),
        _topicRow(2, 501, 2, rights: 'internal_draft'),
      ],
    );

    final cached = await repository.getTopicsForChapter(501);
    expect(cached.getOrElse(() => const []).map((t) => t.id), <int>[1]);

    clock = clock.add(const Duration(hours: 25));
    when(
      () => remoteClient.fetchTopicsForChapter(
        columns: CurriculumRemoteDataSource.topicColumns,
        chapterId: 501,
      ),
    ).thenThrow(
      const CurriculumRemoteException(CurriculumRemoteErrorKind.unauthorized),
    );

    final result = await repository.getTopicsForChapter(501);
    expect(
      result,
      const Left<CurriculumFailure, void>(CurriculumFailure.unauthorized),
    );
  });

  test(
    'clearMemoryCache preserves persisted disk snapshot for subsequent reads',
    () async {
      when(
        () => remoteClient.fetchEducationBoards(
          columns: CurriculumRemoteDataSource.boardColumns,
        ),
      ).thenAnswer(
        (_) async => <Map<String, dynamic>>[_boardRow(1, 'dhaka', 1)],
      );

      await repository.getEducationBoards();
      repository.clearMemoryCache();

      final afterMemoryClear = await repository.getEducationBoards();
      expect(afterMemoryClear.getOrElse(() => const []).single.code, 'dhaka');
      verify(
        () => remoteClient.fetchEducationBoards(
          columns: CurriculumRemoteDataSource.boardColumns,
        ),
      ).called(1);
    },
  );
}
