// Contract for reading the controlled SSC curriculum catalogue.
// Implemented by data-layer repositories with caching or in-memory fixtures.
import 'repositories_imports.dart';

abstract interface class CurriculumRepository {
  Future<Either<CurriculumFailure, List<EducationBoard>>> getEducationBoards({
    bool forceRefresh = false,
  });

  Future<Either<CurriculumFailure, List<Subject>>> getSubjectsForGroup(
    AcademicGroup group, {
    bool forceRefresh = false,
  });

  Future<Either<CurriculumFailure, List<Chapter>>> getChaptersForSubject(
    int subjectId, {
    bool forceRefresh = false,
  });

  Future<Either<CurriculumFailure, List<Topic>>> getTopicsForChapter(
    int chapterId, {
    bool forceRefresh = false,
  });
}
