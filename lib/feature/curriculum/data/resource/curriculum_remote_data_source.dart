// Remote PostgREST boundary for fetching active cleared curriculum records.
// Enforces explicit column projections, 10s timeouts, and typed error mapping.
import 'resource_imports.dart';

enum CurriculumRemoteErrorKind {
  offline,
  unauthorized,
  notFound,
  serverError,
  unknown,
}

class CurriculumRemoteException implements Exception {
  const CurriculumRemoteException(this.kind, [this.message]);

  final CurriculumRemoteErrorKind kind;
  final String? message;

  @override
  String toString() => 'CurriculumRemoteException($kind, $message)';
}

/// Abstract PostgREST query client implemented once Supabase is wired in M1.1.
abstract interface class CurriculumRemoteClient {
  Future<List<Map<String, dynamic>>> fetchEducationBoards({
    required String columns,
  });

  Future<List<Map<String, dynamic>>> fetchSubjectsForGroups({
    required String columns,
    required List<String> academicGroups,
  });

  Future<List<Map<String, dynamic>>> fetchChaptersForSubject({
    required String columns,
    required int subjectId,
  });

  Future<List<Map<String, dynamic>>> fetchTopicsForChapter({
    required String columns,
    required int chapterId,
  });
}

class CurriculumRemoteDataSource {
  CurriculumRemoteDataSource({
    required this.client,
    this.requestTimeout = const Duration(seconds: 10),
  });

  final CurriculumRemoteClient client;
  final Duration requestTimeout;

  static const String boardColumns =
      'id, code, name_en, name_bn, sort_order, is_active';

  static const String subjectColumns =
      'id, code, education_level, academic_group, subject_code, paper_code, '
      'title_en, title_bn, syllabus_version, provenance_source, '
      'rights_status, sort_order, is_active';

  static const String chapterColumns =
      'id, subject_id, chapter_number, title_en, title_bn, summary_en, '
      'summary_bn, sort_order, is_active';

  static const String topicColumns =
      'id, chapter_id, topic_number, title_en, title_bn, provenance_source, '
      'rights_status, sort_order, is_active';

  Future<List<EducationBoard>> fetchEducationBoards() {
    return _execute(() async {
      final rows = await client
          .fetchEducationBoards(columns: boardColumns)
          .timeout(requestTimeout);
      final boards = rows
          .map((row) => EducationBoardModel.fromJson(row).toEntity())
          .where((board) => board.isActive)
          .toList();
      boards.sort((a, b) {
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        return byOrder != 0 ? byOrder : a.id.compareTo(b.id);
      });
      return List<EducationBoard>.unmodifiable(boards);
    });
  }

  Future<List<Subject>> fetchSubjectsForGroup(AcademicGroup group) {
    return _execute(() async {
      final rows = await client
          .fetchSubjectsForGroups(
            columns: subjectColumns,
            academicGroups: <String>['common', group.dbValue],
          )
          .timeout(requestTimeout);
      final subjects = rows
          .map((row) => SubjectModel.fromJson(row).toEntity())
          .where((subject) => subject.isCleared && subject.matchesGroup(group))
          .toList();
      subjects.sort((a, b) {
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        return byOrder != 0 ? byOrder : a.id.compareTo(b.id);
      });
      return List<Subject>.unmodifiable(subjects);
    });
  }

  Future<List<Chapter>> fetchChaptersForSubject(int subjectId) {
    return _execute(() async {
      final rows = await client
          .fetchChaptersForSubject(
            columns: chapterColumns,
            subjectId: subjectId,
          )
          .timeout(requestTimeout);
      final chapters = rows
          .map((row) => ChapterModel.fromJson(row).toEntity())
          .where(
            (chapter) => chapter.isActive && chapter.subjectId == subjectId,
          )
          .toList();
      chapters.sort((a, b) {
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        if (byOrder != 0) return byOrder;
        final byNum = a.chapterNumber.compareTo(b.chapterNumber);
        return byNum != 0 ? byNum : a.id.compareTo(b.id);
      });
      return List<Chapter>.unmodifiable(chapters);
    });
  }

  Future<List<Topic>> fetchTopicsForChapter(int chapterId) {
    return _execute(() async {
      final rows = await client
          .fetchTopicsForChapter(columns: topicColumns, chapterId: chapterId)
          .timeout(requestTimeout);
      final topics = rows
          .map((row) => TopicModel.fromJson(row).toEntity())
          .where((topic) => topic.isCleared && topic.chapterId == chapterId)
          .toList();
      topics.sort((a, b) {
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        if (byOrder != 0) return byOrder;
        final byNum = a.topicNumber.compareTo(b.topicNumber);
        return byNum != 0 ? byNum : a.id.compareTo(b.id);
      });
      return List<Topic>.unmodifiable(topics);
    });
  }

  Future<T> _execute<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on CurriculumRemoteException {
      rethrow;
    } on TimeoutException catch (e) {
      throw CurriculumRemoteException(
        CurriculumRemoteErrorKind.offline,
        e.message ?? 'Curriculum request timed out',
      );
    } on SocketException catch (e) {
      throw CurriculumRemoteException(
        CurriculumRemoteErrorKind.offline,
        e.message,
      );
    } on FormatException catch (e) {
      throw CurriculumRemoteException(
        CurriculumRemoteErrorKind.serverError,
        e.message,
      );
    } on TypeError catch (e) {
      throw CurriculumRemoteException(
        CurriculumRemoteErrorKind.serverError,
        e.toString(),
      );
    } catch (_) {
      throw const CurriculumRemoteException(CurriculumRemoteErrorKind.unknown);
    }
  }
}
