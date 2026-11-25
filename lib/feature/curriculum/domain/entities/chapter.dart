// Immutable domain entity representing a syllabus chapter under a subject.
// Carries bilingual titles, optional summaries, and deterministic ordering.
import 'entities_imports.dart';

class Chapter extends Equatable {
  const Chapter({
    required this.id,
    required this.subjectId,
    required this.chapterNumber,
    required this.titleEn,
    required this.titleBn,
    required this.sortOrder,
    this.summaryEn,
    this.summaryBn,
    this.isActive = true,
  });

  final int id;
  final int subjectId;
  final int chapterNumber;
  final String titleEn;
  final String titleBn;
  final String? summaryEn;
  final String? summaryBn;
  final int sortOrder;
  final bool isActive;

  String localizedTitle({bool isBangla = false}) =>
      isBangla ? titleBn : titleEn;

  @override
  List<Object?> get props => [
    id,
    subjectId,
    chapterNumber,
    titleEn,
    titleBn,
    summaryEn,
    summaryBn,
    sortOrder,
    isActive,
  ];
}
