// Serialization DTO mapping topics rows to Topic domain entities.
// Preserves topic provenance, rights clearance, and bilingual titles.
import 'models_imports.dart';

class TopicModel {
  const TopicModel({
    required this.id,
    required this.chapterId,
    required this.topicNumber,
    required this.titleEn,
    required this.titleBn,
    required this.provenanceSource,
    required this.rightsStatus,
    required this.sortOrder,
    required this.isActive,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final chapterId = json['chapter_id'];
    final topicNumber = json['topic_number'];
    final titleEn = json['title_en'];
    final titleBn = json['title_bn'];
    if (id is! num ||
        chapterId is! num ||
        topicNumber is! num ||
        titleEn is! String ||
        titleBn is! String) {
      throw const FormatException('Invalid topic payload');
    }
    return TopicModel(
      id: id.toInt(),
      chapterId: chapterId.toInt(),
      topicNumber: topicNumber.toInt(),
      titleEn: titleEn,
      titleBn: titleBn,
      provenanceSource: json['provenance_source'] as String? ?? 'nctb_syllabus',
      rightsStatus: json['rights_status'] as String? ?? 'cleared',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  factory TopicModel.fromEntity(Topic entity) {
    return TopicModel(
      id: entity.id,
      chapterId: entity.chapterId,
      topicNumber: entity.topicNumber,
      titleEn: entity.titleEn,
      titleBn: entity.titleBn,
      provenanceSource: entity.provenanceSource.dbValue,
      rightsStatus: entity.rightsStatus,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
    );
  }

  final int id;
  final int chapterId;
  final int topicNumber;
  final String titleEn;
  final String titleBn;
  final String provenanceSource;
  final String rightsStatus;
  final int sortOrder;
  final bool isActive;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'chapter_id': chapterId,
    'topic_number': topicNumber,
    'title_en': titleEn,
    'title_bn': titleBn,
    'provenance_source': provenanceSource,
    'rights_status': rightsStatus,
    'sort_order': sortOrder,
    'is_active': isActive,
  };

  Topic toEntity() => Topic(
    id: id,
    chapterId: chapterId,
    topicNumber: topicNumber,
    titleEn: titleEn,
    titleBn: titleBn,
    provenanceSource: ProvenanceSource.fromDb(provenanceSource),
    rightsStatus: rightsStatus,
    sortOrder: sortOrder,
    isActive: isActive,
  );
}
