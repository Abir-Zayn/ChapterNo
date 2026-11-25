// Immutable domain entity representing an NCTB SSC curriculum subject.
// Preserves academic group membership, bilingual titles, and provenance data.
import 'academic_group.dart';
import 'entities_imports.dart';

enum ProvenanceSource {
  nctbSyllabus('nctb_syllabus'),
  curatedEditorial('curated_editorial');

  const ProvenanceSource(this.dbValue);
  final String dbValue;

  static ProvenanceSource fromDb(String? raw) {
    return switch (raw) {
      'curated_editorial' => ProvenanceSource.curatedEditorial,
      _ => ProvenanceSource.nctbSyllabus,
    };
  }
}

class Subject extends Equatable {
  const Subject({
    required this.id,
    required this.code,
    required this.academicGroupCode,
    required this.titleEn,
    required this.titleBn,
    required this.syllabusVersion,
    required this.sortOrder,
    this.educationLevel = 'ssc',
    this.subjectCode,
    this.paperCode,
    this.provenanceSource = ProvenanceSource.nctbSyllabus,
    this.rightsStatus = 'cleared',
    this.isActive = true,
  });

  final int id;
  final String code;
  final String educationLevel;
  final String academicGroupCode;
  final String? subjectCode;
  final String? paperCode;
  final String titleEn;
  final String titleBn;
  final String syllabusVersion;
  final ProvenanceSource provenanceSource;
  final String rightsStatus;
  final int sortOrder;
  final bool isActive;

  bool get isCommon => academicGroupCode == 'common';
  bool get isCleared => isActive && rightsStatus == 'cleared';
  AcademicGroup? get academicGroup => AcademicGroup.tryParse(academicGroupCode);

  bool matchesGroup(AcademicGroup group) =>
      isCommon || academicGroupCode == group.dbValue;

  String localizedTitle({bool isBangla = false}) =>
      isBangla ? titleBn : titleEn;

  @override
  List<Object?> get props => [
    id,
    code,
    educationLevel,
    academicGroupCode,
    subjectCode,
    paperCode,
    titleEn,
    titleBn,
    syllabusVersion,
    provenanceSource,
    rightsStatus,
    sortOrder,
    isActive,
  ];
}
