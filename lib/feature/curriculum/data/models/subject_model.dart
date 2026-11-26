// Serialization DTO mapping subjects rows to Subject domain entities.
// Preserves syllabus provenance, group codes, and bilingual titles.
import 'models_imports.dart';

class SubjectModel {
  const SubjectModel({
    required this.id,
    required this.code,
    required this.educationLevel,
    required this.academicGroupCode,
    required this.titleEn,
    required this.titleBn,
    required this.syllabusVersion,
    required this.provenanceSource,
    required this.rightsStatus,
    required this.sortOrder,
    required this.isActive,
    this.subjectCode,
    this.paperCode,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final code = json['code'];
    final academicGroup = json['academic_group'];
    final titleEn = json['title_en'];
    final titleBn = json['title_bn'];
    final syllabusVersion = json['syllabus_version'];
    if (id is! num ||
        code is! String ||
        academicGroup is! String ||
        titleEn is! String ||
        titleBn is! String ||
        syllabusVersion is! String) {
      throw const FormatException('Invalid subject payload');
    }
    return SubjectModel(
      id: id.toInt(),
      code: code,
      educationLevel: json['education_level'] as String? ?? 'ssc',
      academicGroupCode: academicGroup,
      subjectCode: json['subject_code'] as String?,
      paperCode: json['paper_code'] as String?,
      titleEn: titleEn,
      titleBn: titleBn,
      syllabusVersion: syllabusVersion,
      provenanceSource: json['provenance_source'] as String? ?? 'nctb_syllabus',
      rightsStatus: json['rights_status'] as String? ?? 'cleared',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  factory SubjectModel.fromEntity(Subject entity) {
    return SubjectModel(
      id: entity.id,
      code: entity.code,
      educationLevel: entity.educationLevel,
      academicGroupCode: entity.academicGroupCode,
      subjectCode: entity.subjectCode,
      paperCode: entity.paperCode,
      titleEn: entity.titleEn,
      titleBn: entity.titleBn,
      syllabusVersion: entity.syllabusVersion,
      provenanceSource: entity.provenanceSource.dbValue,
      rightsStatus: entity.rightsStatus,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
    );
  }

  final int id;
  final String code;
  final String educationLevel;
  final String academicGroupCode;
  final String? subjectCode;
  final String? paperCode;
  final String titleEn;
  final String titleBn;
  final String syllabusVersion;
  final String provenanceSource;
  final String rightsStatus;
  final int sortOrder;
  final bool isActive;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'code': code,
    'education_level': educationLevel,
    'academic_group': academicGroupCode,
    'subject_code': subjectCode,
    'paper_code': paperCode,
    'title_en': titleEn,
    'title_bn': titleBn,
    'syllabus_version': syllabusVersion,
    'provenance_source': provenanceSource,
    'rights_status': rightsStatus,
    'sort_order': sortOrder,
    'is_active': isActive,
  };

  Subject toEntity() => Subject(
    id: id,
    code: code,
    educationLevel: educationLevel,
    academicGroupCode: academicGroupCode,
    subjectCode: subjectCode,
    paperCode: paperCode,
    titleEn: titleEn,
    titleBn: titleBn,
    syllabusVersion: syllabusVersion,
    provenanceSource: ProvenanceSource.fromDb(provenanceSource),
    rightsStatus: rightsStatus,
    sortOrder: sortOrder,
    isActive: isActive,
  );
}
