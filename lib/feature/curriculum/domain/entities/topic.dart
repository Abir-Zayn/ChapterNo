// Immutable domain entity representing a learning topic inside a chapter.
// Preserves bilingual titles and content provenance and clearance status.
import 'entities_imports.dart';
import 'subject.dart' show ProvenanceSource;

class Topic extends Equatable {
  const Topic({
    required this.id,
    required this.chapterId,
    required this.topicNumber,
    required this.titleEn,
    required this.titleBn,
    required this.sortOrder,
    this.provenanceSource = ProvenanceSource.nctbSyllabus,
    this.rightsStatus = 'cleared',
    this.isActive = true,
  });

  final int id;
  final int chapterId;
  final int topicNumber;
  final String titleEn;
  final String titleBn;
  final ProvenanceSource provenanceSource;
  final String rightsStatus;
  final int sortOrder;
  final bool isActive;

  bool get isCleared => isActive && rightsStatus == 'cleared';

  String localizedTitle({bool isBangla = false}) =>
      isBangla ? titleBn : titleEn;

  @override
  List<Object?> get props => [
    id,
    chapterId,
    topicNumber,
    titleEn,
    titleBn,
    provenanceSource,
    rightsStatus,
    sortOrder,
    isActive,
  ];
}
